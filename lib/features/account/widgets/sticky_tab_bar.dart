import 'package:flutter/material.dart';

class StickyTabBar extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  StickyTabBar(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(StickyTabBar oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
      tabBar.preferredSize.height != oldDelegate.tabBar.preferredSize.height;
  }
}