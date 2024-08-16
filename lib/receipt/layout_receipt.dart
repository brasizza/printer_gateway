import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printer_gateway/receipt/layout_controller.dart';

class LayoutReceipt extends StatelessWidget {
  final String jsonContent;
  final double maxHeigth;
  final Uint8List? imageHeader;
  final Uint8List? imageFooter;

  const LayoutReceipt({super.key, required this.jsonContent, required this.maxHeigth, this.imageHeader, this.imageFooter});

  @override
  Widget build(BuildContext context) {
    final controller = LayoutController(imageHeader: imageHeader, imageFooter: imageFooter);
    controller.parse(jsonContent);
    return Material(
      child: SizedBox(
        width: maxHeigth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: controller.layoutReceipt,
        ),
      ),
    );
  }
}
