package com.rfm.nagpurpulse.data.local

import com.rfm.nagpurpulse.domain.model.Station

/**
 * Curated Indian FM/internet stations with verified stream URLs sourced from onlineradiofm.in.
 *
 * National chains (Mirchi, BIG FM, Red FM, Radio City) use a single national stream regardless
 * of city — confirmed identical across Mumbai, Pune, Nagpur, Hyderabad, Bengaluru, Kolkata, etc.
 *
 * Key: "<State>|<City>" — must match IndianCities.CityFilter.displayName exactly.
 */
object HardcodedIndianStations {

    fun forCity(state: String, city: String): List<Station> =
        db["$state|$city"] ?: emptyList()

    fun forState(state: String): List<Station> =
        db.entries
            .filter { it.key.startsWith("$state|") }
            .flatMap { it.value }
            .distinctBy { it.id }

    // ── Verified stream constants ────────────────────────────────────────────
    private const val MIRCHI      = "https://eu8.fastcast4u.com/proxy/clyedupq?mp=%2F1"
    private const val BIG_FM      = "https://stream.zeno.fm/dbstwo3dvhhtv"
    private const val RED_FM      = "https://stream.zeno.fm/9phrkb1e3v8uv"
    private const val RADIO_CITY  = "https://stream.zeno.fm/pxc55r5uyc9uv"
    private const val ISHQ_FM     = "https://drive.uber.radio/uber/bollywoodlove/icecast.audio"
    private const val VIVIDH_BHARATI_NATIONAL = "https://air.pc.cdn.bitgravity.com/air/live/pbaudio001/playlist.m3u8"
    private const val AIR_GOLD_DELHI = "https://airhlspush.pc.cdn.bitgravity.com/httppush/hlspbaudio005/hlspbaudio005_Auto.m3u8"
    private const val SURYAN_935  = "https://radios.crabdance.com:8002/2"       // Chennai Tamil
    private const val RADIO_INDIGO = "https://a2.asurahosting.com/hls/office_radio/live.m3u8" // Bangalore

    // ──────────────────────────────────────────────────────────────────────────
    private val db: Map<String, List<Station>> = mapOf(

        // ── Maharashtra — Nagpur ──────────────────────────────────────────────
        "Maharashtra|Nagpur" to listOf(
            Station(
                id = "hc-mirchi-983-nagpur", name = "Radio Mirchi 98.3 – Nagpur",
                streamUrl = MIRCHI, faviconUrl = "", localImageName = "radio_mirchi",
                tags = listOf("bollywood", "nagpur", "hindi"), country = "India", state = "Maharashtra"
            ),
            Station(
                id = "hc-big-927-nagpur", name = "BIG FM 92.7 – Nagpur",
                streamUrl = BIG_FM, faviconUrl = "", localImageName = "big_fm",
                tags = listOf("bollywood", "nagpur", "hindi"), country = "India", state = "Maharashtra"
            ),
            Station(
                id = "hc-radiocity-911-nagpur", name = "Radio City 91.1 – Nagpur",
                streamUrl = RADIO_CITY, faviconUrl = "", localImageName = "radio_city",
                tags = listOf("bollywood", "nagpur", "hindi"), country = "India", state = "Maharashtra"
            ),
            Station(
                id = "hc-redfm-935-nagpur", name = "Red FM 93.5 – Nagpur",
                streamUrl = RED_FM, faviconUrl = "", localImageName = "red_fm",
                tags = listOf("bollywood", "nagpur", "hindi"), country = "India", state = "Maharashtra"
            ),
            Station(
                id = "hc-vividh-bharati-nagpur", name = "Vividh Bharati 100.6 – Nagpur",
                streamUrl = "https://air.pc.cdn.bitgravity.com/air/live/pbaudio070/playlist.m3u8",
                faviconUrl = "", localImageName = "vividh_bharti",
                tags = listOf("national", "classic", "nagpur"), country = "India", state = "Maharashtra"
            ),
            Station(
                id = "hc-air-nagpur", name = "AIR Nagpur 585 AM",
                streamUrl = "https://air.pc.cdn.bitgravity.com/air/live/pbaudio069/playlist.m3u8",
                faviconUrl = "", localImageName = "vividh_bharti",
                tags = listOf("national", "news", "nagpur"), country = "India", state = "Maharashtra"
            ),
        ),

        // ── Maharashtra — Mumbai ──────────────────────────────────────────────
        "Maharashtra|Mumbai" to listOf(
            Station(
                id = "hc-mirchi-983-mumbai", name = "Radio Mirchi 98.3 – Mumbai",
                streamUrl = MIRCHI, faviconUrl = "", localImageName = "radio_mirchi",
                tags = listOf("bollywood", "mumbai", "hindi"), country = "India", state = "Maharashtra"
            ),
            Station(
                id = "hc-big-927-mumbai", name = "BIG FM 92.7 – Mumbai",
                streamUrl = BIG_FM, faviconUrl = "", localImageName = "big_fm",
                tags = listOf("bollywood", "mumbai", "hindi"), country = "India", state = "Maharashtra"
            ),
            Station(
                id = "hc-radiocity-911-mumbai", name = "Radio City 91.1 – Mumbai",
                streamUrl = RADIO_CITY, faviconUrl = "", localImageName = "radio_city",
                tags = listOf("bollywood", "mumbai", "hindi"), country = "India", state = "Maharashtra"
            ),
            Station(
                id = "hc-redfm-935-mumbai", name = "Red FM 93.5 – Mumbai",
                streamUrl = RED_FM, faviconUrl = "", localImageName = "red_fm",
                tags = listOf("bollywood", "mumbai", "hindi"), country = "India", state = "Maharashtra"
            ),
            Station(
                id = "hc-ishq-mumbai", name = "Ishq 104.8 FM – Mumbai",
                streamUrl = ISHQ_FM, faviconUrl = "", localImageName = "",
                tags = listOf("bollywood", "love", "mumbai"), country = "India", state = "Maharashtra"
            ),
        ),

        // ── Maharashtra — Pune ────────────────────────────────────────────────
        "Maharashtra|Pune" to listOf(
            Station(
                id = "hc-mirchi-983-pune", name = "Radio Mirchi 98.3 – Pune",
                streamUrl = MIRCHI, faviconUrl = "", localImageName = "radio_mirchi",
                tags = listOf("bollywood", "pune", "hindi"), country = "India", state = "Maharashtra"
            ),
            Station(
                id = "hc-big-95-pune", name = "BIG 95 FM – Pune",
                streamUrl = BIG_FM, faviconUrl = "", localImageName = "big_fm",
                tags = listOf("bollywood", "pune", "hindi"), country = "India", state = "Maharashtra"
            ),
            Station(
                id = "hc-radiocity-911-pune", name = "Radio City 91.1 – Pune",
                streamUrl = RADIO_CITY, faviconUrl = "", localImageName = "radio_city",
                tags = listOf("bollywood", "pune", "hindi"), country = "India", state = "Maharashtra"
            ),
            Station(
                id = "hc-redfm-935-pune", name = "Red FM 93.5 – Pune",
                streamUrl = RED_FM, faviconUrl = "", localImageName = "red_fm",
                tags = listOf("bollywood", "pune", "hindi"), country = "India", state = "Maharashtra"
            ),
        ),

        // ── Delhi — New Delhi ─────────────────────────────────────────────────
        "Delhi|New Delhi" to listOf(
            Station(
                id = "hc-mirchi-983-delhi", name = "Radio Mirchi 98.3 – Delhi",
                streamUrl = MIRCHI, faviconUrl = "", localImageName = "radio_mirchi",
                tags = listOf("bollywood", "delhi", "hindi"), country = "India", state = "Delhi"
            ),
            Station(
                id = "hc-big-927-delhi", name = "BIG FM 92.7 – Delhi",
                streamUrl = BIG_FM, faviconUrl = "", localImageName = "big_fm",
                tags = listOf("bollywood", "delhi", "hindi"), country = "India", state = "Delhi"
            ),
            Station(
                id = "hc-radiocity-911-delhi", name = "Radio City 91.1 – Delhi",
                streamUrl = RADIO_CITY, faviconUrl = "", localImageName = "radio_city",
                tags = listOf("bollywood", "delhi", "hindi"), country = "India", state = "Delhi"
            ),
            Station(
                id = "hc-redfm-935-delhi", name = "Red FM 93.5 – Delhi",
                streamUrl = RED_FM, faviconUrl = "", localImageName = "red_fm",
                tags = listOf("bollywood", "delhi", "hindi"), country = "India", state = "Delhi"
            ),
            Station(
                id = "hc-ishq-delhi", name = "Ishq 104.8 FM – Delhi",
                streamUrl = ISHQ_FM, faviconUrl = "", localImageName = "",
                tags = listOf("bollywood", "love", "delhi"), country = "India", state = "Delhi"
            ),
            Station(
                id = "hc-air-gold-delhi", name = "AIR FM Gold – Delhi",
                streamUrl = AIR_GOLD_DELHI, faviconUrl = "", localImageName = "vividh_bharti",
                tags = listOf("national", "news", "delhi"), country = "India", state = "Delhi"
            ),
        ),

        // ── Karnataka — Bengaluru ─────────────────────────────────────────────
        "Karnataka|Bengaluru" to listOf(
            Station(
                id = "hc-mirchi-983-bengaluru", name = "Radio Mirchi 98.3 – Bengaluru",
                streamUrl = MIRCHI, faviconUrl = "", localImageName = "radio_mirchi",
                tags = listOf("bollywood", "bengaluru", "kannada"), country = "India", state = "Karnataka"
            ),
            Station(
                id = "hc-big-927-bengaluru", name = "BIG FM 92.7 – Bengaluru",
                streamUrl = BIG_FM, faviconUrl = "", localImageName = "big_fm",
                tags = listOf("bollywood", "bengaluru", "kannada"), country = "India", state = "Karnataka"
            ),
            Station(
                id = "hc-radiocity-911-bengaluru", name = "Radio City 91.1 – Bengaluru",
                streamUrl = RADIO_CITY, faviconUrl = "", localImageName = "radio_city",
                tags = listOf("bollywood", "bengaluru", "kannada"), country = "India", state = "Karnataka"
            ),
            Station(
                id = "hc-redfm-935-bengaluru", name = "Red FM 93.5 – Bengaluru",
                streamUrl = RED_FM, faviconUrl = "", localImageName = "red_fm",
                tags = listOf("bollywood", "bengaluru", "kannada"), country = "India", state = "Karnataka"
            ),
            Station(
                id = "hc-indigo-bengaluru", name = "Radio Indigo 91.9 – Bengaluru",
                streamUrl = RADIO_INDIGO, faviconUrl = "", localImageName = "",
                tags = listOf("international", "english", "bengaluru"), country = "India", state = "Karnataka"
            ),
        ),

        // ── Tamil Nadu — Chennai ──────────────────────────────────────────────
        "Tamil Nadu|Chennai" to listOf(
            Station(
                id = "hc-mirchi-983-chennai", name = "Radio Mirchi 98.3 – Chennai",
                streamUrl = MIRCHI, faviconUrl = "", localImageName = "radio_mirchi",
                tags = listOf("tamil", "chennai", "bollywood"), country = "India", state = "Tamil Nadu"
            ),
            Station(
                id = "hc-big-927-chennai", name = "BIG FM 92.7 – Chennai",
                streamUrl = BIG_FM, faviconUrl = "", localImageName = "big_fm",
                tags = listOf("tamil", "chennai", "bollywood"), country = "India", state = "Tamil Nadu"
            ),
            Station(
                id = "hc-radiocity-911-chennai", name = "Radio City 91.1 – Chennai",
                streamUrl = RADIO_CITY, faviconUrl = "", localImageName = "radio_city",
                tags = listOf("tamil", "chennai", "bollywood"), country = "India", state = "Tamil Nadu"
            ),
            Station(
                id = "hc-suryan-935-chennai", name = "Suryan 93.5 FM – Chennai",
                streamUrl = SURYAN_935, faviconUrl = "", localImageName = "",
                tags = listOf("tamil", "chennai", "film"), country = "India", state = "Tamil Nadu"
            ),
        ),

        // ── Telangana — Hyderabad ─────────────────────────────────────────────
        "Telangana|Hyderabad" to listOf(
            Station(
                id = "hc-mirchi-983-hyderabad", name = "Radio Mirchi 98.3 – Hyderabad",
                streamUrl = MIRCHI, faviconUrl = "", localImageName = "radio_mirchi",
                tags = listOf("telugu", "hyderabad", "bollywood"), country = "India", state = "Telangana"
            ),
            Station(
                id = "hc-big-927-hyderabad", name = "BIG FM 92.7 – Hyderabad",
                streamUrl = BIG_FM, faviconUrl = "", localImageName = "big_fm",
                tags = listOf("telugu", "hyderabad", "bollywood"), country = "India", state = "Telangana"
            ),
            Station(
                id = "hc-radiocity-911-hyderabad", name = "Radio City 91.1 – Hyderabad",
                streamUrl = RADIO_CITY, faviconUrl = "", localImageName = "radio_city",
                tags = listOf("telugu", "hyderabad", "bollywood"), country = "India", state = "Telangana"
            ),
            Station(
                id = "hc-redfm-935-hyderabad", name = "Red FM 93.5 – Hyderabad",
                streamUrl = RED_FM, faviconUrl = "", localImageName = "red_fm",
                tags = listOf("telugu", "hyderabad", "bollywood"), country = "India", state = "Telangana"
            ),
        ),

        // ── Gujarat — Ahmedabad ───────────────────────────────────────────────
        "Gujarat|Ahmedabad" to listOf(
            Station(
                id = "hc-mirchi-983-ahmedabad", name = "Radio Mirchi 98.3 – Ahmedabad",
                streamUrl = MIRCHI, faviconUrl = "", localImageName = "radio_mirchi",
                tags = listOf("gujarati", "ahmedabad", "bollywood"), country = "India", state = "Gujarat"
            ),
            Station(
                id = "hc-radiocity-911-ahmedabad", name = "Radio City 91.1 – Ahmedabad",
                streamUrl = RADIO_CITY, faviconUrl = "", localImageName = "radio_city",
                tags = listOf("gujarati", "ahmedabad", "bollywood"), country = "India", state = "Gujarat"
            ),
            Station(
                id = "hc-redfm-935-ahmedabad", name = "Red FM 93.5 – Ahmedabad",
                streamUrl = RED_FM, faviconUrl = "", localImageName = "red_fm",
                tags = listOf("gujarati", "ahmedabad", "bollywood"), country = "India", state = "Gujarat"
            ),
        ),

        // ── West Bengal — Kolkata ─────────────────────────────────────────────
        "West Bengal|Kolkata" to listOf(
            Station(
                id = "hc-mirchi-983-kolkata", name = "Radio Mirchi 98.3 – Kolkata",
                streamUrl = MIRCHI, faviconUrl = "", localImageName = "radio_mirchi",
                tags = listOf("bengali", "kolkata", "bollywood"), country = "India", state = "West Bengal"
            ),
            Station(
                id = "hc-big-927-kolkata", name = "BIG FM 92.7 – Kolkata",
                streamUrl = BIG_FM, faviconUrl = "", localImageName = "big_fm",
                tags = listOf("bengali", "kolkata", "bollywood"), country = "India", state = "West Bengal"
            ),
            Station(
                id = "hc-redfm-935-kolkata", name = "Red FM 93.5 – Kolkata",
                streamUrl = RED_FM, faviconUrl = "", localImageName = "red_fm",
                tags = listOf("bengali", "kolkata", "bollywood"), country = "India", state = "West Bengal"
            ),
        ),

        // ── Rajasthan — Jaipur ────────────────────────────────────────────────
        "Rajasthan|Jaipur" to listOf(
            Station(
                id = "hc-mirchi-983-jaipur", name = "Radio Mirchi 98.3 – Jaipur",
                streamUrl = MIRCHI, faviconUrl = "", localImageName = "radio_mirchi",
                tags = listOf("rajasthani", "jaipur", "bollywood"), country = "India", state = "Rajasthan"
            ),
            Station(
                id = "hc-big-927-jaipur", name = "BIG FM 92.7 – Jaipur",
                streamUrl = BIG_FM, faviconUrl = "", localImageName = "big_fm",
                tags = listOf("rajasthani", "jaipur", "bollywood"), country = "India", state = "Rajasthan"
            ),
            Station(
                id = "hc-radiocity-911-jaipur", name = "Radio City 91.1 – Jaipur",
                streamUrl = RADIO_CITY, faviconUrl = "", localImageName = "radio_city",
                tags = listOf("rajasthani", "jaipur", "bollywood"), country = "India", state = "Rajasthan"
            ),
            Station(
                id = "hc-redfm-935-jaipur", name = "Red FM 93.5 – Jaipur",
                streamUrl = RED_FM, faviconUrl = "", localImageName = "red_fm",
                tags = listOf("rajasthani", "jaipur", "bollywood"), country = "India", state = "Rajasthan"
            ),
        ),

        // ── Uttar Pradesh — Lucknow ───────────────────────────────────────────
        "Uttar Pradesh|Lucknow" to listOf(
            Station(
                id = "hc-mirchi-983-lucknow", name = "Radio Mirchi 98.3 – Lucknow",
                streamUrl = MIRCHI, faviconUrl = "", localImageName = "radio_mirchi",
                tags = listOf("hindi", "lucknow", "bollywood"), country = "India", state = "Uttar Pradesh"
            ),
            Station(
                id = "hc-big-943-lucknow", name = "BIG 94.3 FM – Lucknow",
                streamUrl = BIG_FM, faviconUrl = "", localImageName = "big_fm",
                tags = listOf("hindi", "lucknow", "bollywood"), country = "India", state = "Uttar Pradesh"
            ),
            Station(
                id = "hc-radiocity-911-lucknow", name = "Radio City 91.1 – Lucknow",
                streamUrl = RADIO_CITY, faviconUrl = "", localImageName = "radio_city",
                tags = listOf("hindi", "lucknow", "bollywood"), country = "India", state = "Uttar Pradesh"
            ),
            Station(
                id = "hc-redfm-935-lucknow", name = "Red FM 93.5 – Lucknow",
                streamUrl = RED_FM, faviconUrl = "", localImageName = "red_fm",
                tags = listOf("hindi", "lucknow", "bollywood"), country = "India", state = "Uttar Pradesh"
            ),
        ),

        // ── Punjab — Amritsar ─────────────────────────────────────────────────
        "Punjab|Amritsar" to listOf(
            Station(
                id = "hc-mirchi-983-amritsar", name = "Radio Mirchi 98.3 – Amritsar",
                streamUrl = MIRCHI, faviconUrl = "", localImageName = "radio_mirchi",
                tags = listOf("punjabi", "amritsar", "bollywood"), country = "India", state = "Punjab"
            ),
            Station(
                id = "hc-redfm-935-amritsar", name = "Red FM 93.5 – Amritsar",
                streamUrl = RED_FM, faviconUrl = "", localImageName = "red_fm",
                tags = listOf("punjabi", "amritsar", "bollywood"), country = "India", state = "Punjab"
            ),
        ),

        // ── National ──────────────────────────────────────────────────────────
        "National|National" to listOf(
            Station(
                id = "hc-vividh-bharati", name = "Vividh Bharati",
                streamUrl = VIVIDH_BHARATI_NATIONAL, faviconUrl = "", localImageName = "vividh_bharti",
                tags = listOf("national", "classic", "hindi"), country = "India", state = "National"
            ),
            Station(
                id = "hc-air-fmgold", name = "AIR FM Gold",
                streamUrl = AIR_GOLD_DELHI, faviconUrl = "", localImageName = "vividh_bharti",
                tags = listOf("national", "news", "hindi"), country = "India", state = "National"
            ),
        ),
    )
}
