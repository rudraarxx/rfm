package com.rfm.nagpurpulse.domain.usecase

import com.rfm.nagpurpulse.domain.model.Station
import com.rfm.nagpurpulse.domain.repository.StationRepository

class SearchByCityUseCase(private val repository: StationRepository) {
    suspend operator fun invoke(state: String, city: String, searchTerms: List<String>): List<Station> =
        repository.searchByCity(state, city, searchTerms)
}
