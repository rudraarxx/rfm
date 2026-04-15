package com.rfm.nagpurpulse.domain.model

data class Station(
    val id: String,
    val name: String,
    val streamUrl: String,
    val faviconUrl: String,
    val localImageName: String = "",   // drawable resource name, e.g. "radio_mirchi"
    val tags: List<String>,
    val country: String,
    val state: String
)
