import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

class VisualizerService {
  final _controller = BehaviorSubject<List<double>>.seeded(List.generate(30, (_) => 0.1));
  Timer? _timer;
  bool _isPlaying = false;
  double _volume = 1.0;

  Stream<List<double>> get spectrumStream => _controller.stream;

  void updateState({required bool isPlaying, double volume = 1.0}) {
    _isPlaying = isPlaying;
    _volume = volume;
    
    if (_isPlaying && _timer == null) {
      _startSimulation();
    } else if (!_isPlaying && _timer != null) {
      _stopSimulation();
    }
  }

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      final List<double> newValues = List.generate(30, (i) {
        // Base energy
        double energy = 0.2 + math.Random().nextDouble() * 0.8;
        
        // Add some "waves"
        final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
        energy *= (0.5 + 0.5 * math.sin(time * 10 + i * 0.2).abs());
        
        return energy * _volume;
      });
      _controller.add(newValues);
    });
  }

  void _stopSimulation() {
    _timer?.cancel();
    _timer = null;
    // Slowly decay to zero
    _controller.add(List.generate(30, (_) => 0.05));
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}

final visualizerServiceProvider = Provider((ref) => VisualizerService());

final spectrumProvider = StreamProvider<List<double>>((ref) {
  final service = ref.watch(visualizerServiceProvider);
  return service.spectrumStream;
});
