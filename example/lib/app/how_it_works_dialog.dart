import 'dart:math' as math;

import 'package:diagonal_wipe_icon/diagonal_wipe_icon.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../demo_catalog.dart';
import 'app_shared.dart';
import 'support/support.dart';

const _howItWorksDirectionOptions = [
  (
    direction: WipeDirection.topLeftToBottomRight,
    label: 'Top-left to bottom-right',
  ),
  (
    direction: WipeDirection.topRightToBottomLeft,
    label: 'Top-right to bottom-left',
  ),
  (
    direction: WipeDirection.bottomLeftToTopRight,
    label: 'Bottom-left to top-right',
  ),
  (
    direction: WipeDirection.bottomRightToTopLeft,
    label: 'Bottom-right to top-left',
  ),
  (direction: WipeDirection.topToBottom, label: 'Top to bottom'),
  (direction: WipeDirection.bottomToTop, label: 'Bottom to top'),
  (direction: WipeDirection.leftToRight, label: 'Left to right'),
  (direction: WipeDirection.rightToLeft, label: 'Right to left'),
];

final _howItWorksDirectionLabels = {
  for (final option in _howItWorksDirectionOptions)
    option.direction: option.label,
};

class HowItWorksDialog extends StatefulWidget {
  const HowItWorksDialog({
    required this.onDirectionChanged,
    required this.initialDirection,
    required this.pair,
    super.key,
  });

  final ValueChanged<WipeDirection> onDirectionChanged;
  final WipeDirection initialDirection;
  final MaterialWipeIconPair pair;

  @override
  State<HowItWorksDialog> createState() => _HowItWorksDialogState();
}

class _HowItWorksDialogState extends State<HowItWorksDialog> {
  static const _flowFrameHeight = 100.0;
  static const _flowSquareSize = 64.0;
  static const _howItWorksAnimationMultiplier = slowAnimationMultiplier;
  static const Curve _howItWorksWipeInCurve = Curves.ease;
  static const Curve _howItWorksWipeOutCurve = Curves.ease;

  late WipeDirection _direction = widget.initialDirection;

  int _durationForIn() {
    return scaledDuration(wipeInDurationMillis, _howItWorksAnimationMultiplier);
  }

  int _durationForOut() {
    return scaledDuration(
      wipeOutDurationMillis,
      _howItWorksAnimationMultiplier,
    );
  }

  Duration _cycleDuration() {
    return Duration(milliseconds: _durationForIn() + _durationForOut());
  }

  Animatable<double> _progressAnimatable() {
    return TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 0,
          end: 1,
        ).chain(CurveTween(curve: _howItWorksWipeInCurve)),
        weight: _durationForIn().toDouble(),
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1,
          end: 0,
        ).chain(CurveTween(curve: _howItWorksWipeOutCurve)),
        weight: _durationForOut().toDouble(),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final allowedColor = Theme.of(context).colorScheme.primary;
    final blockedColor = Theme.of(context).colorScheme.secondary;
    final dialogMaxWidth = composeDialogMaxWidth(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogMaxWidth,
          maxHeight: MediaQuery.sizeOf(context).height * 0.94,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: RepeatingAnimationBuilder<double>(
            duration: _cycleDuration(),
            animatable: _progressAnimatable(),
            builder: (context, progress, _) {
              final clampedProgress = progress.clamp(0.0, 1.0);
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How it works',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'SF Symbols has built-in symbol transitions. '
                    'Material Icons does not, so this gives you the same '
                    'kind of morph without hand-drawing a custom vector.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 20),
                  _howItWorksDirectionSelector(
                    direction: _direction,
                    onDirectionChange: (value) {
                      setState(() => _direction = value);
                      widget.onDirectionChanged(value);
                    },
                  ),
                  const SizedBox(height: 20),
                  _howItWorksFlow(
                    allowedColor,
                    blockedColor,
                    clampedProgress,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Use two icons and one animated mask. It is much '
                    'easier and faster than building and maintaining '
                    'custom vector paths by hand.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _howItWorksFlow(
    Color allowedColor,
    Color blockedColor,
    double progress,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _HowItWorksStep(
                    title: 'Base',
                    frameHeight: _flowFrameHeight,
                    child: _howItWorksSingleLayer(
                      baseIconName: widget.pair.enabledIcon,
                      wipedIconName: widget.pair.enabledIcon,
                      baseTint: allowedColor,
                      wipedTint: Colors.transparent,
                      direction: _direction,
                      progress: progress,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '+',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
                Expanded(
                  child: _HowItWorksStep(
                    title: 'Overlay',
                    frameHeight: _flowFrameHeight,
                    child: _howItWorksSingleLayer(
                      baseIconName: widget.pair.disabledIcon,
                      wipedIconName: widget.pair.disabledIcon,
                      baseTint: Colors.transparent,
                      wipedTint: blockedColor,
                      direction: _direction,
                      progress: progress,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '+',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
                Expanded(
                  child: _HowItWorksStep(
                    title: 'Mask',
                    frameHeight: _flowFrameHeight,
                    child: _howItWorksMaskLayer(
                      baseIconName: widget.pair.enabledIcon,
                      overlayIconName: widget.pair.disabledIcon,
                      baseColor: allowedColor,
                      overlayColor: blockedColor,
                      progress: progress,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '=',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: _HowItWorksStep(
              title: 'Result',
              frameHeight: _flowFrameHeight,
              child: _howItWorksSingleLayer(
                baseIconName: widget.pair.enabledIcon,
                wipedIconName: widget.pair.disabledIcon,
                baseTint: allowedColor,
                wipedTint: blockedColor,
                direction: _direction,
                progress: progress,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _howItWorksSingleLayer({
    required MaterialSymbolName baseIconName,
    required MaterialSymbolName wipedIconName,
    required Color baseTint,
    required Color wipedTint,
    required WipeDirection direction,
    required double progress,
    EdgeInsetsGeometry padding = const EdgeInsets.all(2),
  }) {
    return Padding(
      padding: padding,
      child: DiagonalWipeTransition(
        progress: AlwaysStoppedAnimation(progress),
        baseChild: materialSymbolIcon(
          symbolName: baseIconName,
          size: _flowSquareSize,
          color: baseTint,
        ),
        wipedChild: materialSymbolIcon(
          symbolName: wipedIconName,
          size: _flowSquareSize,
          color: wipedTint,
        ),
        size: _flowSquareSize,
        direction: direction,
      ),
    );
  }

  Widget _howItWorksMaskLayer({
    required MaterialSymbolName baseIconName,
    required MaterialSymbolName overlayIconName,
    required Color baseColor,
    required Color overlayColor,
    required double progress,
  }) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final rotation = clampedProgress * 180;
    return SizedBox(
      width: _flowSquareSize,
      height: _flowSquareSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (rotation < 90)
            _howItWorksRotatingIcon(
              iconName: baseIconName,
              color: baseColor,
              progress: clampedProgress,
              isBase: true,
            )
          else
            _howItWorksRotatingIcon(
              iconName: overlayIconName,
              color: overlayColor,
              progress: clampedProgress,
              isBase: false,
            ),
          if (clampedProgress >= 0.2 && clampedProgress <= 0.8)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _HowItWorksBoundaryPainterWrapper(
                    progress: clampedProgress,
                    direction: _direction,
                    color: Theme.of(context)
                        .colorScheme
                        .tertiary
                        .withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _howItWorksRotatingIcon({
    required MaterialSymbolName iconName,
    required Color color,
    required double progress,
    required bool isBase,
  }) {
    final rotation = progress * 180;
    final isFirstHalf = isBase && rotation < 90 || (!isBase && rotation > 90);
    final normalizedRotation = isBase ? rotation : rotation - 180;
    final alpha = isBase ? 1 - (rotation / 90) : (rotation - 90) / 90;
    if (!isFirstHalf) return const SizedBox.shrink();

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..rotateY(normalizedRotation * (math.pi / 180)),
      child: Opacity(
        opacity: alpha.clamp(0.0, 1.0),
        child: materialSymbolIcon(
          symbolName: iconName,
          size: _flowSquareSize,
          color: color,
        ),
      ),
    );
  }

  Widget _howItWorksDirectionSelector({
    required WipeDirection direction,
    required ValueChanged<WipeDirection> onDirectionChange,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _HowItWorksDirectionGrid(
            direction: direction,
            onDirectionChange: onDirectionChange,
          ),
          const SizedBox(height: 16),
          Text(
            _howItWorksDirectionLabels[direction] ?? 'Top-left to bottom-right',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorksDirectionGrid extends StatelessWidget {
  const _HowItWorksDirectionGrid({
    required this.direction,
    required this.onDirectionChange,
  });

  final WipeDirection direction;
  final ValueChanged<WipeDirection> onDirectionChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HowItWorksDirectionButton(
              icon: Symbols.north_west,
              description: 'Bottom-right to top-left',
              selected: direction == WipeDirection.bottomRightToTopLeft,
              onPressed: () =>
                  onDirectionChange(WipeDirection.bottomRightToTopLeft),
            ),
            const SizedBox(width: 4),
            _HowItWorksDirectionButton(
              icon: Symbols.keyboard_arrow_up,
              description: 'Bottom to top',
              selected: direction == WipeDirection.bottomToTop,
              onPressed: () => onDirectionChange(WipeDirection.bottomToTop),
            ),
            const SizedBox(width: 4),
            _HowItWorksDirectionButton(
              icon: Symbols.north_east,
              description: 'Bottom-left to top-right',
              selected: direction == WipeDirection.bottomLeftToTopRight,
              onPressed: () =>
                  onDirectionChange(WipeDirection.bottomLeftToTopRight),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HowItWorksDirectionButton(
              icon: Symbols.keyboard_arrow_left,
              description: 'Right to left',
              selected: direction == WipeDirection.rightToLeft,
              onPressed: () => onDirectionChange(WipeDirection.rightToLeft),
            ),
            const SizedBox(width: 4),
            const SizedBox(width: 44, height: 44),
            _HowItWorksDirectionButton(
              icon: Symbols.keyboard_arrow_right,
              description: 'Left to right',
              selected: direction == WipeDirection.leftToRight,
              onPressed: () => onDirectionChange(WipeDirection.leftToRight),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HowItWorksDirectionButton(
              icon: Symbols.south_west,
              description: 'Top-right to bottom-left',
              selected: direction == WipeDirection.topRightToBottomLeft,
              onPressed: () =>
                  onDirectionChange(WipeDirection.topRightToBottomLeft),
            ),
            const SizedBox(width: 4),
            _HowItWorksDirectionButton(
              icon: Symbols.keyboard_arrow_down,
              description: 'Top to bottom',
              selected: direction == WipeDirection.topToBottom,
              onPressed: () => onDirectionChange(WipeDirection.topToBottom),
            ),
            const SizedBox(width: 4),
            _HowItWorksDirectionButton(
              icon: Symbols.south_east,
              description: 'Top-left to bottom-right',
              selected: direction == WipeDirection.topLeftToBottomRight,
              onPressed: () =>
                  onDirectionChange(WipeDirection.topLeftToBottomRight),
            ),
          ],
        ),
      ],
    );
  }
}

class _HowItWorksDirectionButton extends StatefulWidget {
  const _HowItWorksDirectionButton({
    required this.icon,
    required this.description,
    required this.selected,
    required this.onPressed,
  });

  final IconData icon;
  final String description;
  final bool selected;
  final VoidCallback onPressed;

  @override
  State<_HowItWorksDirectionButton> createState() =>
      _HowItWorksDirectionButtonState();
}

class _HowItWorksDirectionButtonState extends State<_HowItWorksDirectionButton>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _pressed = false;
  late final AnimationController _scaleController = AnimationController(
    vsync: this,
    lowerBound: 0.92,
    upperBound: 1.08,
    value: 1,
  );

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  double get _scaleTarget => _pressed ? 0.92 : (_hovered ? 1.08 : 1);

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
    _animateScale();
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
    _animateScale();
  }

  void _animateScale() {
    animateScaleWithSpring(
      _scaleController,
      _scaleTarget,
      stiffness: 500,
      dampingRatio: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = widget.selected
        ? colors.primaryContainer
        : colors.surfaceContainerHighest.withValues(alpha: 0.3);
    final iconColor =
        widget.selected ? colors.onPrimaryContainer : colors.onSurfaceVariant;
    return Semantics(
      selected: widget.selected,
      button: true,
      label: widget.description,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onPressed,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => _setHovered(true),
          onExit: (_) => _setHovered(false),
          child: AnimatedBuilder(
            animation: _scaleController,
            builder: (_, child) => Transform.scale(
              alignment: Alignment.center,
              scale: _scaleController.value,
              child: child,
            ),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.icon,
                size: 24,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  const _HowItWorksStep({
    required this.title,
    required this.frameHeight,
    required this.child,
  });

  final String title;
  final double frameHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: frameHeight,
          width: double.infinity,
          child: Center(child: child),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium,
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      ],
    );
  }
}

class _HowItWorksBoundaryPainterWrapper extends CustomPainter {
  _HowItWorksBoundaryPainterWrapper({
    required this.progress,
    required this.direction,
    required this.color,
  });

  final double progress;
  final WipeDirection direction;
  final Color color;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final line = buildWipeBoundaryLine(
      width: canvasSize.width,
      height: canvasSize.height,
      progress: progress,
      direction: direction,
    );
    if (line == null) return;

    canvas.drawLine(
      line.start,
      line.end,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(
    covariant _HowItWorksBoundaryPainterWrapper oldDelegate,
  ) {
    return oldDelegate.progress != progress ||
        oldDelegate.direction != direction ||
        oldDelegate.color != color;
  }
}
