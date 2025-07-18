import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class AnimatedCustomAppBar extends StatefulWidget {
  final Widget? background;
  final double maxHeight;
  final double minHeight;
  final Widget centerWidget;
  final Widget? profileIcon;
  final Widget? actionIcon;
  final VoidCallback? onTap;
  final ScrollController? scrollController;
  final List<Widget> slivers;
  final double fadingBackgroundHeight;
  final GestureTapCallback? leftWidgetPressed;
  final GestureTapCallback? rightWidgetPressed;
  final Color? widgetsRippleColor;
  final BorderRadius? fadingBackgroundRadius;
  final List<BoxShadow>? fadingBackgroundShadow;
  final double? scrollableContentTopRadius;

  const AnimatedCustomAppBar({
    super.key,
    this.background,
    required this.centerWidget,
    this.profileIcon,
    this.actionIcon,
    this.onTap,
    required this.slivers,
    this.maxHeight = 170,
    this.minHeight = 76,
    this.scrollController,
    this.fadingBackgroundHeight = 56,
    this.leftWidgetPressed,
    this.rightWidgetPressed,
    this.widgetsRippleColor,
    this.fadingBackgroundRadius,
    this.fadingBackgroundShadow,
    this.scrollableContentTopRadius,
  }) : assert(maxHeight > minHeight, 'maxHeight must be greater than minHeight'),
        assert(fadingBackgroundHeight >= 0, 'fadingBackgroundHeight must be non-negative');

  @override
  State<AnimatedCustomAppBar> createState() => _AnimatedCustomAppBarState();
}

class _AnimatedCustomAppBarState extends State<AnimatedCustomAppBar> with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _heightAnimation;

  double get t => _animationController.value;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    _heightAnimation = Tween<double>(
      begin: widget.maxHeight,
      end: widget.minHeight + 30,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.linear));

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOutBack));

    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final offset = _scrollController.offset.clamp(0, widget.maxHeight - widget.minHeight);
    _animationController.value = offset / (widget.maxHeight - widget.minHeight);
  }

  double getRadius() => (1 - t) * (widget.fadingBackgroundHeight - 16);

  double getOpacity() => (1 - t).clamp(0.0, 1.0);

  double calculateIconRadius() =>
      lerpDouble(4, 72, (widget.fadingBackgroundHeight - 56) / (200 - 56)) ?? 16;

  BoxDecoration circularBoxDecoration(Color color) => BoxDecoration(
    shape: BoxShape.circle,
    color: color,
    boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 4)],
  );

  EdgeInsets scaledPadding(double base, double factor) =>
      EdgeInsets.symmetric(horizontal: base - (factor * (1 - t)), vertical: 24);

  Widget buildIconButton({
    required VoidCallback? onTap,
    required Widget icon,
    required double padding,
    required Color bgColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(56),
        highlightColor: widget.widgetsRippleColor ?? Colors.green,
        child: Ink(
          decoration: circularBoxDecoration(bgColor),
          padding: EdgeInsets.all(padding),
          child: icon,
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (widget.scrollController == null) _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final radius = getRadius();
          final iconPadding = calculateIconRadius() + 10;

          return Stack(
            children: [
              if (widget.background != null)
                SizedBox(width: mediaSize.width, height: mediaSize.height, child: widget.background),

              // Scrollable content
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollUpdateNotification) _handleScroll();
                  return true;
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: SizedBox(height: widget.maxHeight + 40)),
                    SliverToBoxAdapter(
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(widget.scrollableContentTopRadius ?? radius),
                          ),
                        ),
                      ),
                    ),
                    ...widget.slivers,
                  ],
                ),
              ),

              // Fading white background
              Opacity(
                opacity: 1 - getOpacity(),
                child: Container(
                  height: widget.maxHeight / 1.3,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: widget.fadingBackgroundRadius ??
                        BorderRadius.vertical(bottom: Radius.circular(radius)),
                    boxShadow: widget.fadingBackgroundShadow ?? [],
                  ),
                ),
              ),

              // AppBar
              SafeArea(
                bottom: false,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Padding(
                    padding: scaledPadding(12, 8),
                    child: Row(
                      children: [
                        // Left Info Box
                        Expanded(
                          child: GestureDetector(
                            onTap: widget.onTap,
                            child: Container(
                              height: widget.fadingBackgroundHeight,
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(widget.fadingBackgroundHeight / 2),
                                color: Colors.white,
                                boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 4)],
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: buildIconButton(
                                      onTap: widget.leftWidgetPressed,
                                      icon: widget.profileIcon ??
                                          Icon(Icons.menu_outlined,
                                              size: 3 * sqrt(widget.fadingBackgroundHeight)),
                                      padding: iconPadding,
                                      bgColor: Colors.grey.shade200,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 1.0, end: t >= 0.88 ? 1.1 : 1),
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeInOut,
                                      builder: (context, scale, child) {
                                        return Transform.scale(
                                          scale: scale,
                                          alignment: Alignment.centerLeft,
                                          child: child,
                                        );
                                      },
                                      child: widget.centerWidget,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Right icon
                        buildIconButton(
                          onTap: widget.rightWidgetPressed,
                          icon: widget.actionIcon ??
                              Icon(Icons.notifications_none_outlined,
                                  size: 3 * sqrt(widget.fadingBackgroundHeight)),
                          padding: iconPadding + 2,
                          bgColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}






