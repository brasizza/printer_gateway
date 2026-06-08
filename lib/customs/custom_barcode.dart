import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

/// A widget that displays a 1D/2D barcode with a configurable symbology
/// and height.
///
/// This widget uses the barcode_widget package to render barcodes based on
/// the provided data structure. It is the barcode counterpart of
/// [CustomQrcode].
class CustomBarcode extends StatelessWidget {
  /// Creates a [CustomBarcode] widget.
  ///
  /// The [barcode] parameter must contain the barcode configuration data.
  const CustomBarcode({super.key, required this.barcode});

  /// The barcode configuration map containing:
  /// - 'size': The height of the barcode in pixels (defaults to 80)
  /// - 'content': The data to encode in the barcode
  /// - 'type': The barcode symbology ('code128', 'code39', 'ean13', 'ean8',
  ///   'upca', 'itf', or 'qrCode'). Defaults to 'code128'.
  /// - 'drawText': Whether to render the human-readable text below the
  ///   barcode (defaults to true)
  final Map barcode;

  /// Resolves the 'drawText' flag, defaulting to true.
  ///
  /// Accepts a real boolean or the strings 'true'/'false', so values coming
  /// from a loosely-typed JSON map do not reach [BarcodeWidget] as the wrong
  /// type. Anything other than an explicit false keeps the default (true).
  bool _resolveDrawText(dynamic drawText) {
    return switch (drawText) {
      false => false,
      'false' => false,
      _ => true,
    };
  }

  /// Maps the textual 'type' value to a [Barcode] symbology.
  ///
  /// Unknown or missing types fall back to Code 128, which accepts the
  /// widest range of input.
  Barcode _resolveType(dynamic type) {
    return switch (type) {
      'code128' => Barcode.code128(),
      'code39' => Barcode.code39(),
      'ean13' => Barcode.ean13(),
      'ean8' => Barcode.ean8(),
      'upca' => Barcode.upcA(),
      'itf' => Barcode.itf(),
      _ => Barcode.code128(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final double height =
        (int.tryParse(barcode['size'].toString()) ?? 80).toDouble();
    return Center(
      child: BarcodeWidget(
        barcode: _resolveType(barcode['type']),
        data: barcode['content'] ?? '',
        height: height,
        drawText: _resolveDrawText(barcode['drawText']),
        errorBuilder: (context, error) => const SizedBox.shrink(),
      ),
    );
  }
}
