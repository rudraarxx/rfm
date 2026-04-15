package com.rfm.nagpurpulse.presentation.theme

import android.app.Activity
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.SideEffect
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

@Immutable
data class NagpurPulseGradients(
    val primaryGradient: Brush = Brush.horizontalGradient(listOf(HimalayanDesertSand, HimalayanDesertSand))
)

val LocalNagpurPulseGradients = staticCompositionLocalOf { NagpurPulseGradients() }

private val DarkColorScheme = darkColorScheme(
    primary = HimalayanDesertSand,
    secondary = HimalayanGrey,
    tertiary = HimalayanAmber,
    background = HimalayanCharcoal,
    surface = HimalayanSurface,
    onPrimary = HimalayanCharcoal,
    onSecondary = HimalayanWhite,
    onTertiary = HimalayanCharcoal,
    onBackground = HimalayanWhite,
    onSurface = HimalayanWhite,
    onSurfaceVariant = HimalayanGrey
)

// We maintain a light scheme but the design is fundamentally dark-centric
private val LightColorScheme = lightColorScheme(
    primary = HimalayanCharcoal,
    secondary = HimalayanGrey,
    tertiary = HimalayanAmber,
    background = Color.White,
    surface = Color(0xFFF5F5F5),
    onPrimary = Color.White,
    onSecondary = HimalayanCharcoal,
    onTertiary = HimalayanCharcoal,
    onBackground = HimalayanCharcoal,
    onSurface = HimalayanCharcoal,
    onSurfaceVariant = HimalayanGrey
)

@Composable
fun NagpurPulseTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    // The Himalayan design system is primarily dark
    val colorScheme = if (darkTheme) DarkColorScheme else DarkColorScheme 
    
    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = colorScheme.background.toArgb()
            window.navigationBarColor = colorScheme.background.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = false
        }
    }

    val gradients = NagpurPulseGradients(
        primaryGradient = Brush.linearGradient(listOf(HimalayanDesertSand, HimalayanDesertSand))
    )

    CompositionLocalProvider(LocalNagpurPulseGradients provides gradients) {
        MaterialTheme(
            colorScheme = colorScheme,
            typography = Typography,
            content = content
        )
    }
}
