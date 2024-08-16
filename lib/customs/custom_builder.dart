import 'package:flutter/widgets.dart';

import 'custom_divider.dart';
import 'custom_jump_line.dart';
import 'custom_qrcode.dart';
import 'customized_text.dart';

class CustomBuilder extends StatelessWidget {
  final Map linha;

  const CustomBuilder({super.key, required this.linha});

  @override
  Widget build(BuildContext context) {
    if (linha.containsKey('content')) {
      return _buildCustomizedText();
    } else if (linha.containsKey('tracejado')) {
      return const CustomDivider();
    } else if (linha.containsKey('pular')) {
      return _buildCustomJumpLine();
    } else if (linha.containsKey('qrcode')) {
      return _buildCustomQrcode();
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildCustomizedText() {
    return CustomizedText(linha: linha);
  }

  Widget _buildCustomJumpLine() {
    final int pular = int.tryParse(linha['pular'].toString()) ?? 1;
    return CustomJumpLine(times: pular);
  }

  Widget _buildCustomQrcode() {
    return CustomQrcode(qrcode: linha['qrcode']);
  }
}
