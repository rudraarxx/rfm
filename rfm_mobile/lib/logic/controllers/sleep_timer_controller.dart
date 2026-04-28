import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart'; // To access radioHandler

final sleepTimerControllerProvider = StateNotifierProvider<SleepTimerController, SleepTimerState>((ref) {
  return SleepTimerController();
});

class SleepTimerState {
  final int remainingSeconds;
  final bool isActive;

  SleepTimerState({this.remainingSeconds = 0, this.isActive = false});

  String get formattedTime {
    final minutes = (remainingSeconds / 60).floor();
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class SleepTimerController extends StateNotifier<SleepTimerState> {
  SleepTimerController() : super(SleepTimerState());

  Timer? _timer;

  void setTimer(int minutes) {
    cancelTimer();
    state = SleepTimerState(remainingSeconds: minutes * 60, isActive: true);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = SleepTimerState(
          remainingSeconds: state.remainingSeconds - 1,
          isActive: true,
        );
      } else {
        _onTimerFinished();
      }
    });
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
    state = SleepTimerState();
  }

  void _onTimerFinished() {
    _timer?.cancel();
    _timer = null;
    state = SleepTimerState();
    radioHandler.stop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
