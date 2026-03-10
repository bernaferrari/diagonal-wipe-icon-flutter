import 'dart:async' as async;
import 'dart:math' as math;

import 'package:diagonal_wipe_icon/diagonal_wipe_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../demo_catalog.dart';
import 'app_shared.dart';
import 'support/support.dart';

class IconPreviewDialog extends StatefulWidget {
  const IconPreviewDialog({
    required this.iconPair,
    required this.baseAnimationMultiplier,
    super.key,
  });

  final MaterialWipeIconPair iconPair;
  final double baseAnimationMultiplier;

  @override
  State<IconPreviewDialog> createState() => _IconPreviewDialogState();
}

class _IconPreviewDialogState extends State<IconPreviewDialog> {
  static const int _previewWipeInDurationMillis = 680;
  static const int _previewWipeOutDurationMillis = 980;

  bool _isWiped = false;
  bool _isPlaying = true;
  bool _previewSlowMode = false;
  bool _previewHovered = false;
  bool _pausedTapWiped = false;
  bool _hasHoveredWhilePaused = false;
  bool _isCopyFeedback = false;
  bool _copyHovered = false;
  int _loopToken = 0;
  async.Timer? _loopDelayTimer;
  async.Timer? _copyResetTimer;

  @override
  void initState() {
    super.initState();
    _previewSlowMode = widget.baseAnimationMultiplier > 1.0;
    _startLoop();
  }

  @override
  void didUpdateWidget(covariant IconPreviewDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.baseAnimationMultiplier != oldWidget.baseAnimationMultiplier &&
        _isPlaying) {
      _startLoop();
    }
  }

  @override
  void dispose() {
    _copyResetTimer?.cancel();
    _loopDelayTimer?.cancel();
    _loopToken++;
    super.dispose();
  }

  void _startLoop() {
    _loopToken++;
    final token = _loopToken;
    _loopDelayTimer?.cancel();
    _runLoop(token);
  }

  Future<void> _runLoop(int token) async {
    while (mounted && _isPlaying && token == _loopToken) {
      setState(() => _isWiped = true);
      final delay = autoPlayDelay(
        _previewWipeInDurationMillis,
        _previewAnimationMultiplier,
      );
      if (!await _awaitDelay(token, delay)) {
        return;
      }
      if (!mounted || token != _loopToken || !_isPlaying) break;

      setState(() => _isWiped = false);
      final reverseDelay = autoPlayDelay(
        _previewWipeOutDurationMillis,
        _previewAnimationMultiplier,
      );
      if (!await _awaitDelay(token, reverseDelay)) {
        return;
      }
      if (!mounted || token != _loopToken || !_isPlaying) break;
    }
  }

  Future<bool> _awaitDelay(int token, int delayMillis) {
    if (_loopDelayTimer != null && _loopDelayTimer!.isActive) {
      _loopDelayTimer!.cancel();
    }
    if (!mounted || token != _loopToken || !_isPlaying) {
      return Future.value(false);
    }

    final completer = async.Completer<void>();
    _loopDelayTimer = async.Timer(Duration(milliseconds: delayMillis), () {
      completer.complete();
    });
    return completer.future
        .then((_) => mounted && token == _loopToken && _isPlaying);
  }

  bool get _isSlow => _previewSlowMode || widget.baseAnimationMultiplier > 1.0;

  double get _previewAnimationMultiplier =>
      _isSlow ? slowAnimationMultiplier : 1.0;

  bool get _previewIsWiped => _isPlaying
      ? _isWiped
      : _hasHoveredWhilePaused
          ? _previewHovered
          : _pausedTapWiped;

  void _setPreviewHovered(bool hovered) {
    if (_previewHovered == hovered) return;
    setState(() {
      _previewHovered = hovered;
      if (!_isPlaying && hovered) {
        _hasHoveredWhilePaused = true;
      }
    });
  }

  void _onPreviewTap() {
    if (_isPlaying) {
      _loopToken++;
      setState(() {
        _isPlaying = false;
        _isWiped = false;
        _pausedTapWiped = false;
        _hasHoveredWhilePaused = false;
      });
    } else {
      setState(() {
        _isWiped = false;
        _hasHoveredWhilePaused = false;
        _pausedTapWiped = !_pausedTapWiped;
      });
    }
  }

  void _togglePlaying() {
    if (_isPlaying) {
      _loopToken++;
      setState(() {
        _isPlaying = false;
        _isWiped = false;
        _pausedTapWiped = false;
        _hasHoveredWhilePaused = false;
      });
    } else {
      _loopToken++;
      setState(() {
        _isPlaying = true;
        _pausedTapWiped = false;
        _hasHoveredWhilePaused = false;
        _isWiped = false;
      });
      _startLoop();
    }
  }

  void _toggleSlowMode() {
    setState(() => _previewSlowMode = !_previewSlowMode);
    if (_isPlaying) _startLoop();
  }

  Future<void> _copyCode(String snippet) async {
    await Clipboard.setData(ClipboardData(text: snippet));
    _copyResetTimer?.cancel();
    setState(() => _isCopyFeedback = true);
    _copyResetTimer = async.Timer(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      setState(() => _isCopyFeedback = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final snippet = buildDiagonalWipeUsageSnippet(widget.iconPair);
    final dialogMaxWidth = composeDialogMaxWidth(context);
    final contentMaxWidth = math.min(dialogMaxWidth, 620.0);
    final dialogMaxHeight = MediaQuery.sizeOf(context).height * 0.94;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogMaxWidth,
          maxHeight: dialogMaxHeight,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _previewControls(context),
                      const SizedBox(height: 16),
                      _codePane(context, snippet),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _previewControls(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.iconPair.label,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 24),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => _setPreviewHovered(true),
          onExit: (_) => _setPreviewHovered(false),
          child: GestureDetector(
            onTap: _onPreviewTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.5),
              ),
              alignment: Alignment.center,
              child: AnimatedDiagonalWipe.icon(
                isWiped: _previewIsWiped,
                baseIcon: fallbackIconData(widget.iconPair.enabledIcon),
                wipedIcon: fallbackIconData(widget.iconPair.disabledIcon),
                baseTint: Theme.of(context).colorScheme.primary,
                wipedTint: Theme.of(context).colorScheme.secondary,
                size: 120,
                animationStyle: AnimationStyle(
                  duration: Duration(
                    milliseconds: scaledDuration(
                      _previewWipeInDurationMillis,
                      _previewAnimationMultiplier,
                    ),
                  ),
                  reverseDuration: Duration(
                    milliseconds: scaledDuration(
                      _previewWipeOutDurationMillis,
                      _previewAnimationMultiplier,
                    ),
                  ),
                  curve: Curves.ease,
                  reverseCurve: Curves.ease,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PreviewDialogControl(
              label: _isPlaying ? 'Playing' : 'Paused',
              icon: _isPlaying ? Symbols.pause : Symbols.play_arrow,
              selected: _isPlaying,
              onPressed: _togglePlaying,
            ),
            const SizedBox(width: 12),
            _PreviewDialogControl(
              label: _previewSlowMode ? '0.5x' : '1x',
              icon: Symbols.speed,
              selected: _previewSlowMode,
              onPressed: _toggleSlowMode,
            ),
          ],
        ),
      ],
    );
  }

  Widget _codePane(BuildContext context, String snippet) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Code',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) {
                  if (_copyHovered) return;
                  setState(() => _copyHovered = true);
                },
                onExit: (_) {
                  if (!_copyHovered) return;
                  setState(() => _copyHovered = false);
                },
                child: GestureDetector(
                  onTap: () => _copyCode(snippet),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: (_isCopyFeedback || _copyHovered)
                          ? Theme.of(context).colorScheme.surface
                          : Colors.transparent,
                    ),
                    child: Icon(
                      _isCopyFeedback ? Symbols.check : Symbols.content_copy,
                      size: 20,
                      color: _isCopyFeedback
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.surface,
            ),
            constraints: const BoxConstraints(minHeight: 180, maxHeight: 320),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SyntaxHighlightedCode(
                code: snippet,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewDialogControl extends StatefulWidget {
  const _PreviewDialogControl({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  State<_PreviewDialogControl> createState() => _PreviewDialogControlState();
}

class _PreviewDialogControlState extends State<_PreviewDialogControl>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _pressed = false;
  late final AnimationController _scaleController = AnimationController(
    vsync: this,
    lowerBound: 0.95,
    upperBound: 1.0,
    value: 1,
  );

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  double get _scaleTarget => _pressed ? 0.95 : 1.0;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
    _animateScale();
  }

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
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
        : (_hovered ? colors.surfaceContainerHighest : colors.surface);
    final textColor =
        widget.selected ? colors.onPrimaryContainer : colors.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.label,
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, size: 20, color: textColor),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
