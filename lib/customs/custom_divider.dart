// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

/// A simple horizontal divider widget for receipt layouts.
///
/// Displays a black horizontal line to separate sections in the receipt.
class CustomDivider extends StatelessWidget {
  final Map<dynamic, dynamic>? linha;
  const CustomDivider({
    super.key,
    this.linha,
  });
  /// Creates a [CustomDivider] widget.

  @override
  Widget build(BuildContext context) {
    final bool isVisible = linha?.containsKey('divider') ?? true;
   //se o linha['divider'] for um map e tiver o campo thickness e height, use esses valores caso contrario o fallback dos 2 é 1 
    final int thickness = (linha?['divider'] is Map && linha?['divider']?['thickness'] != null)
        ? int.tryParse(linha?['divider']?['thickness']?.toString() ?? '1') ?? 1
        : 1;
    final int height = (linha?['divider'] is Map && linha?['divider']?['height'] != null)
        ? int.tryParse(linha?['divider']?['height']?.toString() ?? '1') ?? 1
        : 1;

    return isVisible
        ? Divider(
            color: Colors.black,
            thickness: thickness.toDouble(),
            height: height.toDouble(),
          )
        : const SizedBox.shrink();
  }
}
