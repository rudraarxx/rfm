package com.rfm.nagpurpulse.presentation.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.graphics.ColorMatrix
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import coil.request.ImageRequest
import com.rfm.nagpurpulse.domain.model.Station
import com.rfm.nagpurpulse.presentation.theme.HimalayanDesertSand
import com.rfm.nagpurpulse.presentation.theme.HimalayanGrey

@Composable
fun RadioCard(
    station: Station,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    index: Int = 0,
    isActive: Boolean = false
) {
    // Monochrome matrix
    val matrix = ColorMatrix().apply { setToSaturation(0f) }

    Surface(
        modifier = modifier
            .fillMaxWidth()
            .height(110.dp)
            .clickable(onClick = onClick),
        color = MaterialTheme.colorScheme.surface,
        shape = RoundedCornerShape(2.dp)
    ) {
        Box(modifier = Modifier.fillMaxSize()) {
            // Bolted corners (Rivets)
            BoltedCorners(modifier = Modifier.fillMaxSize())

            Row(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Station Image (Monochrome)
                AsyncImage(
                    model = ImageRequest.Builder(LocalContext.current)
                        .data(station.faviconUrl)
                        .crossfade(true)
                        .build(),
                    contentDescription = station.name,
                    modifier = Modifier
                        .size(80.dp)
                        .clip(RoundedCornerShape(2.dp))
                        .background(Color.Black),
                    contentScale = ContentScale.Crop,
                    colorFilter = ColorFilter.colorMatrix(matrix)
                )

                Spacer(modifier = Modifier.width(16.dp))

                Column(
                    modifier = Modifier.fillMaxHeight(),
                    verticalArrangement = Arrangement.Center
                ) {
                    if (isActive) {
                        Text(
                            text = "ACTIVE NOW",
                            style = MaterialTheme.typography.labelSmall,
                            color = HimalayanDesertSand,
                            fontWeight = FontWeight.Bold
                        )
                    } else {
                        Text(
                            text = "STATION ${String.format("%02d", index + 1)} // ${station.country.uppercase()}",
                            style = MaterialTheme.typography.labelSmall,
                            color = HimalayanGrey
                        )
                    }
                    
                    Text(
                        text = station.name.uppercase(),
                        style = MaterialTheme.typography.displayMedium,
                        fontSize = 22.sp,
                        color = if (isActive) HimalayanDesertSand else MaterialTheme.colorScheme.onSurface
                    )
                    
                    Text(
                        text = "128 KBPS // MP3",
                        style = MaterialTheme.typography.labelMedium,
                        color = HimalayanGrey
                    )
                }
            }
        }
    }
}

@Composable
fun BoltedCorners(modifier: Modifier = Modifier) {
    Canvas(modifier = modifier) {
        val rivetSize = 4.dp.toPx()
        val padding = 4.dp.toPx()
        
        // Corners
        drawRect(
            color = HimalayanGrey.copy(alpha = 0.5f),
            topLeft = androidx.compose.ui.geometry.Offset(padding, padding),
            size = androidx.compose.ui.geometry.Size(rivetSize, rivetSize)
        )
        drawRect(
            color = HimalayanGrey.copy(alpha = 0.5f),
            topLeft = androidx.compose.ui.geometry.Offset(size.width - padding - rivetSize, padding),
            size = androidx.compose.ui.geometry.Size(rivetSize, rivetSize)
        )
        drawRect(
            color = HimalayanGrey.copy(alpha = 0.5f),
            topLeft = androidx.compose.ui.geometry.Offset(padding, size.height - padding - rivetSize),
            size = androidx.compose.ui.geometry.Size(rivetSize, rivetSize)
        )
        drawRect(
            color = HimalayanGrey.copy(alpha = 0.5f),
            topLeft = androidx.compose.ui.geometry.Offset(size.width - padding - rivetSize, size.height - padding - rivetSize),
            size = androidx.compose.ui.geometry.Size(rivetSize, rivetSize)
        )
    }
}
