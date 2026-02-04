library printer_gateway;

import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as decoder;
import 'package:printer_gateway/core/image_decoding/image_decoder.dart';
import 'package:printer_gateway/receipt/layout_receipt.dart';
import 'package:screenshot/screenshot.dart';

/// Main gateway class for converting JSON receipt data into various formats.
///
/// This class provides methods to convert structured JSON receipt data into:
/// - Flutter widgets for display
/// - Images (PNG format)
/// - POS printer compatible format (List of Uint8List)
/// - ESC/POS printer compatible format (List of decoded Images)
///
/// The primary goal is to ensure consistent receipt rendering across
/// different devices by generating a unified image representation.
class PrinterGateway {

  /// Creates a [PrinterGateway] instance.
  ///
  /// The [jsonData] parameter contains the receipt structure in JSON format.
  /// Defaults to an empty object array if not provided.
  ///
  /// The [imageHeader] and [imageFooter] are optional images that will be
  /// displayed at the top and bottom of the receipt respectively.
  PrinterGateway(
      {String jsonData = '[{}]',
      Uint8List? imageHeader,
      Uint8List? imageFooter})
      : _jsonData = jsonData,
        _imageHeader = imageHeader,
        _imageFooter = imageFooter;
  /// The JSON string containing the receipt data structure.
  String _jsonData;

  /// Optional header image to be displayed at the top of the receipt.
  Uint8List? _imageHeader;

  /// Optional footer image to be displayed at the bottom of the receipt.
  Uint8List? _imageFooter;

  /// Converts the JSON receipt data into a Flutter Widget.
  ///
  /// This method is useful for displaying receipts within your Flutter app.
  ///
  /// Parameters:
  /// - [maxWidth]: Maximum width of the receipt widget in pixels. Default: 576
  /// - [margin]: Horizontal margin/padding in pixels. Default: 0
  ///
  /// Returns a [Widget] that can be used in your widget tree.
  Widget toWidget({double maxWidth = 576, int margin = 0}) => LayoutReceipt(
        jsonContent: _jsonData,
        margin: margin,
        maxWidth: maxWidth,
        imageHeader: _imageHeader,
        imageFooter: _imageFooter,
      );

  /// Adds or updates the header image for the receipt.
  ///
  /// The [image] parameter should be a Uint8List containing the image data.
  /// Returns the added image.
  Uint8List addHeaderImage(Uint8List image) => _imageHeader = image;

  /// Adds or updates the footer image for the receipt.
  ///
  /// The [image] parameter should be a Uint8List containing the image data.
  /// Returns the added image.
  Uint8List addFooterImage(Uint8List image) => _imageFooter = image;

  /// Updates the receipt JSON data.
  ///
  /// The [jsonData] parameter should contain the receipt structure in
  /// JSON format. Returns the updated JSON string.
  String addData(String jsonData) => _jsonData = jsonData;

  /// Converts a list of image bytes into decoded Image objects.
  ///
  /// Takes a list of [parts] (Uint8List) and decodes each one into
  /// a raster Image object suitable for ESC/POS printing.
  ///
  /// Returns a list of decoded images, skipping any that fail to decode.
  Future<List<decoder.Image>> _rasterConverter(List<Uint8List> parts) async {
    final images = <decoder.Image>[];

    for (final part in parts) {
      final decoder.Image? image = decoder.decodeImage(part);
      if (image != null) {
        images.add(image);
      }
    }
    return images;
  }

  /// Converts the receipt into a list of decoded Images for ESC/POS printers.
  ///
  /// This method generates raster images that can be used with ESC/POS
  /// printer libraries. Long receipts are automatically split into chunks.
  ///
  /// Parameters:
  /// - [context]: BuildContext required for widget rendering
  /// - [maxHeight]: Maximum height per image chunk in pixels. Default: 2000
  /// - [maxWidth]: Width of each image in pixels. Default: 576
  /// - [margin]: Horizontal margin in pixels. Default: 0
  /// - [fixedRatio]: Pixel ratio for image quality (0 = auto). Default: 0
  ///
  /// Returns a list of decoded Image objects ready for ESC/POS printing.
  Future<List<decoder.Image>> toEscPosPrinter(BuildContext context,
      {int maxHeight = 2000,
      double maxWidth = 576,
      int margin = 0,
      double fixedRatio = 0}) async {
    final ImageDecoder decoder = ImageDecoder();
    final parts = await decoder.splitImage(
      await _capture(context,
          maxWidth: maxWidth, margin: margin, fixedRatio: fixedRatio),
      maxHeight,
    );

    return await _rasterConverter(parts);
  }

  /// Converts the receipt into a list of image bytes for POS printers.
  ///
  /// This method generates image data that can be sent directly to POS
  /// printers. Long receipts are automatically split into chunks.
  ///
  /// Parameters:
  /// - [context]: BuildContext required for widget rendering
  /// - [maxHeight]: Maximum height per image chunk in pixels. Default: 2000
  /// - [maxWidth]: Width of each image in pixels. Default: 576
  /// - [margin]: Horizontal margin in pixels. Default: 0
  /// - [fixedRatio]: Pixel ratio for image quality (0 = auto). Default: 0
  ///
  /// Returns a list of Uint8List containing PNG image data.
  Future<List<Uint8List>> toPosPrinter(BuildContext context,
      {int maxHeight = 2000,
      double maxWidth = 576,
      int margin = 0,
      double fixedRatio = 0}) async {
    final ImageDecoder decoder = ImageDecoder();
    final parts = await decoder.splitImage(
      await _capture(context,
          maxWidth: maxWidth, margin: margin, fixedRatio: fixedRatio),
      maxHeight,
    );

    return parts;
  }

  /// Generates a single image (PNG) from the receipt data.
  ///
  /// This method creates a complete image representation of the receipt
  /// without splitting it into parts.
  ///
  /// Parameters:
  /// - [context]: BuildContext required for widget rendering
  /// - [maxWidth]: Width of the generated image in pixels. Default: 576
  /// - [margin]: Horizontal margin in pixels. Default: 0
  /// - [fixedRatio]: Pixel ratio for image quality (0 = auto). Default: 0
  ///
  /// Returns a Uint8List containing the PNG image data.
  Future<Uint8List> toImage(BuildContext context,
          {double maxWidth = 576,
          int margin = 0,
          double fixedRatio = 0}) async =>
      await _capture(context,
          maxWidth: maxWidth, margin: margin, fixedRatio: fixedRatio);

  /// Internal method to capture the receipt widget as an image.
  ///
  /// Uses the screenshot package to render the widget and convert it to
  /// an image. This ensures consistent output across all devices.
  ///
  /// Parameters:
  /// - [context]: BuildContext for rendering
  /// - [maxWidth]: Width of the capture in pixels
  /// - [margin]: Horizontal margin in pixels
  /// - [fixedRatio]: Pixel ratio (0 = auto-detect device pixel ratio)
  ///
  /// Returns the captured image as Uint8List (PNG format).
  Future<Uint8List> _capture(BuildContext context,
      {required double maxWidth, int margin = 0, double fixedRatio = 0}) async {
    final ScreenshotController screenshotController = ScreenshotController();
    log('Device Pixel Ratio =  $fixedRatio');
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
