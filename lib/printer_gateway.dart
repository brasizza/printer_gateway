library printer_gateway;

import 'dart:developer';
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

  PrinterGateway({String jsonData = '[{}]', Uint8List? imageHeader, Uint8List? imageFooter})
      : _jsonData = jsonData,
        _imageHeader = imageHeader,
        _imageFooter = imageFooter;

  Widget toWidget({double maxWidth = 576, int margin = 0}) => LayoutReceipt(
        jsonContent: _jsonData,
        margin: margin,
        maxWidth: maxWidth,
        imageHeader: _imageHeader,
        imageFooter: _imageFooter,
      );

  addHeaderImage(Uint8List image) => _imageHeader = image;

  addFooterImage(Uint8List image) => _imageFooter = image;

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

  Future<List<decoder.Image>> toEscPosPrinter(BuildContext context, {int maxHeight = 2000, double maxWidth = 576, int margin = 0, double fixedRatio = 0}) async {
    ImageDecoder decoder = ImageDecoder();
    final parts = await decoder.splitImage(
      await _capture(context, maxWidth: maxWidth, margin: margin, fixedRatio: fixedRatio),
      maxHeight,
    );

    return await _rasterConverter(parts);
  }

  Future<List<Uint8List>> toPosPrinter(BuildContext context, {int maxHeight = 2000, double maxWidth = 576, int margin = 0, double fixedRatio = 0}) async {
    ImageDecoder decoder = ImageDecoder();
    final parts = await decoder.splitImage(
      await _capture(context, maxWidth: maxWidth, margin: margin, fixedRatio: fixedRatio),
      maxHeight,
    );

    return parts;
  }

  Future<Uint8List> toImage(BuildContext context, {double maxWidth = 576, int margin = 0, fixedRatio = false}) async => await _capture(context, maxWidth: maxWidth, margin: margin, fixedRatio: fixedRatio);

  Future<Uint8List> _capture(BuildContext context, {required double maxWidth, int margin = 0, double fixedRatio = 0}) async {
    ScreenshotController screenshotController = ScreenshotController();
    log("Device Pixel Ratio =  $fixedRatio");
    return await screenshotController.captureFromLongWidget(
      InheritedTheme.captureAll(
        context,
        toWidget(maxWidth: maxWidth, margin: margin),
      ),
      pixelRatio: fixedRatio != 0 ? fixedRatio : null,
      delay: const Duration(milliseconds: 100),
      context: context,
    );
  }
}
