import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

/// A customizable animated AppBar widget that reacts to scroll,
/// shows a background image, and supports pull-to-refresh.
class AnimatedCustomAppBar extends StatefulWidget {
  // Optional background image displayed behind the app bar
  final Widget? backgroundImage;

  // Maximum height when app bar is fully expanded
  final double maxHeight;

  // Minimum height when app bar is collapsed
  final double minHeight;

  // Widget shown in the center (e.g., search bar or title)
  final Widget centerWidget;

  // Optional widget for the left-side icon (e.g., profile or menu)
  final Widget? profileIcon;

  // Optional widget for the right-side icon (e.g., notification)
  final Widget? actionIcon;

  // Called when the center widget is tapped
  final VoidCallback? onTap;

  // Optional external scroll controller, useful if you want to control scroll outside
  final ScrollController? scrollController;

  // The content widgets placed below the app bar
  final List<Widget> children;

  // Height of the white fading background box behind the top row
  final double fadingBackgroundHeight;

  // Callback when left widget is pressed (icon/button)
  final GestureTapCallback? leftWidgetPressed;

  // Callback when right widget is pressed (icon/button)
  final GestureTapCallback? rightWidgetPressed;

  // Color of the ripple effect when tapping icons
  final Color? widgetsRippleColor;

  // Custom corner radius for the fading white background
  final BorderRadius? fadingBackgroundRadius;

  // Custom shadow for the fading background
  final List<BoxShadow>? fadingBackgroundShadow;

  // Corner radius for the scrollable content's top area
  final double? scrollableContentTopRadius;

  // Scroll physics (e.g., bounce, clamping)
  final ScrollPhysics? physics;

  // Background color for the main container and scrollable content
  final Color? backgroundColor;

  // Curve used for animations (e.g., scaling)
  final Curve curve;

  // Overlay opacity level for the background image
  final double? backgroundImageColorAlpha;

  // Base background color behind everything (often transparent)
  final Color? baseBackgroundColor;

  // Callback function for pull-to-refresh
  final Future<void> Function()? onRefresh;

  const AnimatedCustomAppBar({
    super.key,
    this.backgroundImage,
    required this.centerWidget,
    this.profileIcon,
    this.actionIcon,
    this.onTap,
    required this.children,
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
    this.backgroundColor = Colors.white,
    this.curve = Curves.linear,
    this.backgroundImageColorAlpha = 0.5,
    this.baseBackgroundColor = Colors.transparent,
    this.physics = const BouncingScrollPhysics(),
    this.onRefresh,
  }) : assert(maxHeight > minHeight, 'maxHeight must be greater than minHeight'),
        assert(fadingBackgroundHeight >= 0, 'fadingBackgroundHeight must be non-negative');

  @override
  State<AnimatedCustomAppBar> createState() => _AnimatedCustomAppBarState();
}

class _AnimatedCustomAppBarState extends State<AnimatedCustomAppBar> with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  // A shorthand getter to access animation controller's value
  double get t => _animationController.value;

  @override
  void initState() {
    super.initState();

    // Use external controller if provided; else create internal one
    _scrollController = widget.scrollController ?? ScrollController();

    // Animation controller for animating UI changes on scroll
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    // Scale animation for center widget (e.g., search bar bounce)
    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: widget.curve));

    // Attach scroll listener to update animation based on offset
    _scrollController.addListener(_handleScroll);
  }

  /// Handles scroll changes and updates the animation progress
  void _handleScroll() {
    final offset = _scrollController.offset.clamp(0, widget.maxHeight - widget.minHeight);
    _animationController.value = offset / (widget.maxHeight - widget.minHeight);
  }

  // Calculates fading background radius based on scroll progress
  double getRadius() => (1 - t * 4) * (widget.fadingBackgroundHeight - 16);

  // Calculates fading background opacity based on scroll progress
  double getOpacity() => (1 - t * 4).clamp(0.0, 1.0);

  // Calculates the padding for icons dynamically
  double calculateIconRadius() => lerpDouble(4, 72, (widget.fadingBackgroundHeight - 56) / (200 - 56)) ?? 16;

  // Creates a circular box decoration with optional shadow
  BoxDecoration circularBoxDecoration(Color color) => BoxDecoration(
    shape: BoxShape.circle,
    color: color,
    boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 4)],
  );

  // Scales padding based on scroll progress
  EdgeInsets scaledPadding(double base, double factor) =>
      EdgeInsets.symmetric(horizontal: base - (factor * (1 - t)), vertical: 24);

  /// Reusable method to build an icon button with ripple and background
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
        child: Ink(decoration: circularBoxDecoration(bgColor), padding: EdgeInsets.all(padding), child: icon),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up internal controller if not using external one
    if (widget.scrollController == null) _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final radius = getRadius();
        final iconPadding = calculateIconRadius() + 10;

        return Stack(
          children: [
            // Base background color layer
            Container(color: widget.baseBackgroundColor, width: mediaSize.width, height: mediaSize.height),

            // Optional background image with color overlay
            if (widget.backgroundImage != null)
              Container(
                width: mediaSize.width,
                height: mediaSize.height,
                foregroundDecoration: BoxDecoration(
                  color: widget.backgroundColor?.withOpacity(widget.backgroundImageColorAlpha ?? 0.1),
                ),
                child: widget.backgroundImage,
              ),

            // Scrollable area with pull-to-refresh
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification) _handleScroll();
                return true;
              },
              child: widget.onRefresh != null
                  ? RefreshIndicator(
                onRefresh: widget.onRefresh!,
                edgeOffset: widget.maxHeight - widget.minHeight + 20,
                displacement: 40,
                child: _buildScrollView(mediaSize),
              )
                  : _buildScrollView(mediaSize),
            ),

            // White fading background with shadow that shrinks on scroll
            Opacity(
              opacity: 1 - getOpacity(),
              child: Container(
                height: widget.maxHeight / 1.3,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: widget.fadingBackgroundRadius ?? BorderRadius.vertical(bottom: Radius.circular(radius)),
                  boxShadow: widget.fadingBackgroundShadow ?? [],
                ),
              ),
            ),

            // Top AppBar row (left icon + center widget + right icon)
            SafeArea(
              bottom: false,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: scaledPadding(12, 8),
                  child: Row(
                    children: [
                      // Left: tappable profile/menu icon + center widget
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.onTap,
                          child: Container(
                            height: widget.fadingBackgroundHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(widget.fadingBackgroundHeight / 2),
                              color: Colors.white,
                              boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 4)],
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: buildIconButton(
                                    onTap: widget.leftWidgetPressed,
                                    icon:
                                    widget.profileIcon ??
                                        Icon(Icons.menu_outlined, size: 3 * sqrt(widget.fadingBackgroundHeight)),
                                    padding: iconPadding,
                                    bgColor: Colors.grey.shade200,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Center widget (e.g., title or search)
                                Expanded(
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 1.0, end: t >= 0.88 ? 1.1 : 1),
                                    duration: const Duration(milliseconds: 250),
                                    curve: widget.curve,
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
                      // Right icon button (e.g., notifications)
                      buildIconButton(
                        onTap: widget.rightWidgetPressed,
                        icon:
                        widget.actionIcon ??
                            Icon(Icons.notifications_none_outlined, size: 3 * sqrt(widget.fadingBackgroundHeight)),
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
    );
  }

  Widget _buildScrollView(Size mediaSize) {
    return CustomScrollView(
      controller: _scrollController,
      physics: widget.physics,
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              SizedBox(height: widget.maxHeight - 16),
              Container(
                height: 32,
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(widget.scrollableContentTopRadius ?? getRadius()),
                  ),
                ),
              ),
              Stack(
                children: [
                  Container(
                    width: mediaSize.width,
                    height: mediaSize.height,
                    decoration: BoxDecoration(
                      color: widget.backgroundColor,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(widget.scrollableContentTopRadius ?? getRadius()),
                      ),
                    ),
                  ),
                  Column(children: widget.children),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
