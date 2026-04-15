package com.rfm.nagpurpulse.presentation.discovery

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.Menu
import androidx.compose.material.icons.outlined.WbSunny
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rfm.nagpurpulse.domain.model.CityFilter
import com.rfm.nagpurpulse.domain.model.StateFilter
import com.rfm.nagpurpulse.domain.model.Station
import com.rfm.nagpurpulse.presentation.components.RadioCard
import com.rfm.nagpurpulse.presentation.main.MainViewModel
import com.rfm.nagpurpulse.presentation.theme.HimalayanCharcoal
import com.rfm.nagpurpulse.presentation.theme.HimalayanDesertSand
import com.rfm.nagpurpulse.presentation.theme.HimalayanGrey
import com.rfm.nagpurpulse.presentation.theme.HimalayanWhite

@Composable
fun RouteDiscoveryScreen(
    viewModel: MainViewModel,
    modifier: Modifier = Modifier
) {
    val currentStation by viewModel.currentStation.collectAsState()
    val isPlaying by viewModel.isPlaying.collectAsState()
    
    val selectedState by viewModel.selectedState.collectAsState()
    val availableCities by viewModel.availableCities.collectAsState()
    val selectedCity by viewModel.selectedCity.collectAsState()
    val allStates = viewModel.allStates
    
    val stations by viewModel.displayedStations.collectAsState()
    val isLoading by viewModel.isLoadingStations.collectAsState()
    val favoriteIds by viewModel.favoriteIds.collectAsState()

    var isStateExpanded by remember { mutableStateOf(false) }
    var isCityExpanded by remember { mutableStateOf(false) }

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(HimalayanCharcoal)
            .statusBarsPadding()
    ) {
        DiscoveryTopoBackground(modifier = Modifier.fillMaxSize())

        Column(modifier = Modifier.fillMaxSize()) {
            HimalayanDiscoveryTopBar()

            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(16.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                item {
                    HimalayanSearchUnit(modifier = Modifier.padding(vertical = 16.dp))
                }

                item {
                    HimalayanDiscoveryFiltersRow(
                        currentState = selectedState,
                        currentCity = selectedCity,
                        onStateClick = { isStateExpanded = true },
                        onCityClick = { isCityExpanded = true },
                        onGoClick = { viewModel.loadStations() }
                    )
                }

                item {
                    ActiveFrequencyCard(
                        station = currentStation,
                        isPlaying = isPlaying,
                        onPlayPauseClick = { viewModel.togglePlay() }
                    )
                }
                
                // --- MISSION RESULTS SECTION ---
                item {
                    Spacer(modifier = Modifier.height(32.dp))
                    MissionResultsHeader(isLoading = isLoading, resultCount = stations.size)
                }

                if (isLoading) {
                    item {
                        ScanningIndicator()
                    }
                } else if (stations.isEmpty()) {
                    item {
                        NoSignalPlaceholder()
                    }
                } else {
                    itemsIndexed(stations) { index, station ->
                        RadioCard(
                            station = station,
                            index = index,
                            isActive = currentStation?.id == station.id,
                            onClick = { viewModel.selectStation(station) },
                            modifier = Modifier.padding(vertical = 8.dp)
                        )
                    }
                }

                item {
                    BikerStatusBar(modifier = Modifier.padding(top = 32.dp))
                }
            }
        }

        // Industrial Overlays (Dropdowns)
        if (isStateExpanded) {
            HimalayanSelectionOverlay(
                title = "SELECT STATE",
                items = allStates.map { it.displayName },
                onItemSelected = { name ->
                    val state = allStates.find { it.displayName == name }
                    state?.let { viewModel.selectState(it) }
                    isStateExpanded = false
                },
                onClose = { isStateExpanded = false }
            )
        }

        if (isCityExpanded) {
            HimalayanSelectionOverlay(
                title = "SELECT CITY",
                items = availableCities.map { it.displayName },
                onItemSelected = { name ->
                    val city = availableCities.find { it.displayName == name }
                    city?.let { viewModel.selectCity(it) }
                    isCityExpanded = false
                },
                onClose = { isCityExpanded = false }
            )
        }
    }
}

@Composable
fun MissionResultsHeader(isLoading: Boolean, resultCount: Int) {
    Column(modifier = Modifier.fillMaxWidth().padding(bottom = 12.dp)) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(modifier = Modifier.size(4.dp).background(HimalayanDesertSand))
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = if (isLoading) "SCANNING FREQUENCIES..." else "MISSION_RESULTS_COUNT: $resultCount",
                style = MaterialTheme.typography.labelSmall,
                color = HimalayanGrey,
                letterSpacing = 1.sp
            )
        }
        Divider(color = HimalayanGrey.copy(alpha = 0.1f), modifier = Modifier.padding(top = 8.dp))
    }
}

@Composable
fun ScanningIndicator() {
    Column(
        modifier = Modifier.fillMaxWidth().padding(vertical = 32.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        CircularProgressIndicator(color = HimalayanDesertSand, modifier = Modifier.size(32.dp))
        Spacer(modifier = Modifier.height(16.dp))
        Text(text = "ESTABLISHING UPLINK...", style = MaterialTheme.typography.labelSmall, color = HimalayanGrey)
    }
}

@Composable
fun NoSignalPlaceholder() {
    Column(
        modifier = Modifier.fillMaxWidth().padding(vertical = 48.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Icon(imageVector = Icons.Default.SignalCellularNoSim, contentDescription = null, tint = HimalayanGrey.copy(alpha = 0.3f), modifier = Modifier.size(48.dp))
        Spacer(modifier = Modifier.height(16.dp))
        Text(text = "NO SIGNAL DETECTED", style = MaterialTheme.typography.labelSmall, color = HimalayanGrey)
        Text(text = "ADJUST COORDINATES", style = MaterialTheme.typography.labelSmall, color = HimalayanGrey.copy(alpha = 0.5f))
    }
}

@Composable
fun HimalayanDiscoveryFiltersRow(
    currentState: StateFilter,
    currentCity: CityFilter,
    onStateClick: () -> Unit,
    onCityClick: () -> Unit,
    onGoClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(bottom = 24.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        DiscoveryFilterChip(
            label = currentState.displayName.uppercase(),
            modifier = Modifier.weight(1f),
            onClick = onStateClick
        )
        DiscoveryFilterChip(
            label = currentCity.displayName.uppercase(),
            modifier = Modifier.weight(1f),
            onClick = onCityClick
        )
        
        // GO Button
        Box(
            modifier = Modifier
                .size(width = 64.dp, height = 48.dp)
                .background(HimalayanDesertSand, RoundedCornerShape(2.dp))
                .clickable { onGoClick() },
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "GO",
                style = MaterialTheme.typography.displayMedium,
                fontSize = 18.sp,
                color = HimalayanCharcoal,
                fontWeight = FontWeight.Bold
            )
        }
    }
}

@Composable
fun HimalayanSelectionOverlay(
    title: String,
    items: List<String>,
    onItemSelected: (String) -> Unit,
    onClose: () -> Unit
) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black.copy(alpha = 0.8f))
            .clickable { onClose() },
        contentAlignment = Alignment.Center
    ) {
        Surface(
            modifier = Modifier
                .fillMaxWidth(0.85f)
                .heightIn(max = 400.dp)
                .clickable(enabled = false) { },
            color = HimalayanCharcoal,
            shape = RoundedCornerShape(2.dp),
            border = androidx.compose.foundation.BorderStroke(1.dp, HimalayanGrey.copy(alpha = 0.3f))
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text(
                    text = title,
                    style = MaterialTheme.typography.labelSmall,
                    color = HimalayanDesertSand,
                    letterSpacing = 2.sp
                )
                Spacer(modifier = Modifier.height(16.dp))
                Divider(color = HimalayanGrey.copy(alpha = 0.2f))
                
                LazyColumn(modifier = Modifier.fillMaxWidth()) {
                    items(items) { item ->
                        Text(
                            text = item.uppercase(),
                            color = HimalayanWhite,
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable { onItemSelected(item) }
                                .padding(vertical = 12.dp),
                            style = MaterialTheme.typography.bodyLarge
                        )
                        Divider(color = HimalayanGrey.copy(alpha = 0.1f))
                    }
                }
            }
        }
    }
}

@Composable
fun HimalayanDiscoveryTopBar() {
    Column(modifier = Modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Center
        ) {
            Text(
                text = "ROUTE DISCOVERY",
                style = MaterialTheme.typography.headlineMedium,
                color = HimalayanWhite,
                letterSpacing = 2.sp
            )
        }
        Canvas(modifier = Modifier.fillMaxWidth().height(2.dp)) {
            drawLine(
                color = HimalayanGrey.copy(alpha = 0.3f),
                start = androidx.compose.ui.geometry.Offset(16.dp.toPx(), 0f),
                end = androidx.compose.ui.geometry.Offset(size.width - 16.dp.toPx(), 0f),
                strokeWidth = 2.dp.toPx()
            )
        }
    }
}

@Composable
fun HimalayanSearchUnit(modifier: Modifier = Modifier) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .height(64.dp)
            .background(Color(0xFF1A1A1A), RoundedCornerShape(2.dp))
            .padding(8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(48.dp)
                .background(Color(0xFF2C2C2C), RoundedCornerShape(2.dp))
                .clickable { },
            contentAlignment = Alignment.Center
        ) {
            Icon(imageVector = Icons.Default.ArrowBack, contentDescription = null, tint = HimalayanGrey)
        }

        Spacer(modifier = Modifier.width(8.dp))

        Row(
            modifier = Modifier
                .weight(1f)
                .fillMaxHeight()
                .background(HimalayanDesertSand, RoundedCornerShape(2.dp))
                .padding(horizontal = 12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(imageVector = Icons.Default.Radio, contentDescription = null, tint = HimalayanCharcoal, modifier = Modifier.size(20.dp))
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = "ENTER FREQUE",
                style = MaterialTheme.typography.labelLarge,
                color = HimalayanCharcoal.copy(alpha = 0.5f)
            )
        }

        Spacer(modifier = Modifier.width(8.dp))

        Box(
            modifier = Modifier
                .size(48.dp)
                .background(HimalayanDesertSand, RoundedCornerShape(2.dp))
                .clickable { },
            contentAlignment = Alignment.Center
        ) {
            Icon(imageVector = Icons.Default.KeyboardReturn, contentDescription = null, tint = HimalayanCharcoal)
        }
    }
}

@Composable
fun DiscoveryFilterChip(label: String, modifier: Modifier = Modifier, onClick: () -> Unit = {}) {
    Row(
        modifier = modifier
            .height(48.dp)
            .background(Color(0xFF2C2C2C), RoundedCornerShape(2.dp))
            .border(1.dp, HimalayanGrey.copy(alpha = 0.1f), RoundedCornerShape(2.dp))
            .clickable { onClick() },
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .width(4.dp)
                .fillMaxHeight()
                .background(HimalayanDesertSand)
        )
        Spacer(modifier = Modifier.width(12.dp))
        Text(
            text = label,
            style = MaterialTheme.typography.labelSmall,
            color = HimalayanWhite,
            modifier = Modifier.weight(1f),
            maxLines = 1
        )
        Icon(
            imageVector = Icons.Default.KeyboardArrowDown,
            contentDescription = null,
            tint = HimalayanGrey,
            modifier = Modifier.padding(end = 8.dp)
        )
    }
}

@Composable
fun ActiveFrequencyCard(
    station: Station?,
    isPlaying: Boolean,
    onPlayPauseClick: () -> Unit
) {
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .wrapContentHeight(),
        color = Color(0xFF1E1E1E),
        shape = RoundedCornerShape(4.dp),
        border = androidx.compose.foundation.BorderStroke(1.dp, HimalayanGrey.copy(alpha = 0.2f))
    ) {
        Column(modifier = Modifier.padding(24.dp)) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                Column(modifier = Modifier.weight(1f)) {
                    Box(
                        modifier = Modifier
                            .background(Color(0xFFD6C7A1).copy(alpha = 0.1f))
                            .padding(horizontal = 8.dp, vertical = 4.dp)
                    ) {
                        Text(
                            text = "ACTIVE FREQUENCY",
                            style = MaterialTheme.typography.labelSmall,
                            color = HimalayanDesertSand,
                            fontWeight = FontWeight.Bold
                        )
                    }

                    Spacer(modifier = Modifier.height(12.dp))

                    Text(
                        text = station?.name?.take(7) ?: "104.2 FM",
                        style = MaterialTheme.typography.displayLarge.copy(fontSize = 56.sp),
                        color = HimalayanWhite,
                        maxLines = 1
                    )

                    Text(
                        text = "LEH_DISTRICT_ALTITUDE: 3,500M",
                        style = MaterialTheme.typography.labelSmall,
                        color = HimalayanGrey,
                        letterSpacing = 1.sp
                    )
                }

                Box(
                    modifier = Modifier
                        .size(64.dp)
                        .background(Color(0xFF2C2C2C), RoundedCornerShape(2.dp))
                        .padding(12.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(imageVector = Icons.Default.Radio, contentDescription = null, tint = HimalayanWhite, modifier = Modifier.size(32.dp))
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                DiscoveryGauge(
                    label = "SIGNAL STRENGTH",
                    value = {
                        Row(verticalAlignment = Alignment.Bottom) {
                            (1..4).forEach { i ->
                                Box(
                                    modifier = Modifier
                                        .padding(end = 2.dp)
                                        .width(6.dp)
                                        .height((10 + i * 4).dp)
                                        .background(if (i < 4) HimalayanDesertSand else HimalayanGrey.copy(alpha = 0.3f))
                                )
                            }
                        }
                    },
                    modifier = Modifier.weight(1f)
                )

                DiscoveryGauge(
                    label = "WEATHER STATUS",
                    value = {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(imageVector = Icons.Outlined.WbSunny, contentDescription = null, tint = HimalayanWhite, modifier = Modifier.size(16.dp))
                            Spacer(modifier = Modifier.width(8.dp))
                            Column {
                                Text(text = "-12\u00b0C HEAVY", style = MaterialTheme.typography.labelMedium, color = HimalayanWhite)
                                Text(text = "SNOW", style = MaterialTheme.typography.labelSmall, color = HimalayanGrey)
                            }
                        }
                    },
                    modifier = Modifier.weight(1f)
                )
            }

            Spacer(modifier = Modifier.height(32.dp))

            Button(
                onClick = onPlayPauseClick,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(64.dp),
                shape = RoundedCornerShape(2.dp),
                colors = ButtonDefaults.buttonColors(containerColor = HimalayanDesertSand)
            ) {
                Icon(
                    imageVector = if (isPlaying) Icons.Default.Pause else Icons.Default.PlayArrow,
                    contentDescription = null,
                    tint = HimalayanCharcoal
                )
                Spacer(modifier = Modifier.width(12.dp))
                Text(
                    text = if (isPlaying) "HALT AUDIO STREAM" else "COMMENCE AUDIO STREAM",
                    style = MaterialTheme.typography.titleMedium,
                    color = HimalayanCharcoal,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

@Composable
fun DiscoveryGauge(label: String, value: @Composable () -> Unit, modifier: Modifier = Modifier) {
    Row(
        modifier = modifier
            .height(64.dp)
            .background(Color(0xFF141414))
            .padding(8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(modifier = Modifier.width(2.dp).fillMaxHeight().background(HimalayanDesertSand))
        Spacer(modifier = Modifier.width(12.dp))
        Column {
            Text(text = label, style = MaterialTheme.typography.labelSmall, color = HimalayanGrey, fontSize = 9.sp)
            Spacer(modifier = Modifier.height(4.dp))
            value()
        }
    }
}

@Composable
fun BikerStatusBar(modifier: Modifier = Modifier) {
    Row(
        modifier = modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(modifier = Modifier.size(6.dp).background(HimalayanGrey, RoundedCornerShape(3.dp)))
            Spacer(modifier = Modifier.width(8.dp))
            Text(
                text = "GPS_LOCKED: 34.1526\u00b0 N, 77.5771\u00b0 E",
                style = MaterialTheme.typography.labelSmall,
                color = HimalayanGrey,
                fontSize = 10.sp
            )
        }
        Text(
            text = "SYS_v2.0.4_BETA",
            style = MaterialTheme.typography.labelSmall,
            color = HimalayanGrey,
            fontSize = 10.sp
        )
    }
}

@Composable
fun DiscoveryTopoBackground(modifier: Modifier = Modifier) {
    Canvas(modifier = modifier) {
        val stroke = Stroke(width = 1.dp.toPx())
        val color = HimalayanGrey.copy(alpha = 0.05f)
        
        for (i in 0..5) {
            val yOffset = size.height * (0.1f + i * 0.15f)
            val path = Path().apply {
                moveTo(0f, yOffset)
                cubicTo(
                    size.width * 0.3f, yOffset - 60.dp.toPx(),
                    size.width * 0.6f, yOffset + 60.dp.toPx(),
                    size.width, yOffset - 20.dp.toPx()
                )
            }
            drawPath(path, color, style = stroke)
        }
    }
}
