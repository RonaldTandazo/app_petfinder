import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_petfinder/features/layout/widgets/floating_bottom_bar.dart';
import 'package:app_petfinder/features/layout/widgets/quick_action_bottom_sheet.dart';

class MainLayoutScreen extends StatelessWidget {
  final Widget child;
  final String prefix = '/main';

  const MainLayoutScreen({
    super.key,
    required this.child,
  });

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('$prefix/lost-pets')) return 1;
    if (location.startsWith('$prefix/community')) return 2;
    if (location.startsWith('$prefix/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('$prefix/home');
        break;
      case 1:
        context.go('$prefix/lost-pets');
        break;
      case 2:
        context.go('$prefix/community');
        break;
      case 3:
        context.go('$prefix/profile');
        break;
    }
  }

  void _showQuickActionModal(BuildContext context) async {
    await QuickActionBottomSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickActionModal(context),
        backgroundColor: Colors.teal,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: FloatingBottomBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }
}