import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printer_gateway/receipt/layout_controller.dart';

class LayoutReceipt extends StatelessWidget {
  final String jsonContent;
  final double maxWidth;
  final Uint8List? imageHeader;
  final Uint8List? imageFooter;
  final int margin;

  const LayoutReceipt({super.key, required this.jsonContent, required this.maxWidth, this.imageHeader, this.imageFooter, this.margin = 0});

  @override
  Widget build(BuildContext context) {
    final controller = LayoutController(imageHeader: imageHeader, imageFooter: imageFooter);
    controller.parse(jsonContent);
    return DefaultTextStyle(
      style: const TextStyle(fontFamily: null),
      child: Material(
        child: SizedBox(
          width: maxWidth,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: margin.toDouble()),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: controller.layoutReceipt,
            ),
          ),
        ),
      ),
    );
  }
}
