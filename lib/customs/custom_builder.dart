import 'package:flutter/widgets.dart';

import 'custom_divider.dart';
import 'custom_jump_line.dart';
import 'custom_qrcode.dart';
import 'customized_text.dart';

/// A widget that dynamically builds different types of receipt line components
/// based on the provided data structure.
///
/// This builder supports multiple types of content:
/// - Text lines with customization (content)
/// - Divider lines (divider)
/// - Blank lines/jumps (jump)
/// - QR codes (qrcode)
///
/// The [linha] map determines which component is built by checking for
/// specific keys.
class CustomBuilder extends StatelessWidget {

  /// Creates a [CustomBuilder] widget.
  ///
  /// The [linha] parameter must contain at least one of the following keys:
  /// - 'content': for text lines
  /// - 'divider': for separator lines
  /// - 'jump': for blank space
  /// - 'qrcode': for QR code generation
  const CustomBuilder({super.key, required this.linha});
  /// The line data map containing the type and properties of the component
  /// to be built.
  final Map<dynamic,dynamic> linha;

  @override
  Widget build(BuildContext context) {
    if (linha.containsKey('content')) {
      return _buildCustomizedText();
    } else if (linha.containsKey('divider')) {
      return const CustomDivider();
    } else if (linha.containsKey('jump')) {
      return _buildCustomJumpLine();
    } else if (linha.containsKey('qrcode')) {
      return _buildCustomQrcode();
    } else {
      return const SizedBox.shrink();
    }
  }

  /// Builds a customized text widget with styling options.
  Widget _buildCustomizedText() {
    return CustomizedText(linha: linha);
  }

  /// Builds blank lines based on the jump value.
  ///
  /// Parses the 'jump' value from [linha] to determine how many
  /// blank lines to insert. Defaults to 1 if parsing fails.
  Widget _buildCustomJumpLine() {
    final int pular = int.tryParse(linha['jump'].toString()) ?? 1;
    return CustomJumpLine(times: pular);
  }

  /// Builds a QR code widget with the provided data.
  Widget _buildCustomQrcode() {
    return CustomQrcode(qrcode: linha['qrcode']);
  }
}
