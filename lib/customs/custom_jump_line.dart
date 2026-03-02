import 'package:flutter/material.dart';

/// A widget that creates vertical spacing (blank lines) in the receipt.
///
/// This widget is used to insert empty space between receipt elements.
class CustomJumpLine extends StatelessWidget {
  /// Creates a [CustomJumpLine] widget.
  ///
  /// The [times] parameter determines how many blank lines to insert.
  /// Defaults to 1 if not specified.
  const CustomJumpLine({super.key, this.times = 1});

  /// The number of blank lines to insert.
  ///
  /// Each unit adds 3 pixels of vertical space.
  final int times;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (3 * times).toDouble(),
    );
  }
}
