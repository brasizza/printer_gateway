library printer_gateway;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as decoder;
import 'package:printer_gateway/core/image_decoding/image_decoder.dart';
import 'package:printer_gateway/receipt/layout_receipt.dart';
import 'package:screenshot/screenshot.dart';

class PrinterGateway {
  String _jsonData;
  Uint8List? _imageHeader;
  Uint8List? _imageFooter;

  PrinterGateway(
      {String jsonData = '[{}]',
      Uint8List? imageHeader,
      Uint8List? imageFooter})
      : _jsonData = jsonData,
        _imageHeader = imageHeader,
        _imageFooter = imageFooter;

  Widget toWidget({double maxWidth = 576}) => LayoutReceipt(
        jsonContent: _jsonData,
        maxWidth: maxWidth,
        imageHeader: _imageHeader,
        imageFooter: _imageFooter,
      );

  addHeaderImage(Uint8List image) => _imageHeader = image;

  addFooterImage(Uint8List image) async {
    _imageFooter = image;
  }

  addData(String jsonData) => _jsonData = jsonData;

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

  Future<List<decoder.Image>> toEscPosPrinter(BuildContext context,
      {int maxHeight = 2000, double maxWidth = 576}) async {
    ImageDecoder decoder = ImageDecoder();
    final parts = await decoder.splitImage(
      await _capture(context, maxWidth: maxWidth),
      maxHeight,
    );

    return await _rasterConverter(parts);
  }

  Future<List<Uint8List>> toPosPrinter(BuildContext context,
      {int maxHeight = 2000, double maxWidth = 576}) async {
    ImageDecoder decoder = ImageDecoder();
    final parts = await decoder.splitImage(
      await _capture(context, maxWidth: maxWidth),
      maxHeight,
    );

    return parts;
  }

  Future<Uint8List> toImage(BuildContext context,
          {double maxWidth = 576}) async =>
      await _capture(context, maxWidth: maxWidth);

  Future<Uint8List> _capture(BuildContext context,
      {required double maxWidth}) async {
    ScreenshotController screenshotController = ScreenshotController();

    return await screenshotController.captureFromLongWidget(
      InheritedTheme.captureAll(
        context,
        toWidget(maxWidth: maxWidth),
      ),
      pixelRatio: MediaQuery.of(context).devicePixelRatio,
      delay: const Duration(milliseconds: 100),
      context: context,
    );
  }
}
