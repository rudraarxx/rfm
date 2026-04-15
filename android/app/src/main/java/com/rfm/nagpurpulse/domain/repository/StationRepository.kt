package com.rfm.nagpurpulse.domain.repository

import com.rfm.nagpurpulse.domain.model.Station

interface StationRepository {
    suspend fun getStations(state: String? = null): List<Station>
    suspend fun searchByCity(state: String, city: String, searchTerms: List<String>): List<Station>
}
