import 'package:flutter/material.dart';

/// A widget that displays customizable text with various styling options.
///
/// This widget supports:
/// - Text alignment (left, center, right, justify)
/// - Font styling (bold, italic)
/// - Font size customization
/// - Reverse colors (white on black)
/// - Custom font families
/// - Sensitive content obscuring
class CustomizedText extends StatelessWidget {
  /// Creates a [CustomizedText] widget.
  ///
  /// The [linha] parameter contains the text content and customization options.
  const CustomizedText({
    super.key,
    required this.linha,
  });

  /// The line configuration map containing:
  /// - 'content': The text to display
  /// - 'sensive_content': Optional sensitive data to obscure
  /// - 'customization': Styling options (font_size, font_style, alignment, etc.)
  final Map linha;

  /// Obscures sensitive string data by showing only partial characters.
  ///
  /// For strings with [minLength]+ characters: shows first 3 and last 2 characters.
  /// For shorter strings: shows first and last character.
  /// Single character strings are returned unchanged.
  /// [minLength] defines the minimum length to apply the obscure logic (default: 5).
  String obscureString(String input, {int minLength = 5}) {
    final int length = input.length;

    if (length <= 1) return input;

    if (length <= minLength) {
      return input[0] + '*' * (length - 2) + input[length - 1];
    }

    // For strings longer than minLength, show the first 3 and last 2 characters
    return "${input.substring(0, 3)}${'*' * (length - 5)}${input.substring(length - 2)}";
  }

  /// Determines text alignment based on the customization configuration.
  ///
  /// Accepts values:
  /// - 0: Left/Start alignment
  /// - 1: Center alignment
  /// - 2: Right/End alignment
  /// - 3: Justify alignment
  /// - Default: Center alignment
  TextAlign customAlignment({required Map customizacao}) {
    return switch (customizacao['alignment']) {
      0 => TextAlign.start,
      1 => TextAlign.center,
      2 => TextAlign.end,
      3 => TextAlign.justify,
      _ => TextAlign.center,
    };
  }

  /// Creates a custom TextStyle based on the customization configuration.
  ///
  /// Reads the following properties from customization:
  /// - 'font_size': Text size (scaled by 1.5x)
  /// - 'font_style': Object with 'bold' and 'italic' booleans
  /// - 'font_name': Optional custom font family name
  ///
  /// Returns a configured TextStyle object.
  TextStyle customFont({required Map customizacao}) {
    FontWeight weight = FontWeight.normal;
    FontStyle style = FontStyle.normal;
    double fontSize =
        (int.tryParse(customizacao['font_size'].toString()) ?? 12).toDouble();
    fontSize *= 1.5;
    if (customizacao.containsKey('font_style')) {
      if (customizacao['font_style'].containsKey('bold')) {
        weight = switch (customizacao['font_style']['bold'] ?? false) {
          true => FontWeight.bold,
          false => FontWeight.normal,
          _ => FontWeight.normal,
        };
      } else {
        weight = FontWeight.normal;
      }

      if (customizacao['font_style'].containsKey('italic')) {
        style = switch (customizacao['font_style']['italic'] ?? false) {
          true => FontStyle.italic,
          false => FontStyle.normal,
          _ => FontStyle.normal,
        };
      } else {
        style = FontStyle.normal;
      }
    }
    String? fontName;
    if (customizacao.containsKey('font_name')) {
      fontName = customizacao['font_name'];
    }

    return TextStyle(
        fontSize: fontSize.toDouble(),
        fontWeight: weight,
        fontStyle: style,
        fontFamily: fontName);
  }

  @override
  Widget build(BuildContext context) {
    TextAlign align = TextAlign.center;

    TextStyle style = const TextStyle();
    Color containerColor = Colors.transparent;
    if (linha.containsKey('customization')) {
      style = customFont(customizacao: linha['customization']);
      align = customAlignment(customizacao: linha['customization']);
      if ((linha['customization'] as Map).containsKey('reverse')) {
        if (linha['customization']['reverse'] == true) {
          style = style.copyWith(color: Colors.white);
          containerColor = Colors.black;
        }
      }
    }

    return linha['content'].isEmpty
        ? const SizedBox.shrink()
        : Container(
            color: containerColor,
            child: Text(
              "${linha['content']}${linha.containsKey('sensive_content') ? obscureString(linha['sensive_content']) : ''}",
              style: style,
              textAlign: align,
            ),
          );
  }
}
