import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

/// A customizable animated app bar widget with scroll interaction,
/// fading background, and action/profile icons.
/// Designed to be flexible and elegant with visual polish.
class AnimatedCustomAppBar extends StatefulWidget {
  // Optional background image widget
  final Widget? backgroundImage;

  // Maximum expanded height of the AppBar
  final double maxHeight;

  // Minimum collapsed height of the AppBar
  final double minHeight;

  // The widget placed in the center of the app bar
  final Widget centerWidget;

  // Optional left-side icon (typically profile or menu)
  final Widget? profileIcon;

  // Optional right-side icon (e.g., notification bell)
  final Widget? actionIcon;

  // Called when centerWidget or left content is tapped
  final VoidCallback? onTap;

  // Optional external scroll controller
  final ScrollController? scrollController;

  // Children below the AppBar in scrollable area
  final List<Widget> children;

  // Height of the fading white background box
  final double fadingBackgroundHeight;

  // Callback for left icon press
  final GestureTapCallback? leftWidgetPressed;

  // Callback for right icon press
  final GestureTapCallback? rightWidgetPressed;

  // Ripple color when tapping icons
  final Color? widgetsRippleColor;

  // Custom border radius for fading background
  final BorderRadius? fadingBackgroundRadius;

  // Custom shadow for fading background
  final List<BoxShadow>? fadingBackgroundShadow;

  // Top radius for scrollable content area
  final double? scrollableContentTopRadius;

  // Scroll physics for CustomScrollView
  final ScrollPhysics? physics;

  // App-wide background color
  final Color? backgroundColor;

  // Curve used for scale and animations
  final Curve curve;

  // Opacity level for background image overlay
  final double? backgroundImageColorAlpha;

  // Base background color behind everything
  final Color? baseBackgroundColor;

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
  }) : assert(maxHeight > minHeight, 'maxHeight must be greater than minHeight'),
        assert(fadingBackgroundHeight >= 0, 'fadingBackgroundHeight must be non-negative');

  @override
  State<AnimatedCustomAppBar> createState() => _AnimatedCustomAppBarState();
}

class _AnimatedCustomAppBarState extends State<AnimatedCustomAppBar> with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  // Shortcut for accessing animation progress (0.0 to 1.0)
  double get t => _animationController.value;

  @override
  void initState() {
    super.initState();

    // Use external scroll controller or create a new one
    _scrollController = widget.scrollController ?? ScrollController();

    // Animation controller to interpolate values based on scroll
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));

    // Scale animation for center widget
    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: widget.curve));

    // Attach listener to scroll controller
    _scrollController.addListener(_handleScroll);
  }

  // Calculate scroll offset and update animation controller accordingly
  void _handleScroll() {
    final offset = _scrollController.offset.clamp(0, widget.maxHeight - widget.minHeight);
    _animationController.value = offset / (widget.maxHeight - widget.minHeight);
  }

  // Radius for fading background (shrinks as it scrolls)
  double getRadius() => (1 - t * 4) * (widget.fadingBackgroundHeight - 16);

  // Opacity for fading background
  double getOpacity() => (1 - t * 4).clamp(0.0, 1.0);

  // Calculate icon padding size based on fading background height
  double calculateIconRadius() =>
      lerpDouble(4, 72, (widget.fadingBackgroundHeight - 56) / (200 - 56)) ?? 16;

  // Circle box decoration for icon buttons
  BoxDecoration circularBoxDecoration(Color color) => BoxDecoration(
    shape: BoxShape.circle,
    color: color,
    boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 4)],
  );

  // Padding scaling based on animation progress
  EdgeInsets scaledPadding(double base, double factor) =>
      EdgeInsets.symmetric(horizontal: base - (factor * (1 - t)), vertical: 24);

  // Build tappable icon button
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
    // Only dispose internal scroll controller
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
            // Solid base background layer
            Container(
              color: widget.baseBackgroundColor,
              width: mediaSize.width,
              height: mediaSize.height,
            ),

            // Optional background image with fade overlay
            if (widget.backgroundImage != null)
              Container(
                width: mediaSize.width,
                height: mediaSize.height,
                foregroundDecoration: BoxDecoration(
                  color: widget.backgroundColor?.withOpacity(widget.backgroundImageColorAlpha ?? 0.1),
                ),
                child: widget.backgroundImage,
              ),

            // Scrollable content area
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification) _handleScroll();
                return true;
              },
              child: CustomScrollView(
                controller: _scrollController,
                physics: widget.physics,
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate([
                      // Reserve space equal to app bar height
                      SizedBox(height: widget.maxHeight - 16),

                      // Transition top round area for content
                      Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: widget.backgroundColor,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(widget.scrollableContentTopRadius ?? radius),
                          ),
                        ),
                      ),

                      // Main scrollable content area
                      Stack(
                        children: [
                          Container(
                            width: mediaSize.width,
                            height: mediaSize.height,
                            decoration: BoxDecoration(
                              color: widget.backgroundColor,
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(widget.scrollableContentTopRadius ?? radius),
                              ),
                            ),
                          ),
                          Column(children: widget.children),
                        ],
                      ),
                    ]),
                  ),
                ],
              ),
            ),

            // White fading overlay background behind AppBar
            Opacity(
              opacity: 1 - getOpacity(),
              child: Container(
                height: widget.maxHeight / 1.3,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: widget.fadingBackgroundRadius ??
                      BorderRadius.vertical(bottom: Radius.circular(radius)),
                  boxShadow: widget.fadingBackgroundShadow ?? [],
                ),
              ),
            ),

            // Main AppBar with center + icons
            SafeArea(
              bottom: false,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Padding(
                  padding: scaledPadding(12, 8),
                  child: Row(
                    children: [
                      // Left (center + profile icon) widget area
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
                                    icon: widget.profileIcon ??
                                        Icon(Icons.menu_outlined,
                                            size: 3 * sqrt(widget.fadingBackgroundHeight)),
                                    padding: iconPadding,
                                    bgColor: Colors.grey.shade200,
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Center widget (text/title/any widget)
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

                      // Right-side action icon (notification or any widget)
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
    );
  }
}
