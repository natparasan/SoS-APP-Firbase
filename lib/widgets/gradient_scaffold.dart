import 'package:flutter/material.dart';

/// Wraps a screen body with a full-bleed gradient background, so auth
/// and hero screens all share the same vivid backdrop.
class GradientScaffold extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final PreferredSizeWidget? appBar;

  const GradientScaffold({
    super.key,
    required this.child,
    required this.gradient,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: gradient),
        child: SafeArea(child: child),
      ),
    );
  }
}
