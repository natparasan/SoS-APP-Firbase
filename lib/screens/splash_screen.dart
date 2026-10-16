import 'package:flutter/material.dart';
import 'package:sos_alert_package/sos_alert_package.dart';
import '../navigation/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => setState(() => _show = true));
    _start();
  }

  Future<void> _start() async {
    final results = await Future.wait([
      AuthService().currentAccount(),
      Future<void>.delayed(const Duration(seconds: 2)),
    ]);
    if (mounted) context.goToHome(results.first as Account?);
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      gradient: AppColors.backgroundGradient,
      child: Center(
        child: AnimatedOpacity(
          opacity: _show ? 1 : 0,
          duration: const Duration(milliseconds: 800),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.sosGradient),
                child: const Icon(Icons.shield, color: Colors.white, size: 56),
              ),
              const SizedBox(height: 24),
              const Text(
                'Emergency SOS',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
