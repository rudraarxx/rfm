import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../../data/models/station.dart';

class RadioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  RadioHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> skipToNext() async {
    // This logic should ideally be triggered from the controller
    // but we can add a broadcast signal or simpler logic here.
  }

  @override
  Future<void> skipToPrevious() async {
    // Same for prev
  }

  @override
  Future<void> playFromMediaId(String mediaId, [Map<String, dynamic>? extras]) async {
    if (extras == null) return;
    
    final station = Station.fromJson(extras);
    final mediaItem = MediaItem(
      id: station.changeuuid,
      album: "RFM Analog Player",
      title: station.name,
      artist: station.tags ?? "Maharashtra",
      artUri: station.favicon != null ? Uri.parse(station.favicon!) : null,
      extras: station.toJson(),
    );

    this.mediaItem.add(mediaItem);

    try {
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(station.urlResolved)),
      );
      play();
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
