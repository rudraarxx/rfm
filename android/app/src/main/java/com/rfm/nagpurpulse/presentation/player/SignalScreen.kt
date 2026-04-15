package com.rfm.nagpurpulse.presentation.player

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.Menu
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import coil.request.ImageRequest
import com.rfm.nagpurpulse.presentation.main.MainViewModel
import com.rfm.nagpurpulse.presentation.theme.*

@Composable
fun SignalScreen(
    viewModel: MainViewModel,
    modifier: Modifier = Modifier
) {
    val station by viewModel.currentStation.collectAsState()
    val isPlaying by viewModel.isPlaying.collectAsState()
    val isBuffering by viewModel.isBuffering.collectAsState()

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(HimalayanCharcoal)
            .statusBarsPadding()
    ) {
        // Cockpit Industrial Frame
        CockpitFrame()

        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // 1. Top Bar
            HimalayanSignalTopBar()

            Spacer(modifier = Modifier.height(60.dp))

            // 2. Central Instrument Hub
            Box(
                modifier = Modifier
                    .size(320.dp),
                contentAlignment = Alignment.Center
            ) {
                // Background Gauges (Side-Wings)
                Row(
                    modifier = Modifier.fillMaxWidth().padding(horizontal = 4.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    SignalAnalogGauge(modifier = Modifier.size(100.dp, 120.dp))
                    BitrateInfoBox(modifier = Modifier.size(110.dp, 120.dp))
                }

                // Main Circular Gauge
                CentralInstrumentHub(
                    stationName = station?.name ?: "Radio Himalaya",
                    frequency = "104.2", // Or station metadata frequency
                    isPlaying = isPlaying,
                    stationImageUrl = station?.faviconUrl
                )
            }

            Spacer(modifier = Modifier.weight(1f))

            // 3. Transport Controls
            TacticalTransportControls(
                isPlaying = isPlaying,
                onPlayPause = { viewModel.togglePlay() },
                onPrev = { viewModel.playNext() }, // Map as per logic
                onNext = { viewModel.playNext() },
                onStop = { /* Stop logic */ },
                onEject = { /* Eject logic */ }
            )
            
            Spacer(modifier = Modifier.height(100.dp)) // Bottom Nav spacing
        }
    }
}

@Composable
fun HimalayanSignalTopBar() {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.Center
    ) {
        Text(
            text = "COCKPIT_V1.0",
            style = MaterialTheme.typography.headlineMedium,
            color = HimalayanWhite,
            letterSpacing = 2.sp
        )
    }
}

@Composable
fun CentralInstrumentHub(
    stationName: String,
    frequency: String,
    isPlaying: Boolean,
    stationImageUrl: String?
) {
    val infiniteTransition = rememberInfiniteTransition()
    val glowIntensity by infiniteTransition.animateFloat(
        initialValue = 0.6f,
        targetValue = 1.0f,
        animationSpec = infiniteRepeatable(
            animation = tween(2000, easing = LinearEasing),
            repeatMode = RepeatMode.Reverse
        )
    )

    Box(
        modifier = Modifier
            .size(280.dp),
        contentAlignment = Alignment.Center
    ) {
        // Outer Rings
        Canvas(modifier = Modifier.fillMaxSize()) {
            val center = Offset(size.width / 2, size.height / 2)
            val radius = size.minDimension / 2
            
            // Slate/Teal Outer Border
            drawCircle(
                color = Color(0xFF2C3E50),
                radius = radius,
                style = Stroke(width = 8.dp.toPx())
            )
            
            // Inner Cyan Accents
            drawArc(
                color = Color(0xFF1ABC9C),
                startAngle = 180f,
                sweepAngle = 90f,
                useCenter = false,
                topLeft = Offset(center.x - radius + 12.dp.toPx(), center.y - radius + 12.dp.toPx()),
                size = Size(size.width - 24.dp.toPx(), size.height - 24.dp.toPx()),
                style = Stroke(width = 4.dp.toPx())
            )
        }

        // Inner Content
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(
                text = stationName,
                style = TextStyle(
                    fontFamily = DMSerif,
                    fontStyle = FontStyle.Italic,
                    fontSize = 20.sp,
                    color = HimalayanWhite.copy(alpha = 0.8f)
                )
            )
            
            Box(contentAlignment = Alignment.Center) {
                // Amber Glow
                Box(
                    modifier = Modifier
                        .size(120.dp, 60.dp)
                        .blur(20.dp * glowIntensity)
                        .background(HimalayanDesertSand.copy(alpha = 0.2f * glowIntensity), RoundedCornerShape(30.dp))
                )
                
                Row(verticalAlignment = Alignment.Bottom) {
                    Text(
                        text = frequency,
                        style = MaterialTheme.typography.displayLarge.copy(
                            fontSize = 72.sp,
                            color = HimalayanDesertSand, // Using DesertSand for the amber look
                            fontWeight = FontWeight.Bold
                        )
                    )
                    Text(
                        text = " FM",
                        style = MaterialTheme.typography.labelLarge,
                        color = Color(0xFFF1C40F),
                        modifier = Modifier.padding(bottom = 12.dp)
                    )
                }
            }

            Text(
                text = "STREAMING NOW",
                style = MaterialTheme.typography.labelSmall,
                color = Color(0xFF3498DB), // Teal blue
                letterSpacing = 2.sp,
                fontWeight = FontWeight.Bold
            )

            Spacer(modifier = Modifier.height(16.dp))

            // Central Artwork Circle
            Box(
                modifier = Modifier
                    .size(80.dp)
                    .clip(CircleShape)
                    .border(2.dp, HimalayanGrey.copy(alpha = 0.5f), CircleShape)
                    .background(Color.Black),
                contentAlignment = Alignment.Center
            ) {
                AsyncImage(
                    model = ImageRequest.Builder(LocalContext.current)
                        .data(stationImageUrl)
                        .crossfade(true)
                        .build(),
                    contentDescription = null,
                    modifier = Modifier.fillMaxSize()
                )
            }
        }
    }
}

@Composable
fun SignalAnalogGauge(modifier: Modifier = Modifier) {
    Surface(
        modifier = modifier,
        color = Color(0xFF1C1C1C),
        shape = RoundedCornerShape(2.dp),
        border = androidx.compose.foundation.BorderStroke(1.dp, HimalayanGrey.copy(alpha = 0.1f))
    ) {
        Column(modifier = Modifier.padding(8.dp)) {
            Text(text = "SIGNAL\nLEVEL", style = MaterialTheme.typography.labelSmall, color = HimalayanGrey, fontSize = 8.sp)
            
            Canvas(modifier = Modifier.fillMaxSize().padding(top = 8.dp)) {
                val center = Offset(size.width / 2, size.height)
                val radius = size.width * 0.8f
                
                // Scale Marks
                drawArc(
                    color = HimalayanGrey.copy(alpha = 0.3f),
                    startAngle = 180f,
                    sweepAngle = 180f,
                    useCenter = false,
                    style = Stroke(width = 1.dp.toPx())
                )
                
                // Needle
                drawLine(
                    color = Color(0xFFE67E22), // Orange needle
                    start = center,
                    end = Offset(center.x + 20.dp.toPx(), center.y - 40.dp.toPx()),
                    strokeWidth = 2.dp.toPx()
                )
                
                // Value text via native canvas
                drawContext.canvas.nativeCanvas.drawText(
                   "-20dB",
                   size.width * 0.1f,
                   size.height * 0.9f,
                   android.graphics.Paint().apply {
                       color = android.graphics.Color.GRAY
                       textSize = 24f
                   }
                )
            }
        }
    }
}

@Composable
fun BitrateInfoBox(modifier: Modifier = Modifier) {
    Surface(
        modifier = modifier,
        color = Color(0xFF1C1C1C),
        shape = RoundedCornerShape(2.dp),
        border = androidx.compose.foundation.BorderStroke(1.dp, HimalayanGrey.copy(alpha = 0.1f))
    ) {
        Column(modifier = Modifier.padding(8.dp)) {
            Text(text = "BITRATE / QU", style = MaterialTheme.typography.labelSmall, color = HimalayanGrey, fontSize = 8.sp)
            
            Spacer(modifier = Modifier.height(4.dp))
            LinearProgressIndicator(
                progress = 0.9f,
                modifier = Modifier.fillMaxWidth().height(4.dp),
                color = Color(0xFF3498DB),
                trackColor = Color.Black
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            Text(text = "320 KB", style = MaterialTheme.typography.displayMedium, color = HimalayanWhite, fontSize = 18.sp)
            
            Spacer(modifier = Modifier.height(8.dp))
            // Signal High Badge
            Box(
                modifier = Modifier
                    .border(1.dp, Color(0xFF3498DB).copy(alpha = 0.5f))
                    .padding(horizontal = 4.dp, vertical = 2.dp)
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(text = "SIGNAL", fontSize = 6.sp, color = HimalayanGrey)
                    Text(text = "HIGH", fontSize = 10.sp, color = Color(0xFF3498DB), fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}

@Composable
fun TacticalTransportControls(
    isPlaying: Boolean,
    onPlayPause: () -> Unit,
    onPrev: () -> Unit,
    onNext: () -> Unit,
    onStop: () -> Unit,
    onEject: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 24.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        TransportButton("PREV", Icons.Default.SkipPrevious, onPrev)
        TransportButton("STOP", Icons.Default.Stop, onStop)
        
        // Large Play/Pause Capsule
        Box(
            modifier = Modifier
                .size(width = 100.dp, height = 120.dp)
                .clip(RoundedCornerShape(40.dp))
                .background(Color(0xFF2C3E50))
                .border(2.dp, Color(0xFF1ABC9C).copy(alpha = 0.5f), RoundedCornerShape(40.dp))
                .clickable { onPlayPause() },
            contentAlignment = Alignment.Center
        ) {
            Box(
                modifier = Modifier
                    .fillMaxSize(0.85f)
                    .clip(RoundedCornerShape(35.dp))
                    .background(HimalayanDesertSand)
            ) {
                Icon(
                    imageVector = if (isPlaying) Icons.Default.Pause else Icons.Default.PlayArrow,
                    contentDescription = null,
                    tint = HimalayanCharcoal,
                    modifier = Modifier.size(48.dp).align(Alignment.Center)
                )
            }
        }

        TransportButton("NEXT", Icons.Default.SkipNext, onNext)
        TransportButton("EJECT", Icons.Default.Eject, onEject)
    }
}

@Composable
fun TransportButton(label: String, icon: ImageVector, onClick: () -> Unit) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Box(
            modifier = Modifier
                .size(48.dp, 64.dp)
                .background(Color(0xFF1C1C1C), RoundedCornerShape(4.dp))
                .border(1.dp, HimalayanGrey.copy(alpha = 0.2f), RoundedCornerShape(4.dp))
                .clickable { onClick() },
            contentAlignment = Alignment.Center
        ) {
            Icon(imageVector = icon, contentDescription = null, tint = HimalayanGrey, modifier = Modifier.size(24.dp))
        }
        Spacer(modifier = Modifier.height(4.dp))
        Text(text = label, style = MaterialTheme.typography.labelSmall, color = HimalayanGrey, fontSize = 9.sp)
    }
}

@Composable
fun CockpitFrame() {
    Canvas(modifier = Modifier.fillMaxSize()) {
        val stroke = Stroke(width = 4.dp.toPx())
        val color = Color(0xFF2C2C2C)
        
        // Vertical Rails for the background look
        drawLine(color, Offset(24.dp.toPx(), 40.dp.toPx()), Offset(24.dp.toPx(), size.height - 120.dp.toPx()), strokeWidth = 8.dp.toPx())
        drawLine(color, Offset(size.width - 24.dp.toPx(), 40.dp.toPx()), Offset(size.width - 24.dp.toPx(), size.height - 120.dp.toPx()), strokeWidth = 8.dp.toPx())
        
        // Horizontal connectors
        drawLine(color, Offset(24.dp.toPx(), 100.dp.toPx()), Offset(size.width - 24.dp.toPx(), 100.dp.toPx()), strokeWidth = 4.dp.toPx())
    }
}
