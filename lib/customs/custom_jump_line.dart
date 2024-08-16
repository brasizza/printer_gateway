import 'package:flutter/material.dart';

class CustomJumpLine extends StatelessWidget {
  final int times;

  const CustomJumpLine({super.key, this.times = 1});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (3 * times).toDouble(),
    );
  }
}
