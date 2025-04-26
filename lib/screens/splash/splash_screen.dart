import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:qoute_app/screens/home/home_screen.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splashIconSize: 250,
      duration: 3000,
      nextScreen: HomeScreen(),
      centered: true,
      splash: Column(
        children: [
          Expanded(
            child: LottieBuilder.asset(
              'assets/Animation - 1744956806670.json',
              fit: BoxFit.fill,
            ),
          ),

          Text(
            'Fashion Assistant AI',
            style: TextStyle(
              fontSize: 22,
              color: Colors.black,
              fontFamily: 'Marker',
            ),
          ),
        ],
      ),
    );
  }
}
