import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splashIconSize: 250,
      nextScreen: Container(),
      splash: Center(
        child: LottieBuilder.asset(
          'assets/Animation - 1742482544235.json',
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
