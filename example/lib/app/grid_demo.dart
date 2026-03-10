import 'package:diagonal_wipe_icon/diagonal_wipe_icon.dart';
import 'package:flutter/material.dart';

import '../demo_catalog.dart';
import 'app_shared.dart';
import 'support/support.dart';

class DiagonalWipeIconGridDemo extends StatefulWidget {
  const DiagonalWipeIconGridDemo({
    required this.onIconTap,
    required this.onScrollProgressChanged,
    required this.animationMultiplier,
    required this.allIconsWiped,
    required this.isLooping,
    required this.accentColor,
    required this.gridHeader,
    this.heroSelectedIcon,
    required this.onHeroSelectedIconConsumed,
    required this.scrollController,
    super.key,
  });

  final IconTapCallback onIconTap;
  final ValueChanged<double> onScrollProgressChanged;
  final double animationMultiplier;
  final bool allIconsWiped;
  final bool isLooping;
  final Color accentColor;
  final Widget gridHeader;
  final MaterialWipeIconPair? heroSelectedIcon;
  final VoidCallback onHeroSelectedIconConsumed;
  final ScrollController scrollController;

  @override
  State<DiagonalWipeIconGridDemo> createState() =>
      _DiagonalWipeIconGridDemoState();
}

class _DiagonalWipeIconGridDemoState extends State<DiagonalWipeIconGridDemo> {
  final Map<int, List<List<List<MaterialWipeIconPair>>>> _rowsByColumns = {};
  final Map<int, int> _itemCountByColumns = {};

  List<List<List<MaterialWipeIconPair>>> _sectionRowsForColumns(int columns) {
    return _rowsByColumns.putIfAbsent(columns, () {
      final rowsBySection = <List<List<MaterialWipeIconPair>>>[];
      for (final section in iconSections) {
        final rows = <List<MaterialWipeIconPair>>[];
        for (var i = 0; i < section.icons.length; i += columns) {
          final end = (i + columns).clamp(0, section.icons.length);
          rows.add(section.icons.sublist(i, end));
        }
        rowsBySection.add(rows);
      }
      return rowsBySection;
    });
  }

  int _itemCountForColumns(int columns) {
    return _itemCountByColumns.putIfAbsent(columns, () {
      final sectionRows = _sectionRowsForColumns(columns);
      var itemCount = 1;
      for (final rows in sectionRows) {
        itemCount += 1;
        itemCount += rows.length;
        itemCount += 1;
      }
      return itemCount;
    });
  }

  @override
  void didUpdateWidget(covariant DiagonalWipeIconGridDemo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.heroSelectedIcon == null ||
        widget.heroSelectedIcon == oldWidget.heroSelectedIcon) {
      return;
    }

    final selectedPair = widget.heroSelectedIcon;
    if (selectedPair == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !context.mounted) return;
      widget.onIconTap(selectedPair);
      widget.onHeroSelectedIconConsumed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth > uiGridMaxContentWidth
            ? ((constraints.maxWidth - uiGridMaxContentWidth) / 2) +
                uiPageHorizontalPadding
            : uiPageHorizontalPadding;
        final contentWidth = (constraints.maxWidth - (horizontalPadding * 2))
            .clamp(uiGridItemSlotWidth, double.infinity);
        final columns =
            (contentWidth / uiGridItemSlotWidth).toInt().clamp(1, 20);
        final sectionRows = _sectionRowsForColumns(columns);
        final itemCount = _itemCountForColumns(columns);

        return ListView.separated(
          controller: widget.scrollController,
          padding: const EdgeInsets.only(top: 0, bottom: 48),
          itemCount: itemCount,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            var remaining = index;
            if (remaining == 0) {
              return Align(
                alignment: Alignment.topCenter,
                child: widget.gridHeader,
              );
            }
            remaining -= 1;

            for (var sectionIndex = 0;
                sectionIndex < iconSections.length;
                sectionIndex++) {
              final section = iconSections[sectionIndex];
              final rows = sectionRows[sectionIndex];

              if (remaining == 0) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: MaterialWipeIconSectionHeader(
                    section: section,
                    topPadding: sectionIndex == 0 ? 24 : 16,
                    bottomPadding: 16,
                  ),
                );
              }
              remaining -= 1;

              if (remaining < rows.length) {
                final row = rows[remaining];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: row
                        .map(
                          (pair) => DiagonalWipeIconGridItem(
                            key: ValueKey(pair.label),
                            iconPair: pair,
                            animationMultiplier: widget.animationMultiplier,
                            allIconsWiped: widget.allIconsWiped,
                            isLooping: widget.isLooping,
                            accentColor: widget.accentColor,
                            onOpen: () => widget.onIconTap(pair),
                          ),
                        )
                        .toList(),
                  ),
                );
              }
              remaining -= rows.length;

              if (remaining == 0) {
                return const SizedBox(height: 20);
              }
              remaining -= 1;
            }

            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}

class MaterialWipeIconSectionHeader extends StatelessWidget {
  const MaterialWipeIconSectionHeader({
    required this.section,
    this.topPadding = 16,
    this.bottomPadding = 16,
    super.key,
  });

  final MaterialWipeIconSection section;
  final double topPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: Text(
            section.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Text(
            section.subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}

class DiagonalWipeIconGridItem extends StatefulWidget {
  const DiagonalWipeIconGridItem({
    required this.iconPair,
    required this.animationMultiplier,
    required this.allIconsWiped,
    required this.isLooping,
    required this.accentColor,
    required this.onOpen,
    super.key,
  });

  final MaterialWipeIconPair iconPair;
  final double animationMultiplier;
  final bool allIconsWiped;
  final bool isLooping;
  final Color accentColor;
  final VoidCallback onOpen;

  @override
  State<DiagonalWipeIconGridItem> createState() =>
      _DiagonalWipeIconGridItemState();
}

class _DiagonalWipeIconGridItemState extends State<DiagonalWipeIconGridItem>
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

  @override
  void didUpdateWidget(covariant DiagonalWipeIconGridItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_targetScale != _scaleController.value) {
      _animateScale();
    }
  }

  double get _targetScale => _pressed ? 0.95 : 1.0;

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
      _targetScale,
      stiffness: 500,
      dampingRatio: 0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWiped = widget.isLooping ? widget.allIconsWiped : _hovered;
    final animationStyle = AnimationStyle(
      duration: Duration(
        milliseconds: (530 * widget.animationMultiplier).round(),
      ),
      reverseDuration: Duration(
        milliseconds: (800 * widget.animationMultiplier).round(),
      ),
      curve: Curves.ease,
      reverseCurve: Curves.ease,
    );
    final Color borderColor = _pressed
        ? widget.accentColor
        : _hovered
            ? widget.accentColor.withValues(alpha: 0.5)
            : Colors.transparent;
    final Color textColor = _pressed
        ? widget.accentColor
        : _hovered
            ? Theme.of(context).colorScheme.onSurface
            : Theme.of(context).colorScheme.onSurfaceVariant;
    final Color iconBgColor = _pressed
        ? widget.accentColor.withValues(alpha: 0.2)
        : _hovered
            ? widget.accentColor.withValues(alpha: 0.12)
            : Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.5);

    return Semantics(
      button: true,
      label: widget.iconPair.label,
      child: RepaintBoundary(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => _setHovered(true),
          onExit: (_) => _setHovered(false),
          child: GestureDetector(
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            onTap: widget.onOpen,
            child: AnimatedBuilder(
              animation: _scaleController,
              builder: (_, child) => Transform.scale(
                alignment: Alignment.center,
                scale: _scaleController.value,
                filterQuality: FilterQuality.high,
                child: child,
              ),
              child: SizedBox(
                width: uiGridItemSlotWidth,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.ease,
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: iconBgColor,
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: AnimatedDiagonalWipe.icon(
                                  isWiped: isWiped,
                                  baseIcon: fallbackIconData(
                                    widget.iconPair.enabledIcon,
                                  ),
                                  wipedIcon: fallbackIconData(
                                    widget.iconPair.disabledIcon,
                                  ),
                                  baseTint:
                                      Theme.of(context).colorScheme.primary,
                                  wipedTint:
                                      Theme.of(context).colorScheme.secondary,
                                  size: 44,
                                  animationStyle: animationStyle,
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: IgnorePointer(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.ease,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: borderColor,
                                      width: (_hovered || _pressed) ? 1.5 : 0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.iconPair.label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: textColor,
                              fontWeight:
                                  _hovered ? FontWeight.w600 : FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
