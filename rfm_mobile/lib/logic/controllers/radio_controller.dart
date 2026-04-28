import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/station.dart';
import '../../data/repositories/persistence_service.dart';
import '../../main.dart'; // To access radioHandler
import '../audio/visualizer_service.dart';

class RadioState {
  final Station? currentStation;
  final bool isPlaying;
  final double volume;
  final List<Station> stations;
  final String visualizerStyle;
  final int visualizerColor;
  final double visualizerOpacity;

  RadioState({
    this.currentStation,
    this.isPlaying = false,
    this.volume = 1.0,
    this.stations = const [],
    this.visualizerStyle = 'classic',
    this.visualizerColor = 0xFFD4AF37, // Brass
    this.visualizerOpacity = 1.0,
  });

  RadioState copyWith({
    Station? currentStation,
    bool? isPlaying,
    double? volume,
    List<Station>? stations,
    String? visualizerStyle,
    int? visualizerColor,
    double? visualizerOpacity,
  }) {
    return RadioState(
      currentStation: currentStation ?? this.currentStation,
      isPlaying: isPlaying ?? this.isPlaying,
      volume: volume ?? this.volume,
      stations: stations ?? this.stations,
      visualizerStyle: visualizerStyle ?? this.visualizerStyle,
      visualizerColor: visualizerColor ?? this.visualizerColor,
      visualizerOpacity: visualizerOpacity ?? this.visualizerOpacity,
    );
  }
}


class RadioController extends StateNotifier<RadioState> {
  final PersistenceService _persistence = PersistenceService();
  final VisualizerService _visualizer;
  
  RadioController(this._visualizer) : super(RadioState()) {
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

    _visualizer.updateState(isPlaying: state.isPlaying, volume: state.volume);

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
      _visualizer.updateState(isPlaying: state.isPlaying, volume: state.volume);
    });
  }

  Future<void> setStation(Station station) async {
    try {
      await radioHandler.playFromMediaId(station.changeuuid, station.toJson());
    } catch (e) {
      print("RadioController Error: $e");
    }
  }

  Future<void> togglePlay() async {
    if (state.isPlaying) {
      await radioHandler.pause();
    } else {
      await radioHandler.play();
    }
  }

  Future<void> setVolume(double volume) async {
    state = state.copyWith(volume: volume);
    _visualizer.updateState(isPlaying: state.isPlaying, volume: state.volume);
    await _persistence.saveVolume(volume);
  }

  Future<void> setVisualizerStyle(String style) async {
    state = state.copyWith(visualizerStyle: style);
    await _persistence.saveVisualizerStyle(style);
  }

  void setVisualizerColor(int color) {
    state = state.copyWith(visualizerColor: color);
  }

  void setVisualizerOpacity(double opacity) {
    state = state.copyWith(visualizerOpacity: opacity);
  }
}

final radioControllerProvider = StateNotifierProvider<RadioController, RadioState>((ref) {
  final visualizer = ref.watch(visualizerServiceProvider);
  return RadioController(visualizer);
});
