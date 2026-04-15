package com.rfm.nagpurpulse.domain.usecase

import com.rfm.nagpurpulse.domain.repository.PreferencesRepository

class SavePreferencesUseCase(private val repository: PreferencesRepository) {
    suspend fun saveStation(id: String) = repository.saveLastStationId(id)
    suspend fun saveVolume(volume: Int) = repository.saveVolume(volume)
    suspend fun saveFavorites(ids: Set<String>) = repository.saveFavoriteIds(ids)
}
