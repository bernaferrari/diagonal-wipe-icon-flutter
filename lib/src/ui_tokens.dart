import 'package:flutter/material.dart';

@immutable
class ThemeSeed {
  const ThemeSeed({
    required this.name,
    required this.color,
    required this.expressive,
  });

  final String name;
  final Color color;
  final bool expressive;
}

const uiPageHorizontalPadding = 24.0;
const uiGridMaxContentWidth = 1000.0;
const uiGridItemSlotWidth = 136.0;

const uiScrollProgressOffsetPx = 300.0;
const uiScrollProgressQuantizationSteps = 60;

const heroIconSize = 90.0;
const heroIconSpacing = 20.0;

const double autoPlayTurnaroundMillis = 180;
const double autoPlaySlowTurnaroundMillis = 90;
const double slowAnimationMultiplier = 2.4;

const int wipeInDurationMillis = 530;
const int wipeOutDurationMillis = 800;

const List<ThemeSeed> themeSeedOptions = [
  ThemeSeed(name: 'Salmon', color: Color(0xFFFF8B7B), expressive: true),
  ThemeSeed(name: 'Gold', color: Color(0xFFFFD700), expressive: true),
  ThemeSeed(name: 'Mint', color: Color(0xFF00FA9A), expressive: true),
  ThemeSeed(name: 'Azure', color: Color(0xFF007FFF), expressive: true),
  ThemeSeed(name: 'Slate', color: Color(0xFF708090), expressive: false),
];

int scaledDuration(int durationMillis, double multiplier) {
  final scaled = (durationMillis * multiplier).round();
  return scaled < 1 ? 1 : scaled;
}

int autoPlayDelay(int durationMillis, double multiplier) {
  final turnaround = multiplier > 1
      ? autoPlaySlowTurnaroundMillis
      : autoPlayTurnaroundMillis;
  return scaledDuration(durationMillis, multiplier) + turnaround.toInt();
}
