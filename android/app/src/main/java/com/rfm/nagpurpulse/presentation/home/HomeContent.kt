package com.rfm.nagpurpulse.presentation.home

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.SignalCellularAlt
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rfm.nagpurpulse.presentation.components.HimalayanFrequencyDial
import com.rfm.nagpurpulse.presentation.components.MiniPlayer
import com.rfm.nagpurpulse.presentation.components.RadioCard
import com.rfm.nagpurpulse.presentation.main.MainViewModel
import com.rfm.nagpurpulse.presentation.theme.HimalayanCharcoal
import com.rfm.nagpurpulse.presentation.theme.HimalayanDesertSand
import com.rfm.nagpurpulse.presentation.theme.HimalayanGrey

@Composable
fun HomeContent(
    viewModel: MainViewModel,
    modifier: Modifier = Modifier
) {
    val stations by viewModel.displayedStations.collectAsState()
    val isLoading by viewModel.isLoadingStations.collectAsState()
    val error by viewModel.stationsError.collectAsState()
    val currentStation by viewModel.currentStation.collectAsState()
    val isPlaying by viewModel.isPlaying.collectAsState()
    val isBuffering by viewModel.isBuffering.collectAsState()

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(HimalayanCharcoal)
            .statusBarsPadding()
    ) {
        // Step 1: Subtle Topographic Background Pattern
        TopographicBackground(modifier = Modifier.fillMaxSize())

        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Top Nav-Comms Bar
            item {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 24.dp, vertical = 16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Default.SignalCellularAlt,
                            contentDescription = null,
                            tint = HimalayanDesertSand,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = "NAV-COMMS V1.0",
                            style = MaterialTheme.typography.labelSmall,
                            color = HimalayanDesertSand,
                            letterSpacing = 1.sp
                        )
                    }
                    Text(
                        text = "SIGNAL: HIGH-GAIN",
                        style = MaterialTheme.typography.labelSmall,
                        color = HimalayanGrey,
                        fontSize = 10.sp
                    )
                }
            }

            // Central Tuning Dial
            item {
                HimalayanFrequencyDial(
                    frequency = currentStation?.name?.take(5) ?: "104.2",
                    mhz = "MHZ FM",
                    isPlaying = isPlaying,
                    modifier = Modifier.size(320.dp)
                )
            }

            // Integrated Controls (The Cockpit Area)
            item {
                MiniPlayer(
                    station = currentStation,
                    isPlaying = isPlaying,
                    isBuffering = isBuffering,
                    onPlayPauseClick = { viewModel.togglePlay() },
                    onNextClick = { viewModel.playNext() },
                    onPreviousClick = { viewModel.playPrevious() },
                    onClick = { /* Could open bottom sheet */ },
                    modifier = Modifier.padding(bottom = 24.dp)
                )
            }

            // Station List Header
            item {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 24.dp, vertical = 8.dp),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(text = "STATION FEED", style = MaterialTheme.typography.labelSmall, color = HimalayanGrey)
                    Text(text = "REGION: NAGPUR_PULSE", style = MaterialTheme.typography.labelSmall, color = HimalayanGrey)
                }
            }

            // Station Cards
            if (isLoading) {
                item {
                    CircularProgressIndicator(
                        modifier = Modifier.padding(32.dp),
                        color = HimalayanDesertSand
                    )
                }
            } else if (error != null) {
                item {
                    Text(
                        text = error ?: "An error occurred",
                        modifier = Modifier.padding(32.dp),
                        color = MaterialTheme.colorScheme.error
                    )
                }
            } else {
                itemsIndexed(stations) { index, station ->
                    RadioCard(
                        station = station,
                        index = index,
                        isActive = currentStation?.id == station.id,
                        onClick = { viewModel.selectStation(station) }
                    )
                }
            }
            
            // Padding at bottom for navigation bar
            item {
                Spacer(modifier = Modifier.height(100.dp))
            }
        }
    }
}

@Composable
fun TopographicBackground(modifier: Modifier = Modifier) {
    Canvas(modifier = modifier) {
        val stroke = Stroke(width = 1.dp.toPx())
        val color = HimalayanGrey.copy(alpha = 0.05f)
        
        // Draw 3 subtle wavy paths
        for (i in 0..3) {
            val yOffset = size.height * (0.2f + i * 0.2f)
            val path = Path().apply {
                moveTo(0f, yOffset)
                quadraticBezierTo(
                    size.width * 0.25f, yOffset - 40.dp.toPx(),
                    size.width * 0.5f, yOffset
                )
                quadraticBezierTo(
                    size.width * 0.75f, yOffset + 40.dp.toPx(),
                    size.width, yOffset
                )
            }
            drawPath(path, color, style = stroke)
        }
    }
}
