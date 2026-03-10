import 'package:flutter/material.dart';

export 'animation_timing.dart';

@immutable
class ThemeSeed {
  const ThemeSeed({
    required this.name,
    required this.color,
    required this.style,
  });

  final String name;
  final Color color;
  final ThemeSeedStyle style;
}

enum ThemeSeedStyle { expressive, neutral }

const uiPageHorizontalPadding = 24.0;
const uiGridMaxContentWidth = 1000.0;
const uiGridItemSlotWidth = 136.0;

const uiScrollProgressOffsetPx = 300.0;
const uiScrollProgressQuantizationSteps = 60;

const heroIconSize = 90.0;
const heroIconSpacing = 20.0;

const List<ThemeSeed> themeSeedOptions = [
  ThemeSeed(
    name: 'Salmon',
    color: Color(0xFFFF8B7B),
    style: ThemeSeedStyle.expressive,
  ),
  ThemeSeed(
    name: 'Gold',
    color: Color(0xFFFFD700),
    style: ThemeSeedStyle.expressive,
  ),
  ThemeSeed(
    name: 'Mint',
    color: Color(0xFF00FA9A),
    style: ThemeSeedStyle.expressive,
  ),
  ThemeSeed(
    name: 'Azure',
    color: Color(0xFF007FFF),
    style: ThemeSeedStyle.expressive,
  ),
  ThemeSeed(
    name: 'Slate',
    color: Color(0xFF708090),
    style: ThemeSeedStyle.neutral,
  ),
];
