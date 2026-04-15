package com.rfm.nagpurpulse.auto

import android.content.ComponentName
import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import androidx.car.app.model.Action
import androidx.car.app.model.CarIcon
import androidx.car.app.model.GridItem
import androidx.car.app.model.GridTemplate
import androidx.car.app.model.ItemList
import androidx.car.app.model.Template
import androidx.core.graphics.drawable.IconCompat
import androidx.media3.common.MediaItem
import androidx.media3.common.MediaMetadata
import androidx.media3.session.MediaController
import androidx.media3.session.SessionToken
import com.google.common.util.concurrent.MoreExecutors
import com.rfm.nagpurpulse.R
import com.rfm.nagpurpulse.data.repository.StationRepositoryImpl
import com.rfm.nagpurpulse.data.service.RadioPlaybackService
import com.rfm.nagpurpulse.domain.model.Station

class RadioCarScreen(carContext: CarContext) : Screen(carContext) {

    private val stations: List<Station> = StationRepositoryImpl.FALLBACK_STATIONS
    private var currentStationId: String? = null
    private var mediaController: MediaController? = null

    init {
        val token = SessionToken(
            carContext,
            ComponentName(carContext, RadioPlaybackService::class.java)
        )
        val future = MediaController.Builder(carContext, token).buildAsync()
        future.addListener({
            mediaController = future.get()
        }, MoreExecutors.directExecutor())

        lifecycle.addObserver(object : DefaultLifecycleObserver {
            override fun onDestroy(owner: LifecycleOwner) {
                mediaController?.release()
            }
        })
    }

    override fun onGetTemplate(): Template {
        val listBuilder = ItemList.Builder()

        stations.forEach { station ->
            val isActive = station.id == currentStationId
            val icon = CarIcon.Builder(
                IconCompat.createWithResource(carContext, R.drawable.ic_radio)
            ).build()

            listBuilder.addItem(
                GridItem.Builder()
                    .setTitle(station.name)
                    .setText(if (isActive) "▶ Playing" else station.tags.firstOrNull() ?: "")
                    .setImage(icon)
                    .setOnClickListener { onStationSelected(station) }
                    .build()
            )
        }

        return GridTemplate.Builder()
            .setTitle(carContext.getString(R.string.app_name))
            .setHeaderAction(Action.APP_ICON)
            .setSingleList(listBuilder.build())
            .build()
    }

    private fun onStationSelected(station: Station) {
        currentStationId = station.id
        val controller = mediaController
        if (controller != null) {
            val mediaItem = MediaItem.Builder()
                .setMediaId(station.id)
                .setUri(station.streamUrl)
                .setMediaMetadata(
                    MediaMetadata.Builder()
                        .setTitle(station.name)
                        .setArtist(station.tags.firstOrNull() ?: "")
                        .build()
                )
                .build()
            controller.setMediaItem(mediaItem)
            controller.prepare()
            controller.play()
        }
        invalidate()
    }


}
