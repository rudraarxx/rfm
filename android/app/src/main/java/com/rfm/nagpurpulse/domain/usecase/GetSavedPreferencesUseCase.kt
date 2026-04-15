package com.rfm.nagpurpulse.domain.usecase

import com.rfm.nagpurpulse.domain.model.UserPreferences
import com.rfm.nagpurpulse.domain.repository.PreferencesRepository
import kotlinx.coroutines.flow.Flow

class GetSavedPreferencesUseCase(private val repository: PreferencesRepository) {
    operator fun invoke(): Flow<UserPreferences> = repository.preferences
}
