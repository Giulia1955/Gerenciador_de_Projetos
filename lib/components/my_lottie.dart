import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MyLottie extends StatelessWidget {
  final String animation;
  final double height;
  final double width;

  const MyLottie({
    super.key,
    required this.animation,
    this.height = 200,
    this.width = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      animation,
      height: height,
      width: width,
      fit: BoxFit.contain,
      repeat: true,
    );
  }
}
