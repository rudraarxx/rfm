package com.rfm.nagpurpulse.data.service

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.os.Build
import androidx.media3.common.AudioAttributes
import androidx.media3.common.C
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.source.DefaultMediaSourceFactory
import androidx.media3.session.MediaLibraryService
import androidx.media3.session.MediaSession

class RadioPlaybackService : MediaLibraryService() {

    private lateinit var player: ExoPlayer
    private lateinit var mediaSession: MediaLibrarySession
    private lateinit var audioManager: AudioManager
    private lateinit var audioFocusRequest: AudioFocusRequest
    private var wasPlayingBeforeFocusLoss = false

    private val noisyReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (intent.action == AudioManager.ACTION_AUDIO_BECOMING_NOISY) {
                player.pause()
            }
        }
    }

    private val audioFocusListener = AudioManager.OnAudioFocusChangeListener { focusChange ->
        when (focusChange) {
            AudioManager.AUDIOFOCUS_GAIN -> {
                player.volume = 1f
                if (wasPlayingBeforeFocusLoss) {
                    player.play()
                    wasPlayingBeforeFocusLoss = false
                }
            }
            AudioManager.AUDIOFOCUS_LOSS -> {
                wasPlayingBeforeFocusLoss = player.isPlaying
                player.pause()
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> {
                wasPlayingBeforeFocusLoss = player.isPlaying
                player.pause()
            }
            AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK -> {
                player.volume = 0.3f
            }
        }
    }

    override fun onCreate() {
        super.onCreate()

        audioManager = getSystemService(AUDIO_SERVICE) as AudioManager

        audioFocusRequest = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
            .setOnAudioFocusChangeListener(audioFocusListener)
            .setAudioAttributes(
                android.media.AudioAttributes.Builder()
                    .setUsage(android.media.AudioAttributes.USAGE_MEDIA)
                    .setContentType(android.media.AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
            )
            .setAcceptsDelayedFocusGain(true)
            .build()

        // Zeno.fm streams (and others) require browser-like headers + redirect following.
        // Without a Referer the server returns 401; with it, it 302s to a short-lived CDN URL.
        val httpDataSourceFactory = DefaultHttpDataSource.Factory()
            .setUserAgent(
                "Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 " +
                "(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36"
            )
            .setAllowCrossProtocolRedirects(true)
            .setDefaultRequestProperties(mapOf("Referer" to "https://onlineradiofm.in/"))

        player = ExoPlayer.Builder(this)
            .setMediaSourceFactory(DefaultMediaSourceFactory(httpDataSourceFactory))
            .setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(C.USAGE_MEDIA)
                    .setContentType(C.AUDIO_CONTENT_TYPE_MUSIC)
                    .build(),
                /* handleAudioFocus= */ false  // We handle focus manually
            )
            .setHandleAudioBecomingNoisy(false)  // We handle via BroadcastReceiver
            .build()

        val sessionActivityIntent = packageManager
            .getLaunchIntentForPackage(packageName)
            ?.let { PendingIntent.getActivity(this, 0, it, PendingIntent.FLAG_IMMUTABLE) }

        mediaSession = MediaLibrarySession.Builder(this, player, object : MediaLibrarySession.Callback {})
            .also { builder ->
                sessionActivityIntent?.let { builder.setSessionActivity(it) }
            }
            .build()

        registerReceiver(
            noisyReceiver,
            IntentFilter(AudioManager.ACTION_AUDIO_BECOMING_NOISY),
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU)
                RECEIVER_NOT_EXPORTED else 0
        )
    }

    override fun onGetSession(controllerInfo: MediaSession.ControllerInfo): MediaLibrarySession = mediaSession

    fun requestAudioFocus(): Boolean {
        val result = audioManager.requestAudioFocus(audioFocusRequest)
        return result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED ||
                result == AudioManager.AUDIOFOCUS_REQUEST_DELAYED
    }

    fun abandonAudioFocus() {
        audioManager.abandonAudioFocusRequest(audioFocusRequest)
    }

    override fun onDestroy() {
        abandonAudioFocus()
        unregisterReceiver(noisyReceiver)
        mediaSession.release()
        player.release()
        super.onDestroy()
    }
}
