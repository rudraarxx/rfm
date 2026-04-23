import 'package:flutter/services.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/station.dart';
import '../../data/repositories/persistence_service.dart';
import '../../main.dart'; // To access radioHandler
import '../audio/radio_handler.dart';

class RadioState {
  final Station? currentStation;
  final bool isPlaying;
  final bool isBuffering;
  final double volume;
  final List<Station> queue;
  final int queueIndex;
  final String visualizerStyle;

  RadioState({
    this.currentStation,
    this.isPlaying = false,
    this.isBuffering = false,
    this.volume = 1.0,
    this.queue = const [],
    this.queueIndex = -1,
    this.visualizerStyle = 'classic',
  });

  bool get hasPrevious => queueIndex > 0;
  bool get hasNext => queue.isNotEmpty && queueIndex < queue.length - 1;

  RadioState copyWith({
    Station? currentStation,
    bool? isPlaying,
    bool? isBuffering,
    double? volume,
    List<Station>? queue,
    int? queueIndex,
    String? visualizerStyle,
  }) {
    return RadioState(
      currentStation: currentStation ?? this.currentStation,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      volume: volume ?? this.volume,
      queue: queue ?? this.queue,
      queueIndex: queueIndex ?? this.queueIndex,
      visualizerStyle: visualizerStyle ?? this.visualizerStyle,
    );
  }
}

class RadioController extends StateNotifier<RadioState> {
  final PersistenceService _persistence = PersistenceService();
  
  RadioController() : super(RadioState()) {
    _init();
  }

  Future<void> _init() async {
    final savedStation = await _persistence.getStation();
    final savedVolume = await _persistence.getVolume();
    final savedStyle = await _persistence.getVisualizerStyle();

    state = state.copyWith(
      currentStation: savedStation,
      volume: savedVolume,
      visualizerStyle: savedStyle,
    );

    // Wire lock screen skip buttons → controller
    final handler = radioHandler as RadioHandler;
    handler.onSkipNext = () => skipToNext();
    handler.onSkipPrevious = () => skipToPrevious();

    radioHandler.mediaItem.listen((item) {
      if (item != null && item.extras != null) {
        final station = Station.fromJson(item.extras!);
        state = state.copyWith(currentStation: station);
        _persistence.saveStation(station);
      }
    });

    radioHandler.playbackState.listen((pbState) {
      final isBuffering = pbState.processingState == AudioProcessingState.loading ||
          pbState.processingState == AudioProcessingState.buffering;
      state = state.copyWith(
        isPlaying: pbState.playing && !isBuffering,
        isBuffering: isBuffering,
      );
    });
  }

  Future<void> setStation(Station station, {List<Station>? queue}) async {
    if (queue != null && queue.isNotEmpty) {
      final index = queue.indexWhere((s) => s.changeuuid == station.changeuuid);
      state = state.copyWith(queue: queue, queueIndex: index >= 0 ? index : 0);
    }
    await radioHandler.playFromMediaId(station.changeuuid, station.toJson());
  }

  Future<void> skipToNext() async {
    if (!state.hasNext) return;
    final next = state.queue[state.queueIndex + 1];
    state = state.copyWith(queueIndex: state.queueIndex + 1);
    await radioHandler.playFromMediaId(next.changeuuid, next.toJson());
  }

  Future<void> skipToPrevious() async {
    if (!state.hasPrevious) return;
    final prev = state.queue[state.queueIndex - 1];
    state = state.copyWith(queueIndex: state.queueIndex - 1);
    await radioHandler.playFromMediaId(prev.changeuuid, prev.toJson());
  }

  Future<void> togglePlay() async {
    if (state.isPlaying) {
      await radioHandler.pause();
    } else {
      await radioHandler.play();
    }
  }

  Future<void> pause() async {
    await radioHandler.pause();
  }

  Future<void> setVolume(double volume) async {
    state = state.copyWith(volume: volume);
    await _persistence.saveVolume(volume);
  }

  Future<void> setVisualizerStyle(String style) async {
    state = state.copyWith(visualizerStyle: style);
    await _persistence.saveVisualizerStyle(style);
  }
}

final radioControllerProvider = StateNotifierProvider<RadioController, RadioState>((ref) {
  return RadioController();
});
