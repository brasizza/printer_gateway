import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printer_gateway/receipt/layout_controller.dart';

/// The main receipt layout widget that renders JSON receipt data.
///
/// This widget takes JSON-formatted receipt data and renders it as a
/// Flutter widget with proper styling and layout.
class LayoutReceipt extends StatelessWidget {
  /// Creates a [LayoutReceipt] widget.
  ///
  /// All parameters are required except [imageHeader], [imageFooter], and [margin].
  const LayoutReceipt(
      {super.key,
      required this.jsonContent,
      required this.maxWidth,
      this.imageHeader,
      this.imageFooter,
      this.margin = 0});

  /// The JSON string containing the receipt structure and data.
  final String jsonContent;

  /// The maximum width of the receipt in pixels.
  final double maxWidth;

  /// Optional header image to display at the top of the receipt.
  final Uint8List? imageHeader;

  /// Optional footer image to display at the bottom of the receipt.
  final Uint8List? imageFooter;

  /// Horizontal margin/padding in pixels.
  final int margin;

  @override
  Widget build(BuildContext context) {
    final controller =
        LayoutController(imageHeader: imageHeader, imageFooter: imageFooter);
    controller.parse(jsonContent);
    return Theme(
      data: ThemeData.light(),
      child: DefaultTextStyle(
        style: const TextStyle(),
        child: Material(
          child: SizedBox(
            width: maxWidth,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: margin.toDouble()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: controller.layoutReceipt,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
