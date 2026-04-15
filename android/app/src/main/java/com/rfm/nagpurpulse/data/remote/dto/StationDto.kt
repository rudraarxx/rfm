package com.rfm.nagpurpulse.data.remote.dto

import com.google.gson.annotations.SerializedName
import com.rfm.nagpurpulse.domain.model.Station

data class StationDto(
    @SerializedName("stationuuid") val id: String,
    @SerializedName("name") val name: String,
    @SerializedName("url_resolved") val streamUrl: String,
    @SerializedName("url") val fallbackUrl: String,
    @SerializedName("favicon") val faviconUrl: String,
    @SerializedName("tags") val tags: String,
    @SerializedName("country") val country: String,
    @SerializedName("state") val state: String,
    @SerializedName("language") val language: String,
    @SerializedName("votes") val votes: Int
)

fun StationDto.toDomain(): Station = Station(
    id = id,
    name = name.trim(),
    streamUrl = streamUrl.ifEmpty { fallbackUrl },
    faviconUrl = faviconUrl,
    localImageName = "",
    tags = tags.split(",").map { it.trim() }.filter { it.isNotEmpty() },
    country = country,
    state = state
)
