package com.rfm.nagpurpulse.presentation.main

import android.app.Application
import android.content.ComponentName
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import androidx.media3.common.MediaItem
import androidx.media3.common.MediaMetadata
import androidx.media3.common.Player
import androidx.media3.session.MediaController
import androidx.media3.session.SessionToken
import com.google.common.util.concurrent.ListenableFuture
import com.google.common.util.concurrent.MoreExecutors
import com.rfm.nagpurpulse.data.local.UserPreferencesDataStore
import com.rfm.nagpurpulse.data.repository.StationRepositoryImpl
import com.rfm.nagpurpulse.data.service.RadioPlaybackService
import com.rfm.nagpurpulse.domain.model.CityFilter
import com.rfm.nagpurpulse.domain.model.IndianCities
import com.rfm.nagpurpulse.domain.model.IndianStates
import com.rfm.nagpurpulse.domain.model.StateFilter
import com.rfm.nagpurpulse.domain.model.Station
import com.rfm.nagpurpulse.domain.usecase.GetSavedPreferencesUseCase
import com.rfm.nagpurpulse.domain.usecase.GetStationsUseCase
import com.rfm.nagpurpulse.domain.usecase.SavePreferencesUseCase
import com.rfm.nagpurpulse.domain.usecase.SearchByCityUseCase
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class MainViewModel(application: Application) : AndroidViewModel(application) {

    private val stationRepository = StationRepositoryImpl()
    private val preferencesDataStore = UserPreferencesDataStore(application)
    private val getStations = GetStationsUseCase(stationRepository)
    private val searchByCity = SearchByCityUseCase(stationRepository)
    private val getPreferences = GetSavedPreferencesUseCase(preferencesDataStore)
    private val savePreferences = SavePreferencesUseCase(preferencesDataStore)

    // ── State filter ──────────────────────────────────────────────────────────
    val allStates: List<StateFilter> = IndianStates.states

    private val _selectedState = MutableStateFlow(IndianStates.ALL)
    val selectedState: StateFlow<StateFilter> = _selectedState.asStateFlow()

    // ── City filter ───────────────────────────────────────────────────────────
    private val _availableCities = MutableStateFlow<List<CityFilter>>(emptyList())
    val availableCities: StateFlow<List<CityFilter>> = _availableCities.asStateFlow()

    private val _selectedCity = MutableStateFlow(CityFilter.ALL)
    val selectedCity: StateFlow<CityFilter> = _selectedCity.asStateFlow()

    // ── Stations ──────────────────────────────────────────────────────────────
    private val _stateStations = MutableStateFlow<List<Station>>(emptyList())
    private val _displayedStationsRaw = MutableStateFlow<List<Station>>(emptyList())

    // ── Favorites ─────────────────────────────────────────────────────────────
    private val _favoriteIds = MutableStateFlow<Set<String>>(emptySet())
    val favoriteIds: StateFlow<Set<String>> = _favoriteIds.asStateFlow()

    /** Displayed stations with favorites sorted to the top. */
    val displayedStations: StateFlow<List<Station>> = combine(
        _displayedStationsRaw, _favoriteIds
    ) { stations, favs ->
        if (favs.isEmpty()) stations
        else stations.sortedWith(compareByDescending { it.id in favs })
    }.stateIn(viewModelScope, SharingStarted.Eagerly, emptyList())

    private val _isLoadingStations = MutableStateFlow(false)
    val isLoadingStations: StateFlow<Boolean> = _isLoadingStations.asStateFlow()

    private val _stationsError = MutableStateFlow<String?>(null)
    val stationsError: StateFlow<String?> = _stationsError.asStateFlow()

    // ── Playback ──────────────────────────────────────────────────────────────
    private val _currentStation = MutableStateFlow<Station?>(null)
    val currentStation: StateFlow<Station?> = _currentStation.asStateFlow()

    private val _isPlaying = MutableStateFlow(false)
    val isPlaying: StateFlow<Boolean> = _isPlaying.asStateFlow()

    private val _isBuffering = MutableStateFlow(false)
    val isBuffering: StateFlow<Boolean> = _isBuffering.asStateFlow()

    private val _volume = MutableStateFlow(80)
    val volume: StateFlow<Int> = _volume.asStateFlow()

    private var controllerFuture: ListenableFuture<MediaController>? = null
    private var mediaController: MediaController? = null

    init {
        loadStations()
        restorePreferences()
    }

    // ── Filter actions ────────────────────────────────────────────────────────

    fun selectState(state: StateFilter) {
        if (_selectedState.value == state) return
        _selectedState.value = state
        _selectedCity.value = CityFilter.ALL
        _availableCities.value = if (state.apiValue.isEmpty()) emptyList()
                                  else IndianCities.forState(state.apiValue)
        loadStations()
    }

    fun selectCity(city: CityFilter) {
        if (_selectedCity.value == city) return
        _selectedCity.value = city
        
        // Decoupled from immediate loading to support tactical "GO" workflow
    }

    private fun loadCityStations(city: CityFilter) {
        viewModelScope.launch {
            _isLoadingStations.value = true
            _stationsError.value = null
            try {
                val state = _selectedState.value.apiValue
                val results = searchByCity(state, city.displayName, city.searchTerms)
                if (results.isEmpty()) {
                    _stationsError.value = "No stations found in ${city.displayName}."
                    _displayedStationsRaw.value = emptyList()
                } else {
                    _displayedStationsRaw.value = results
                }
            } catch (e: Exception) {
                _stationsError.value = "Could not load stations for ${city.displayName}."
                _displayedStationsRaw.value = emptyList()
            } finally {
                _isLoadingStations.value = false
            }
        }
    }

    fun loadStations() {
        val city = _selectedCity.value
        if (city != CityFilter.ALL && city.searchTerms.isNotEmpty()) {
            loadCityStations(city)
            return
        }

        viewModelScope.launch {
            _isLoadingStations.value = true
            _stationsError.value = null
            val stateParam = _selectedState.value.apiValue.ifEmpty { null }
            try {
                val result = getStations(stateParam)
                _stateStations.value = result
                _displayedStationsRaw.value = result
                val currentId = _currentStation.value?.id
                if (currentId != null) {
                    _currentStation.value = result.find { it.id == currentId } ?: _currentStation.value
                }
                if (result.isEmpty()) {
                    _stationsError.value = "No stations found for ${_selectedState.value.displayName}."
                }
            } catch (e: Exception) {
                _stationsError.value = "Could not load stations. Showing local favourites."
                if (_stateStations.value.isEmpty()) {
                    val fallback = StationRepositoryImpl.FALLBACK_STATIONS
                    _stateStations.value = fallback
                    _displayedStationsRaw.value = fallback
                }
            } finally {
                _isLoadingStations.value = false
            }
        }
    }

    // ── Playback actions ──────────────────────────────────────────────────────

    fun connectMediaController() {
        val context = getApplication<Application>()
        val sessionToken = SessionToken(
            context,
            ComponentName(context, RadioPlaybackService::class.java)
        )
        controllerFuture = MediaController.Builder(context, sessionToken).buildAsync()
        controllerFuture?.addListener({
            mediaController = controllerFuture?.get()
            mediaController?.addListener(playerListener)
            syncVolumeToController()
        }, MoreExecutors.directExecutor())
    }

    fun disconnectMediaController() {
        mediaController?.removeListener(playerListener)
        controllerFuture?.let { MediaController.releaseFuture(it) }
        mediaController = null
        controllerFuture = null
    }

    fun selectStation(station: Station) {
        _currentStation.value = station
        val mediaItem = MediaItem.Builder()
            .setMediaId(station.id)
            .setUri(station.streamUrl)
            .setMediaMetadata(
                MediaMetadata.Builder()
                    .setTitle(station.name)
                    .setArtist(station.tags.firstOrNull() ?: "")
                    .build()
            )
            .build()
        mediaController?.setMediaItem(mediaItem)
        mediaController?.prepare()
        mediaController?.play()
        viewModelScope.launch { savePreferences.saveStation(station.id) }
    }

    fun togglePlay() {
        val controller = mediaController ?: return
        if (controller.isPlaying) controller.pause() else controller.play()
    }

    fun playNext() {
        val stations = displayedStations.value
        if (stations.isEmpty()) return
        val idx = stations.indexOfFirst { it.id == _currentStation.value?.id }
        val nextIdx = if (idx >= stations.size - 1) 0 else idx + 1
        selectStation(stations[nextIdx])
    }

    fun playPrevious() {
        val stations = displayedStations.value
        if (stations.isEmpty()) return
        val idx = stations.indexOfFirst { it.id == _currentStation.value?.id }
        val prevIdx = if (idx <= 0) stations.size - 1 else idx - 1
        selectStation(stations[prevIdx])
    }

    fun toggleFavorite(station: Station) {
        val updated = _favoriteIds.value.toMutableSet()
        if (station.id in updated) updated.remove(station.id) else updated.add(station.id)
        _favoriteIds.value = updated
        viewModelScope.launch { savePreferences.saveFavorites(updated) }
    }

    fun isFavorite(stationId: String) = stationId in _favoriteIds.value

    fun setVolume(volume: Int) {
        _volume.value = volume
        mediaController?.volume = volume / 100f
        viewModelScope.launch { savePreferences.saveVolume(volume) }
    }

    private fun syncVolumeToController() {
        mediaController?.volume = _volume.value / 100f
    }

    private fun restorePreferences() {
        viewModelScope.launch {
            val prefs = getPreferences().first()
            _volume.value = prefs.volume
            _favoriteIds.value = prefs.favoriteIds
            if (prefs.lastStationId.isNotEmpty()) {
                _stateStations.first { it.isNotEmpty() }
                _currentStation.value = _stateStations.value.find { it.id == prefs.lastStationId }
            }
        }
    }

    private val playerListener = object : Player.Listener {
        override fun onIsPlayingChanged(isPlaying: Boolean) { _isPlaying.value = isPlaying }
        override fun onPlaybackStateChanged(playbackState: Int) {
            _isBuffering.value = playbackState == Player.STATE_BUFFERING
        }
    }

    override fun onCleared() {
        disconnectMediaController()
        super.onCleared()
    }
}
