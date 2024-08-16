library printer_gateway;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as decoder;
import 'package:printer_gateway/core/image_decoding/image_decoder.dart';
import 'package:printer_gateway/receipt/layout_receipt.dart';
import 'package:screenshot/screenshot.dart';

class PrinterGateway {
  final String _jsonData;
  Uint8List? _imageHeader;
  Uint8List? _imageFooter;

  PrinterGateway({required String jsonData, Uint8List? imageHeader, Uint8List? imageFooter})
      : _jsonData = jsonData,
        _imageHeader = imageHeader,
        _imageFooter = imageFooter;

  Widget toWidget({double maxHeigth = 576}) => LayoutReceipt(
        jsonContent: _jsonData,
        maxHeigth: maxHeigth,
        imageHeader: _imageHeader,
        imageFooter: _imageFooter,
      );

  addHeaderImage(Uint8List image) {
    _imageHeader = image;
  }

  addFooterImage(Uint8List image) {
    _imageFooter = image;
  }

  Future<List<decoder.Image>> _rasterConverter(List<Uint8List> parts) async {
    final images = <decoder.Image>[];

    for (var part in parts) {
      final decoder.Image? image = decoder.decodeImage(part);
      if (image != null) {
        images.add(image);
      }
    }
    return images;
  }

  Future<List<decoder.Image>> toPrinter(BuildContext context, {int heigthMax = 500}) async {
    ImageDecoder decoder = ImageDecoder();
    final parts = await decoder.splitImage(
      await _capture(context),
      heigthMax,
    );

    return await _rasterConverter(parts);
  }

  Future<Uint8List> toImage(BuildContext context) async => await _capture(context);

  Future<Uint8List> _capture(BuildContext context) {
    ScreenshotController screenshotController = ScreenshotController();

    return screenshotController.captureFromLongWidget(
      InheritedTheme.captureAll(
        context,
        toWidget(),
      ),
      delay: const Duration(milliseconds: 100),
      context: context,
    );
  }
}
