import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class CustomQrcode extends StatelessWidget {
  final Map qrcode;

  const CustomQrcode({super.key, required this.qrcode});

  @override
  Widget build(BuildContext context) {
    final double size = (int.tryParse(qrcode['size'].toString()) ?? 100).toDouble();
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
