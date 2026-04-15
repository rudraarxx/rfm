package com.rfm.nagpurpulse.presentation.home.adapter

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.rfm.nagpurpulse.R
import com.rfm.nagpurpulse.presentation.util.VisualizerAnimator
import com.rfm.nagpurpulse.presentation.util.imageSource
import com.rfm.nagpurpulse.databinding.ItemStationBinding
import com.rfm.nagpurpulse.domain.model.Station

class StationAdapter(
    private val onStationClick: (Station) -> Unit,
    private val onFavoriteClick: (Station) -> Unit
) : ListAdapter<Station, StationAdapter.ViewHolder>(DiffCallback) {

    private var activeStationId: String? = null
    private var isPlaying: Boolean = false
    private var favoriteIds: Set<String> = emptySet()

    fun setActiveStationId(id: String?) {
        val oldId = activeStationId
        activeStationId = id
        currentList.forEachIndexed { index, station ->
            if (station.id == oldId || station.id == id) notifyItemChanged(index)
        }
    }

    fun setIsPlaying(playing: Boolean) {
        if (isPlaying != playing) {
            isPlaying = playing
            val activeIndex = currentList.indexOfFirst { it.id == activeStationId }
            if (activeIndex >= 0) notifyItemChanged(activeIndex)
        }
    }

    fun setFavoriteIds(ids: Set<String>) {
        favoriteIds = ids
        notifyItemRangeChanged(0, currentList.size)
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemStationBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return ViewHolder(binding)
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    override fun onViewRecycled(holder: ViewHolder) {
        super.onViewRecycled(holder)
        VisualizerAnimator.stopByRoot(holder.binding.visualizer.root)
    }

    inner class ViewHolder(val binding: ItemStationBinding) :
        RecyclerView.ViewHolder(binding.root) {

        fun bind(station: Station) {
            val isActive = station.id == activeStationId
            val showVisualizer = isActive && isPlaying
            val isFav = station.id in favoriteIds

            binding.tvStationName.text = station.name
            binding.tvStationTag.text = station.tags.firstOrNull() ?: ""

            Glide.with(binding.root.context)
                .load(station.imageSource(binding.root.context))
                .placeholder(R.drawable.ic_radio)
                .error(R.drawable.ic_radio)
                .into(binding.ivStationIcon)

            binding.visualizer.root.visibility = if (showVisualizer) View.VISIBLE else View.INVISIBLE
            binding.ivPlayOverlay.visibility = if (showVisualizer) View.INVISIBLE else View.VISIBLE
            if (showVisualizer) VisualizerAnimator.start(binding.visualizer)
            else VisualizerAnimator.stop(binding.visualizer)

            binding.ivFavorite.visibility = if (isFav) View.VISIBLE else View.GONE

            binding.root.isSelected = isActive
            binding.root.setOnClickListener { onStationClick(station) }
            binding.ivFavorite.setOnClickListener { onFavoriteClick(station) }
        }
    }

    private object DiffCallback : DiffUtil.ItemCallback<Station>() {
        override fun areItemsTheSame(oldItem: Station, newItem: Station) = oldItem.id == newItem.id
        override fun areContentsTheSame(oldItem: Station, newItem: Station) = oldItem == newItem
    }
}
