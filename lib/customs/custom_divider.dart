import 'package:flutter/material.dart';

/// A simple horizontal divider widget for receipt layouts.
///
/// Displays a black horizontal line to separate sections in the receipt.
class CustomDivider extends StatelessWidget {
  /// Creates a [CustomDivider] widget.
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: Colors.black,
    );
  }
}
