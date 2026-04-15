package com.rfm.nagpurpulse.data.remote

import com.rfm.nagpurpulse.data.remote.dto.StationDto
import retrofit2.http.GET
import retrofit2.http.Query

interface RadioBrowserApi {

    @GET("json/stations/bycountrycodeexact/in")
    suspend fun getIndianStations(
        @Query("limit") limit: Int = 200,
        @Query("order") order: String = "votes",
        @Query("reverse") reverse: Boolean = true,
        @Query("hidebroken") hidebroken: Boolean = true,
        @Query("state") state: String? = null
    ): List<StationDto>

    /** Searches stations where the name contains [name]. */
    @GET("json/stations/search")
    suspend fun searchByName(
        @Query("countrycode") countryCode: String = "in",
        @Query("name") name: String,
        @Query("nameExact") nameExact: Boolean = false,
        @Query("limit") limit: Int = 100,
        @Query("order") order: String = "votes",
        @Query("reverse") reverse: Boolean = true,
        @Query("hidebroken") hidebroken: Boolean = true
    ): List<StationDto>
}
