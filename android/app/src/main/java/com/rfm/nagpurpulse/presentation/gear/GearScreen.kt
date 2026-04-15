package com.rfm.nagpurpulse.presentation.gear

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Build
import androidx.compose.material.icons.filled.CellTower
import androidx.compose.material.icons.filled.Explore
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.outlined.Menu
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.rfm.nagpurpulse.domain.model.Station
import com.rfm.nagpurpulse.presentation.main.MainViewModel
import com.rfm.nagpurpulse.presentation.theme.HimalayanCharcoal
import com.rfm.nagpurpulse.presentation.theme.HimalayanDesertSand
import com.rfm.nagpurpulse.presentation.theme.HimalayanGrey
import com.rfm.nagpurpulse.presentation.theme.HimalayanWhite

@Composable
fun GearScreen(
    viewModel: MainViewModel,
    modifier: Modifier = Modifier
) {
    val favoriteIds by viewModel.favoriteIds.collectAsState()
    val allStations by viewModel.displayedStations.collectAsState()
    val favorites = allStations.filter { it.id in favoriteIds }

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(HimalayanCharcoal)
            .statusBarsPadding()
    ) {
        Column(modifier = Modifier.fillMaxSize()) {
            HimalayanGearTopBar()

            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                contentPadding = PaddingValues(16.dp)
            ) {
                // 1. Header Information
                item {
                    Column(modifier = Modifier.padding(vertical = 16.dp)) {
                        Text(
                            text = "COCKPIT GEAR: ${favorites.size} STATIONS LOADED",
                            style = MaterialTheme.typography.displayMedium,
                            color = HimalayanDesertSand,
                            fontSize = 28.sp
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = "SYSTEM STATUS: FULLY DEPLOYED // SECTOR 04",
                            style = MaterialTheme.typography.labelSmall,
                            color = HimalayanGrey,
                            letterSpacing = 1.sp
                        )
                    }
                }

                // 2. Sort By Kit Bar
                item {
                    SortByKitBar()
                }

                // 3. Favorites List with Vertical Rail
                if (favorites.isEmpty()) {
                    item {
                        Box(
                            modifier = Modifier.fillMaxWidth().height(200.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(text = "0 GEAR UNITS DEPLOYED", color = HimalayanGrey)
                        }
                    }
                } else {
                    itemsIndexed(favorites) { index, station ->
                        GearStationItem(
                            station = station,
                            isFirst = index == 0,
                            isLast = index == favorites.size - 1,
                            onToggleFavorite = { viewModel.toggleFavorite(station) }
                        )
                    }
                }

                // 4. Maintenance Gauge
                item {
                    MaintenanceGauge(modifier = Modifier.padding(top = 24.dp, bottom = 100.dp))
                }
            }
        }
    }
}

@Composable
fun HimalayanGearTopBar() {
    Column(modifier = Modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Center
        ) {
            Text(
                text = "COCKPIT GEAR",
                style = MaterialTheme.typography.headlineMedium,
                color = HimalayanWhite,
                letterSpacing = 2.sp
            )
        }
        Divider(color = HimalayanGrey.copy(alpha = 0.2f), thickness = 1.dp)
    }
}

@Composable
fun SortByKitBar() {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(56.dp)
            .border(1.dp, HimalayanGrey.copy(alpha = 0.2f), RoundedCornerShape(2.dp))
            .padding(horizontal = 16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(text = "SORT BY KIT:", style = MaterialTheme.typography.labelSmall, color = HimalayanWhite)
        Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
            KitIcon(Icons.Default.Build)
            KitIcon(Icons.Default.Explore)
            KitIcon(Icons.Default.Settings)
            KitIcon(Icons.Default.CellTower)
        }
    }
}

@Composable
fun KitIcon(icon: ImageVector) {
    Icon(imageVector = icon, contentDescription = null, tint = HimalayanGrey, modifier = Modifier.size(18.dp))
}

@Composable
fun GearStationItem(
    station: Station,
    isFirst: Boolean,
    isLast: Boolean,
    onToggleFavorite: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(110.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Vertical Rail Section
        Box(
            modifier = Modifier
                .width(40.dp)
                .fillMaxHeight(),
            contentAlignment = Alignment.Center
        ) {
            // Main Line
            Canvas(modifier = Modifier.fillMaxSize()) {
                val centerX = size.width / 2
                drawLine(
                    color = HimalayanGrey.copy(alpha = 0.2f),
                    start = Offset(centerX, 0f),
                    end = Offset(centerX, size.height),
                    strokeWidth = 2.dp.toPx()
                )
            }
            // Accent Bricks (Horizontal Bricks on the Rail)
            Box(
                modifier = Modifier
                    .size(24.dp, 12.dp)
                    .background(HimalayanGrey.copy(alpha = 0.3f))
                    .border(1.dp, HimalayanDesertSand.copy(alpha = 0.5f))
            )

            // The square "Brick" on the rail as seen in screenshot
            // Actually, in the screenshot, it's a tan square indicator next to the card
        }

        // The Station Card
        Surface(
            modifier = Modifier
                .weight(1f)
                .padding(vertical = 4.dp)
                .fillMaxHeight(),
            color = Color(0xFF1E1E1E),
            shape = RoundedCornerShape(2.dp),
            border = androidx.compose.foundation.BorderStroke(1.dp, HimalayanGrey.copy(alpha = 0.1f))
        ) {
            Row(
                modifier = Modifier.padding(12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Industrial Circular Icon
                Box(
                    modifier = Modifier
                        .size(56.dp)
                        .clip(CircleShape)
                        .background(Color.Black)
                        .border(1.dp, HimalayanGrey.copy(alpha = 0.5f), CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Explore, // Placeholder for industrial icon
                        contentDescription = null,
                        tint = HimalayanDesertSand,
                        modifier = Modifier.size(28.dp)
                    )
                }

                Spacer(modifier = Modifier.width(16.dp))

                Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.Center) {
                    Text(
                        text = station.name.uppercase(),
                        style = MaterialTheme.typography.displayMedium,
                        fontSize = 20.sp,
                        color = HimalayanWhite
                    )
                    Text(
                        text = "STATION_ID: ${station.id.take(4).uppercase()}-BETA",
                        style = MaterialTheme.typography.labelSmall,
                        color = HimalayanGrey,
                        fontSize = 10.sp
                    )
                }

                IconButton(onClick = onToggleFavorite) {
                    Icon(imageVector = Icons.Default.Star, contentDescription = null, tint = HimalayanDesertSand, modifier = Modifier.size(20.dp))
                }
            }
        }
    }
}

@Composable
fun MaintenanceGauge(modifier: Modifier = Modifier) {
    Surface(
        modifier = modifier
            .fillMaxWidth()
            .wrapContentHeight(),
        color = Color.Transparent,
        border = androidx.compose.foundation.BorderStroke(2.dp, HimalayanGrey.copy(alpha = 0.3f)),
        shape = RoundedCornerShape(2.dp)
    ) {
        Column(modifier = Modifier.padding(20.dp)) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.Bottom) {
                Text(text = "MAINTENANCE GAUGE", style = MaterialTheme.typography.labelSmall, color = HimalayanWhite, fontWeight = FontWeight.Bold)
                Text(text = "84%", style = MaterialTheme.typography.displayLarge, color = HimalayanWhite, fontSize = 32.sp)
            }
            
            Spacer(modifier = Modifier.height(16.dp))
            
            // Progress Bar
            LinearProgressIndicator(
                progress = 0.84f,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(32.dp),
                color = HimalayanDesertSand,
                trackColor = Color(0xFF2C2C2C)
            )
            
            Spacer(modifier = Modifier.height(16.dp))
            
            Text(
                text = "MECHANICAL DURABILITY WITHIN NOMINAL PARAMETERS. ALL RIVETS SECURED. SYSTEM COOLANT STABLE AT 14,000FT.",
                style = MaterialTheme.typography.labelSmall,
                color = HimalayanGrey,
                fontSize = 11.sp,
                lineHeight = 16.sp
            )
        }
    }
}
