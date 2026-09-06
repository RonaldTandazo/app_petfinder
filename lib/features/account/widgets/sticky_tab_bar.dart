
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
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(StickyTabBar oldDelegate) {
    return false;
  }
}