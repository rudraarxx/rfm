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

import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.ui.text.font.FontWeight
import com.rfm.nagpurpulse.presentation.theme.DeepNavy
import com.rfm.nagpurpulse.presentation.theme.HimalayanWhite
import com.rfm.nagpurpulse.presentation.theme.HimalayanGrey

@Composable
fun HomeContent(
    viewModel: MainViewModel,
    modifier: Modifier = Modifier
) {
    val stations by viewModel.displayedStations.collectAsState()
    val searchQuery by viewModel.searchQuery.collectAsState()
    val currentStation by viewModel.currentStation.collectAsState()

    // Partition stations for the two sections- just taking slices for the demo layout
    val recentlyListened = stations.take(6)
    val recommended = stations.drop(6).take(15)

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(DeepNavy)
            .statusBarsPadding()
    ) {
        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(horizontal = 24.dp, vertical = 24.dp)
        ) {
            // Expanded Search Bar
            item {
                HomeSearchBar(
                    query = searchQuery,
                    onQueryChange = { viewModel.searchStations(it) },
                    modifier = Modifier.padding(bottom = 32.dp)
                )
            }

            // Recently Listened Section
            item {
                Text(
                    text = "Recently Listened",
                    color = HimalayanWhite,
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(bottom = 16.dp)
                )
            }

            item {
                LazyRow(
                    horizontalArrangement = Arrangement.spacedBy(16.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 32.dp)
                ) {
                    items(recentlyListened) { station ->
                        RecentStationItem(
                            station = station,
                            onClick = { viewModel.selectStation(station) }
                        )
                    }
                }
            }

            // Recommend for you Section
            item {
                Text(
                    text = "Recommend for you",
                    color = HimalayanWhite,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Medium,
                    modifier = Modifier.padding(bottom = 16.dp)
                )
            }

            items(recommended) { station ->
                RecommendedStationItem(
                    station = station,
                    onClick = { viewModel.selectStation(station) }
                )
            }

            // Bottom Spacer
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
