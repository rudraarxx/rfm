package com.rfm.nagpurpulse.domain.usecase

import com.rfm.nagpurpulse.domain.model.Station
import com.rfm.nagpurpulse.domain.repository.StationRepository

class GetStationsUseCase(private val repository: StationRepository) {
    suspend operator fun invoke(state: String? = null): List<Station> =
        repository.getStations(state)
}
