package com.rfm.nagpurpulse.domain.model

data class CityFilter(
    val displayName: String,    // used for both UI label and station name matching
    val searchTerms: List<String> = listOf(displayName)  // extra aliases for matching
) {
    companion object {
        val ALL = CityFilter("All Cities", emptyList())
    }
}

object IndianCities {

    /** Returns the city list for a given state API value. Always starts with [CityFilter.ALL]. */
    fun forState(stateApiValue: String): List<CityFilter> {
        val cities = cityMap[stateApiValue] ?: emptyList()
        return listOf(CityFilter.ALL) + cities
    }

    private val cityMap: Map<String, List<CityFilter>> = mapOf(

        "Andhra Pradesh" to listOf(
            CityFilter("Visakhapatnam", listOf("Visakhapatnam", "Vizag")),
            CityFilter("Vijayawada"),
            CityFilter("Guntur"),
            CityFilter("Tirupati"),
            CityFilter("Kurnool"),
            CityFilter("Nellore"),
            CityFilter("Rajahmundry"),
        ),

        "Assam" to listOf(
            CityFilter("Guwahati"),
            CityFilter("Dibrugarh"),
            CityFilter("Silchar"),
            CityFilter("Jorhat"),
        ),

        "Bihar" to listOf(
            CityFilter("Patna"),
            CityFilter("Gaya"),
            CityFilter("Bhagalpur"),
            CityFilter("Muzaffarpur"),
            CityFilter("Darbhanga"),
        ),

        "Chhattisgarh" to listOf(
            CityFilter("Raipur"),
            CityFilter("Bhilai"),
            CityFilter("Bilaspur"),
            CityFilter("Durg"),
        ),

        "Delhi" to listOf(
            CityFilter("New Delhi", listOf("New Delhi", "Delhi")),
        ),

        "Goa" to listOf(
            CityFilter("Panaji"),
            CityFilter("Margao"),
            CityFilter("Vasco"),
        ),

        "Gujarat" to listOf(
            CityFilter("Ahmedabad"),
            CityFilter("Surat"),
            CityFilter("Vadodara", listOf("Vadodara", "Baroda")),
            CityFilter("Rajkot"),
            CityFilter("Bhavnagar"),
            CityFilter("Gandhinagar"),
        ),

        "Haryana" to listOf(
            CityFilter("Gurugram", listOf("Gurugram", "Gurgaon")),
            CityFilter("Faridabad"),
            CityFilter("Ambala"),
            CityFilter("Rohtak"),
            CityFilter("Hisar"),
        ),

        "Himachal Pradesh" to listOf(
            CityFilter("Shimla"),
            CityFilter("Dharamshala"),
            CityFilter("Manali"),
            CityFilter("Solan"),
        ),

        "Jharkhand" to listOf(
            CityFilter("Ranchi"),
            CityFilter("Jamshedpur"),
            CityFilter("Dhanbad"),
            CityFilter("Bokaro"),
        ),

        "Karnataka" to listOf(
            CityFilter("Bengaluru", listOf("Bengaluru", "Bangalore")),
            CityFilter("Mysuru", listOf("Mysuru", "Mysore")),
            CityFilter("Hubli", listOf("Hubli", "Hubballi")),
            CityFilter("Mangaluru", listOf("Mangaluru", "Mangalore")),
            CityFilter("Belgaum", listOf("Belgaum", "Belagavi")),
            CityFilter("Tumkur"),
        ),

        "Kerala" to listOf(
            CityFilter("Thiruvananthapuram", listOf("Thiruvananthapuram", "Trivandrum")),
            CityFilter("Kochi", listOf("Kochi", "Cochin")),
            CityFilter("Kozhikode", listOf("Kozhikode", "Calicut")),
            CityFilter("Thrissur"),
            CityFilter("Kollam"),
            CityFilter("Palakkad"),
        ),

        "Madhya Pradesh" to listOf(
            CityFilter("Bhopal"),
            CityFilter("Indore"),
            CityFilter("Gwalior"),
            CityFilter("Jabalpur"),
            CityFilter("Ujjain"),
        ),

        "Maharashtra" to listOf(
            CityFilter("Mumbai", listOf("Mumbai", "Bombay")),
            CityFilter("Pune"),
            CityFilter("Nagpur"),
            CityFilter("Nashik"),
            CityFilter("Aurangabad"),
            CityFilter("Thane"),
            CityFilter("Solapur"),
            CityFilter("Kolhapur"),
            CityFilter("Amravati"),
            CityFilter("Nanded"),
        ),

        "Manipur" to listOf(
            CityFilter("Imphal"),
        ),

        "Meghalaya" to listOf(
            CityFilter("Shillong"),
        ),

        "Odisha" to listOf(
            CityFilter("Bhubaneswar"),
            CityFilter("Cuttack"),
            CityFilter("Rourkela"),
            CityFilter("Berhampur"),
        ),

        "Punjab" to listOf(
            CityFilter("Chandigarh"),
            CityFilter("Ludhiana"),
            CityFilter("Amritsar"),
            CityFilter("Jalandhar"),
            CityFilter("Patiala"),
        ),

        "Rajasthan" to listOf(
            CityFilter("Jaipur"),
            CityFilter("Jodhpur"),
            CityFilter("Udaipur"),
            CityFilter("Kota"),
            CityFilter("Ajmer"),
            CityFilter("Bikaner"),
        ),

        "Tamil Nadu" to listOf(
            CityFilter("Chennai", listOf("Chennai", "Madras")),
            CityFilter("Coimbatore"),
            CityFilter("Madurai"),
            CityFilter("Salem"),
            CityFilter("Tiruchirappalli", listOf("Tiruchirappalli", "Trichy")),
            CityFilter("Tirunelveli"),
            CityFilter("Vellore"),
        ),

        "Telangana" to listOf(
            CityFilter("Hyderabad"),
            CityFilter("Warangal"),
            CityFilter("Nizamabad"),
            CityFilter("Karimnagar"),
            CityFilter("Khammam"),
        ),

        "Uttar Pradesh" to listOf(
            CityFilter("Lucknow"),
            CityFilter("Kanpur"),
            CityFilter("Agra"),
            CityFilter("Varanasi"),
            CityFilter("Prayagraj", listOf("Prayagraj", "Allahabad")),
            CityFilter("Meerut"),
            CityFilter("Noida"),
            CityFilter("Ghaziabad"),
        ),

        "Uttarakhand" to listOf(
            CityFilter("Dehradun"),
            CityFilter("Haridwar"),
            CityFilter("Nainital"),
            CityFilter("Rishikesh"),
        ),

        "West Bengal" to listOf(
            CityFilter("Kolkata", listOf("Kolkata", "Calcutta")),
            CityFilter("Howrah"),
            CityFilter("Durgapur"),
            CityFilter("Siliguri"),
            CityFilter("Asansol"),
        ),
    )
}
