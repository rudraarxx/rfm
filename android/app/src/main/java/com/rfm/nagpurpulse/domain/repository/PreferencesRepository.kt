package com.rfm.nagpurpulse.domain.repository

import com.rfm.nagpurpulse.domain.model.UserPreferences
import kotlinx.coroutines.flow.Flow

interface PreferencesRepository {
    val preferences: Flow<UserPreferences>
    suspend fun saveLastStationId(id: String)
    suspend fun saveVolume(volume: Int)
    suspend fun saveFavoriteIds(ids: Set<String>)
}
