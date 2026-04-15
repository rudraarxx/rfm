package com.rfm.nagpurpulse.domain.model

data class StateFilter(
    val apiValue: String,   // sent to Radio Browser API (empty = All India)
    val displayName: String
)

object IndianStates {

    val ALL = StateFilter("", "All India")

    val states: List<StateFilter> = listOf(
        ALL,
        StateFilter("Andhra Pradesh",    "Andhra Pradesh"),
        StateFilter("Assam",             "Assam"),
        StateFilter("Bihar",             "Bihar"),
        StateFilter("Chhattisgarh",      "Chhattisgarh"),
        StateFilter("Delhi",             "Delhi"),
        StateFilter("Goa",               "Goa"),
        StateFilter("Gujarat",           "Gujarat"),
        StateFilter("Haryana",           "Haryana"),
        StateFilter("Himachal Pradesh",  "Himachal Pradesh"),
        StateFilter("Jharkhand",         "Jharkhand"),
        StateFilter("Karnataka",         "Karnataka"),
        StateFilter("Kerala",            "Kerala"),
        StateFilter("Madhya Pradesh",    "Madhya Pradesh"),
        StateFilter("Maharashtra",       "Maharashtra"),
        StateFilter("Manipur",           "Manipur"),
        StateFilter("Meghalaya",         "Meghalaya"),
        StateFilter("Odisha",            "Odisha"),
        StateFilter("Punjab",            "Punjab"),
        StateFilter("Rajasthan",         "Rajasthan"),
        StateFilter("Tamil Nadu",        "Tamil Nadu"),
        StateFilter("Telangana",         "Telangana"),
        StateFilter("Uttar Pradesh",     "Uttar Pradesh"),
        StateFilter("Uttarakhand",       "Uttarakhand"),
        StateFilter("West Bengal",       "West Bengal"),
    )
}
