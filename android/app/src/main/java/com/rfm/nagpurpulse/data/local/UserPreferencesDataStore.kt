package com.rfm.nagpurpulse.data.local

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.core.stringSetPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.rfm.nagpurpulse.domain.model.UserPreferences
import com.rfm.nagpurpulse.domain.repository.PreferencesRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "rfm_preferences")

class UserPreferencesDataStore(private val context: Context) : PreferencesRepository {

    private object Keys {
        val LAST_STATION_ID = stringPreferencesKey("last_station_id")
        val VOLUME = intPreferencesKey("volume")
        val FAVORITE_IDS = stringSetPreferencesKey("favorite_ids")
    }

    override val preferences: Flow<UserPreferences> = context.dataStore.data.map { prefs ->
        UserPreferences(
            lastStationId = prefs[Keys.LAST_STATION_ID] ?: "",
            volume = prefs[Keys.VOLUME] ?: 80,
            favoriteIds = prefs[Keys.FAVORITE_IDS] ?: emptySet()
        )
    }

    override suspend fun saveLastStationId(id: String) {
        context.dataStore.edit { it[Keys.LAST_STATION_ID] = id }
    }

    override suspend fun saveVolume(volume: Int) {
        context.dataStore.edit { it[Keys.VOLUME] = volume }
    }

    override suspend fun saveFavoriteIds(ids: Set<String>) {
        context.dataStore.edit { it[Keys.FAVORITE_IDS] = ids }
    }
}
