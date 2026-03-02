import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

/// A widget that displays a QR code with customizable size and error correction.
///
/// This widget uses the pretty_qr_code package to render QR codes based on
/// the provided data structure.
class CustomQrcode extends StatelessWidget {
  /// Creates a [CustomQrcode] widget.
  ///
  /// The [qrcode] parameter must contain the QR code configuration data.
  const CustomQrcode({super.key, required this.qrcode});

  /// The QR code configuration map containing:
  /// - 'size': The size of the QR code in pixels (defaults to 100)
  /// - 'content': The data to encode in the QR code
  /// - 'level': Error correction level ('L', 'M', 'Q', or 'H')
  final Map qrcode;

  @override
  Widget build(BuildContext context) {
    final double size =
        (int.tryParse(qrcode['size'].toString()) ?? 100).toDouble();
    return Center(
      child: SizedBox(
        width: size,
        child: PrettyQrView.data(
            data: qrcode['content'] ?? '',
            errorCorrectLevel: switch (qrcode['level']) {
              'L' => QrErrorCorrectLevel.L,
              'M' => QrErrorCorrectLevel.M,
              'Q' => QrErrorCorrectLevel.Q,
              'H' => QrErrorCorrectLevel.H,
              _ => QrErrorCorrectLevel.H,
            }),
      ),
    );
  }
}
