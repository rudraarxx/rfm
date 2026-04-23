import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/radio_controller.dart';

class SleepTimerNotifier extends StateNotifier<Duration?> {
  final Ref _ref;
  Timer? _ticker;

  SleepTimerNotifier(this._ref) : super(null);

  void set(Duration duration) {
    _ticker?.cancel();
    state = duration;
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      final current = state;
      if (current == null || current.inSeconds <= 0) {
        t.cancel();
        state = null;
        final radioState = _ref.read(radioControllerProvider);
        if (radioState.isPlaying) {
          _ref.read(radioControllerProvider.notifier).pause();
        }
      } else {
        state = current - const Duration(seconds: 1);
      }
    });
  }

  void cancel() {
    _ticker?.cancel();
    state = null;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final sleepTimerProvider = StateNotifierProvider<SleepTimerNotifier, Duration?>(
  (ref) => SleepTimerNotifier(ref),
);
