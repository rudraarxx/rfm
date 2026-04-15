package com.rfm.nagpurpulse.domain.model

data class UserPreferences(
    val lastStationId: String = "",
    val volume: Int = 80,
    val favoriteIds: Set<String> = emptySet()
)
