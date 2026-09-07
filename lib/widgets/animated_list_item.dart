import 'package:flutter/material.dart';

/// Wraps a list-item widget with a staggered fade + slide-up entrance.
///
/// Pass the item's [index] and every item in a `ListView` will animate in
/// one after another (a small [delayPerItem] apart) instead of all
/// appearing at once — this is the "awesome animation" touch applied to
/// every list in the app (billing items, weeks, days) via one shared
/// widget instead of duplicating animation code per screen.
class AnimatedListItem extends StatefulWidget {
  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
    this.delayPerItem = const Duration(milliseconds: 45),
  });

  final int index;
  final Widget child;
  final Duration delayPerItem;

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.delayPerItem * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
