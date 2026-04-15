package com.rfm.nagpurpulse.data.remote

import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit

object RadioBrowserService {

    // Three mirrors — tried in order on failure
    private val MIRRORS = listOf(
        "https://de1.api.radio-browser.info/",
        "https://at1.api.radio-browser.info/",
        "https://nl1.api.radio-browser.info/"
    )

    private val okHttpClient = OkHttpClient.Builder()
        .connectTimeout(10, TimeUnit.SECONDS)
        .readTimeout(15, TimeUnit.SECONDS)
        .addInterceptor(
            HttpLoggingInterceptor().apply {
                level = HttpLoggingInterceptor.Level.BASIC
            }
        )
        .addInterceptor { chain ->
            val request = chain.request()
                .newBuilder()
                .header("User-Agent", "RFMNagpurPulse/1.0")
                .build()
            chain.proceed(request)
        }
        .build()

    private fun buildApi(baseUrl: String): RadioBrowserApi =
        Retrofit.Builder()
            .baseUrl(baseUrl)
            .client(okHttpClient)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(RadioBrowserApi::class.java)

    /**
     * Tries each mirror in order and returns the result from the first one that succeeds.
     * Falls back to the next mirror on any exception.
     */
    suspend fun getIndianStations(state: String? = null): List<com.rfm.nagpurpulse.data.remote.dto.StationDto> {
        val stateParam = if (state.isNullOrEmpty()) null else state
        var lastException: Exception? = null
        for (mirror in MIRRORS) {
            try {
                return buildApi(mirror).getIndianStations(state = stateParam)
            } catch (e: Exception) {
                lastException = e
            }
        }
        throw lastException ?: Exception("All Radio Browser mirrors failed")
    }

    /**
     * Searches stations by name across all search terms (aliases).
     * Tries each alias and deduplicates by station ID.
     */
    suspend fun searchByCity(searchTerms: List<String>): List<com.rfm.nagpurpulse.data.remote.dto.StationDto> {
        var lastException: Exception? = null
        for (mirror in MIRRORS) {
            try {
                val api = buildApi(mirror)
                val seen = mutableSetOf<String>()
                val results = mutableListOf<com.rfm.nagpurpulse.data.remote.dto.StationDto>()
                for (term in searchTerms) {
                    api.searchByName(name = term).forEach { dto ->
                        if (seen.add(dto.id)) results.add(dto)
                    }
                }
                return results
            } catch (e: Exception) {
                lastException = e
            }
        }
        throw lastException ?: Exception("All Radio Browser mirrors failed")
    }
}
