import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShellBackHandler extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onGoToFirstTab;
  final Widget child;

  const ShellBackHandler({
    super.key,
    required this.currentIndex,
    required this.onGoToFirstTab,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        currentIndex == 0 ? SystemNavigator.pop() : onGoToFirstTab();
      },
      child: child,
    );
  }
}
