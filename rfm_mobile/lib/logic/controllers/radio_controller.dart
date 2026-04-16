import 'package:flutter/services.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/station.dart';
import '../../data/repositories/persistence_service.dart';
import '../../main.dart'; // To access radioHandler

class RadioState {
  final Station? currentStation;
  final bool isPlaying;
  final double volume;
  final List<Station> stations;
  final String visualizerStyle;

  RadioState({
    this.currentStation,
    this.isPlaying = false,
    this.volume = 1.0,
    this.stations = const [],
    this.visualizerStyle = 'classic',
  });

  RadioState copyWith({
    Station? currentStation,
    bool? isPlaying,
    double? volume,
    List<Station>? stations,
    String? visualizerStyle,
  }) {
    return RadioState(
      currentStation: currentStation ?? this.currentStation,
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
      stations: stations ?? this.stations,
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
    // Restore state
    final savedStation = await _persistence.getStation();
    final savedVolume = await _persistence.getVolume();
    final savedStyle = await _persistence.getVisualizerStyle();
    
    state = state.copyWith(
      currentStation: savedStation,
      volume: savedVolume,
      visualizerStyle: savedStyle,
    );

    // Listen to audio handler changes
    radioHandler.mediaItem.listen((item) {
      if (item != null && item.extras != null) {
        final station = Station.fromJson(item.extras!);
        state = state.copyWith(currentStation: station);
        _persistence.saveStation(station);
      }
    });

    radioHandler.playbackState.listen((playbackState) {
      state = state.copyWith(
        isPlaying: playbackState.playing,
      );
    });
  }

  Future<void> setStation(Station station) async {
    await radioHandler.playFromMediaId(station.changeuuid, station.toJson());
  }

  Future<void> togglePlay() async {
    if (state.isPlaying) {
      await radioHandler.pause();
    } else {
      rootBundle.load('assets/haptics/click.mp3').catchError((_){}); // Placeholder for pulse
      await radioHandler.play();
    }
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
