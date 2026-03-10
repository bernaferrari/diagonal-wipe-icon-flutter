/// Animation timing utilities for diagonal wipe animations.
///
/// These constants and functions control the timing of autoplay animations
/// and provide scaled duration calculations.
library;

import 'dart:math' as math;

/// Multiplier for slow animation mode (2.4x slower).
const double slowAnimationMultiplier = 2.4;

/// Delay in milliseconds before reversing an autoplay animation at normal speed.
const int autoPlayTurnaroundMillis = 180;

/// Delay in milliseconds before reversing an autoplay animation in slow mode.
const int autoPlaySlowTurnaroundMillis = 90;

/// Default duration for wipe-in animation in milliseconds.
const int wipeInDurationMillis = 530;

/// Default duration for wipe-out animation in milliseconds.
const int wipeOutDurationMillis = 800;

/// Scales a duration by the given multiplier.
///
/// The result is always at least 1 millisecond.
int scaledDuration(int durationMillis, double multiplier) {
  final scaled = (durationMillis * multiplier).round();
  return math.max(1, scaled);
}

/// Calculates the autoplay delay including the turnaround time.
///
/// Returns the scaled duration plus an appropriate turnaround delay
/// based on whether slow mode is active.
int autoPlayDelay(int durationMillis, double multiplier) {
  final turnaround = multiplier > 1.0
      ? autoPlaySlowTurnaroundMillis
      : autoPlayTurnaroundMillis;
  return scaledDuration(durationMillis, multiplier) + turnaround;
}
