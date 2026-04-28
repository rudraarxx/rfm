import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/station.dart';
import '../../logic/controllers/radio_controller.dart';

final recordingControllerProvider = StateNotifierProvider<RecordingController, RecordingState>((ref) {
  return RecordingController(ref);
});

class RecordingState {
  final bool isRecording;
  final List<TapeRecord> tapes;
  final Duration duration;

  RecordingState({
    this.isRecording = false,
    this.tapes = const [],
    this.duration = Duration.zero,
  });

  RecordingState copyWith({
    bool? isRecording,
    List<TapeRecord>? tapes,
    Duration? duration,
  }) {
    return RecordingState(
      isRecording: isRecording ?? this.isRecording,
      tapes: tapes ?? this.tapes,
      duration: duration ?? this.duration,
    );
  }
}

class TapeRecord {
  final String id;
  final String stationName;
  final String filePath;
  final DateTime timestamp;
  final Duration duration;

  TapeRecord({
    required this.id,
    required this.stationName,
    required this.filePath,
    required this.timestamp,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'stationName': stationName,
    'filePath': filePath,
    'timestamp': timestamp.toIso8601String(),
    'duration': duration.inSeconds,
  };

  factory TapeRecord.fromJson(Map<String, dynamic> json) => TapeRecord(
    id: json['id'],
    stationName: json['stationName'],
    filePath: json['filePath'],
    timestamp: DateTime.parse(json['timestamp']),
    duration: Duration(seconds: json['duration']),
  );
}

class RecordingController extends StateNotifier<RecordingState> {
  final Ref _ref;
  RecordingController(this._ref) : super(RecordingState()) {
    _loadTapes();
  }

  http.Client? _client;
  File? _currentFile;
  IOSink? _sink;
  Timer? _durationTimer;
  DateTime? _startTime;

  static const String _storageKey = 'rfm_tapes';

  Future<void> _loadTapes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encoded = prefs.getString(_storageKey);
    if (encoded != null) {
      final List<dynamic> decoded = jsonDecode(encoded);
      state = state.copyWith(tapes: decoded.map((item) => TapeRecord.fromJson(item)).toList());
    }
  }

  Future<void> startRecording() async {
    final radioState = _ref.read(radioControllerProvider);
    final station = radioState.currentStation;
    if (station == null || state.isRecording) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final String id = DateTime.now().millisecondsSinceEpoch.toString();
      final String path = '${dir.path}/tape_$id.aac';
      _currentFile = File(path);
      _sink = _currentFile!.openWrite();

      _client = http.Client();
      final request = http.Request('GET', Uri.parse(station.url));
      final response = await _client!.send(request);

      state = state.copyWith(isRecording: true, duration: Duration.zero);
      _startTime = DateTime.now();
      
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        state = state.copyWith(duration: DateTime.now().difference(_startTime!));
      });

      response.stream.listen(
        (chunk) {
          _sink?.add(chunk);
        },
        onDone: () => stopRecording(),
        onError: (e) => stopRecording(),
        cancelOnError: true,
      );
    } catch (e) {
      print("Recording Error: $e");
      stopRecording();
    }
  }

  Future<void> stopRecording() async {
    if (!state.isRecording) return;

    _durationTimer?.cancel();
    _client?.close();
    await _sink?.close();

    final radioState = _ref.read(radioControllerProvider);
    final station = radioState.currentStation;

    if (_currentFile != null && await _currentFile!.exists()) {
      final newTape = TapeRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        stationName: station?.name ?? "Unknown Signal",
        filePath: _currentFile!.path,
        timestamp: DateTime.now(),
        duration: state.duration,
      );

      final updatedTapes = [newTape, ...state.tapes];
      state = state.copyWith(isRecording: false, tapes: updatedTapes, duration: Duration.zero);
      _saveTapes(updatedTapes);
    } else {
      state = state.copyWith(isRecording: false, duration: Duration.zero);
    }
  }

  Future<void> _saveTapes(List<TapeRecord> tapes) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(tapes.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> deleteTape(TapeRecord tape) async {
    final file = File(tape.filePath);
    if (await file.exists()) await file.delete();
    
    final updatedTapes = state.tapes.where((t) => t.id != tape.id).toList();
    state = state.copyWith(tapes: updatedTapes);
    _saveTapes(updatedTapes);
  }
}
