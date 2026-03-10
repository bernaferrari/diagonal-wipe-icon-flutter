import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'support/support.dart';
import 'app_shared.dart';

class BottomToolbar extends StatelessWidget {
  const BottomToolbar({
    required this.themeSeedOptions,
    required this.selectedSeedIndex,
    required this.onSeedSelected,
    required this.isSlowMode,
    required this.onToggleSlowMode,
    required this.isLooping,
    required this.onToggleLoop,
    super.key,
  });

  final List<ThemeSeed> themeSeedOptions;
  final int selectedSeedIndex;
  final ValueChanged<int> onSeedSelected;
  final bool isSlowMode;
  final VoidCallback onToggleSlowMode;
  final bool isLooping;
  final ValueChanged<bool> onToggleLoop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool showSeedDivider = constraints.maxWidth >= 560;
        final toolbarTheme = Theme.of(context).colorScheme;
        final toolbarMaxWidth = (constraints.maxWidth - 32).clamp(0.0, 1180.0);

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: toolbarMaxWidth),
            child: Material(
              color: toolbarTheme.surface,
              elevation: 4,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var index = 0;
                                index < themeSeedOptions.length;
                                index++)
                              _ThemeColorSwatch(
                                seed: themeSeedOptions[index],
                                selected: selectedSeedIndex == index,
                                onTap: () => onSeedSelected(index),
                              ),
                            if (showSeedDivider) ...[
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 1,
                                height: 24,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: toolbarTheme.outlineVariant
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      key: const ValueKey('toolbar-speed-toggle'),
                      onPressed: onToggleSlowMode,
                      style: TextButton.styleFrom(
                        foregroundColor: isSlowMode
                            ? toolbarTheme.primary
                            : toolbarTheme.onSurfaceVariant,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Symbols.speed, size: 17),
                          const SizedBox(width: 6),
                          Text(
                            isSlowMode ? '0.5x' : '1x',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  fontWeight: isSlowMode
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      key: const ValueKey('toolbar-loop-toggle'),
                      onPressed: () => onToggleLoop(!isLooping),
                      style: FilledButton.styleFrom(
                        backgroundColor: isLooping
                            ? toolbarTheme.primaryContainer
                            : toolbarTheme.secondaryContainer
                                .withValues(alpha: 0.78),
                        foregroundColor: isLooping
                            ? toolbarTheme.onPrimaryContainer
                            : toolbarTheme.onSecondaryContainer,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isLooping ? Symbols.stop : Symbols.play_arrow,
                            size: 17,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isLooping ? 'Stop' : 'Loop',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  fontWeight: isLooping
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ThemeColorSwatch extends StatefulWidget {
  const _ThemeColorSwatch({
    required this.seed,
    required this.selected,
    required this.onTap,
  });

  final ThemeSeed seed;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_ThemeColorSwatch> createState() => _ThemeColorSwatchState();
}

class _ThemeColorSwatchState extends State<_ThemeColorSwatch>
    with TickerProviderStateMixin {
  bool _hovered = false;
  bool _pressed = false;
  late final AnimationController _scaleController = AnimationController(
    vsync: this,
    lowerBound: 0.93,
    upperBound: 1.04,
    value: 1,
  );
  late final AnimationController _selectionController = AnimationController(
    vsync: this,
    lowerBound: 0,
    upperBound: 1,
    value: widget.selected ? 1 : 0,
  );

  @override
  void dispose() {
    _scaleController.dispose();
    _selectionController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ThemeColorSwatch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      _animateSelection();
    }
  }

  double get _pressScaleTarget => _pressed ? 0.93 : (_hovered ? 1.04 : 1);

  double get _selectionTarget => widget.selected ? 1 : 0;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
    _animatePressScale();
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
    _animatePressScale();
  }

  void _animatePressScale() {
    animateScaleWithSpring(
      _scaleController,
      _pressScaleTarget,
      stiffness: 700,
      dampingRatio: 0.6,
    );
  }

  void _animateSelection() {
    animateScaleWithSpring(
      _selectionController,
      _selectionTarget,
      stiffness: 520,
      dampingRatio: 0.7,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showSelected = widget.selected;
    final Color swatchColor = widget.seed.color;
    final bool highContrastText = (0.2126 * swatchColor.r +
            0.7152 * swatchColor.g +
            0.0722 * swatchColor.b) >
        0.5;
    final double selectionProgress = _selectionController.value.clamp(0.0, 1.0);
    final double cornerRadius = 8 + (8 * selectionProgress);
    const double glowDiameter = 54;
    final double orbScale = 0.84 + (0.16 * selectionProgress);
    const double orbSize = 32;
    final double rotation = 8 * selectionProgress;
    final double checkOpacity = selectionProgress;
    final double glowOpacity = selectionProgress;
    final Color checkColor =
        highContrastText ? Colors.black.withValues(alpha: 0.75) : Colors.white;

    return Semantics(
      button: true,
      selected: showSelected,
      label: '${widget.seed.name} theme',
      onTapHint: showSelected
          ? 'Current theme selection'
          : 'Select ${widget.seed.name} theme',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: GestureDetector(
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _scaleController,
            builder: (_, child) => Transform.scale(
              alignment: Alignment.center,
              scale: _scaleController.value,
              child: child,
            ),
            child: AnimatedBuilder(
              animation: _selectionController,
              builder: (_, child) => SizedBox(
                width: 38,
                height: 38,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: glowOpacity,
                      child: Container(
                        width: glowDiameter,
                        height: glowDiameter,
                        decoration: BoxDecoration(
                          color: widget.seed.color.withValues(alpha: 0.38),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Transform.scale(
                      alignment: Alignment.center,
                      scaleX: orbScale,
                      scaleY: orbScale,
                      child: Transform.rotate(
                        angle: rotation * (math.pi / 180),
                        child: Container(
                          width: orbSize,
                          height: orbSize,
                          decoration: BoxDecoration(
                            color: widget.seed.color,
                            borderRadius: BorderRadius.circular(cornerRadius),
                          ),
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(cornerRadius),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0x38FFFFFF),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              Center(
                                child: Transform.rotate(
                                  angle: -rotation * (math.pi / 180),
                                  child: Opacity(
                                    opacity: checkOpacity,
                                    child: Icon(
                                      Symbols.check,
                                      size: 16,
                                      color: checkColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              child: const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}
