package com.rfm.nagpurpulse.data.repository

import com.rfm.nagpurpulse.data.local.HardcodedIndianStations
import com.rfm.nagpurpulse.data.remote.RadioBrowserService
import com.rfm.nagpurpulse.data.remote.dto.toDomain
import com.rfm.nagpurpulse.domain.model.Station
import com.rfm.nagpurpulse.domain.repository.StationRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class StationRepositoryImpl : StationRepository {

    override suspend fun getStations(state: String?): List<Station> = withContext(Dispatchers.IO) {
        try {
            RadioBrowserService.getIndianStations(state = state)
                .filter { it.streamUrl.isNotEmpty() || it.fallbackUrl.isNotEmpty() }
                .map { it.toDomain() }
                .ifEmpty { if (state.isNullOrEmpty()) FALLBACK_STATIONS else emptyList() }
        } catch (e: Exception) {
            if (state.isNullOrEmpty()) FALLBACK_STATIONS else emptyList()
        }
    }

    override suspend fun searchByCity(state: String, city: String, searchTerms: List<String>): List<Station> = withContext(Dispatchers.IO) {
        val hardcoded = HardcodedIndianStations.forCity(state, city)
        val apiResults = try {
            RadioBrowserService.searchByCity(searchTerms)
                .filter { it.streamUrl.isNotEmpty() || it.fallbackUrl.isNotEmpty() }
                .map { it.toDomain() }
        } catch (e: Exception) {
            emptyList()
        }
        // Hardcoded stations first, then any API stations not already present
        val hardcodedIds = hardcoded.map { it.id }.toSet()
        hardcoded + apiResults.filter { it.id !in hardcodedIds }
    }

    companion object {
        val FALLBACK_STATIONS = listOf(
            Station(
                id = "vividh-bharti",
                name = "Vividh Bharati",
                streamUrl = "https://air.pc.cdn.bitgravity.com/air/live/pbaudio001/playlist.m3u8",
                faviconUrl = "",
                localImageName = "vividh_bharti",
                tags = listOf("national", "classic", "hindi"),
                country = "India",
                state = "National"
            ),
            Station(
                id = "mirchi-983",
                name = "Radio Mirchi 98.3 – Nagpur",
                streamUrl = "https://eu8.fastcast4u.com/proxy/clyedupq?mp=%2F1",
                faviconUrl = "",
                localImageName = "radio_mirchi",
                tags = listOf("bollywood", "nagpur", "hindi"),
                country = "India",
                state = "Maharashtra"
            ),
            Station(
                id = "big-927",
                name = "BIG FM 92.7 – Nagpur",
                streamUrl = "https://stream.zeno.fm/dbstwo3dvhhtv",
                faviconUrl = "",
                localImageName = "big_fm",
                tags = listOf("bollywood", "nagpur", "hindi"),
                country = "India",
                state = "Maharashtra"
            ),
            Station(
                id = "radiocity-911",
                name = "Radio City 91.1 – Nagpur",
                streamUrl = "https://stream.zeno.fm/pxc55r5uyc9uv",
                faviconUrl = "",
                localImageName = "radio_city",
                tags = listOf("bollywood", "nagpur", "hindi"),
                country = "India",
                state = "Maharashtra"
            ),
            Station(
                id = "redfm-935",
                name = "Red FM 93.5 – Nagpur",
                streamUrl = "https://stream.zeno.fm/9phrkb1e3v8uv",
                faviconUrl = "",
                localImageName = "red_fm",
                tags = listOf("bollywood", "nagpur", "hindi"),
                country = "India",
                state = "Maharashtra"
            )
        )
    }
}
