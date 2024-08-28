import 'package:flutter/material.dart';

class CustomizedText extends StatelessWidget {
  const CustomizedText({
    super.key,
    required this.linha,
  });

  final Map linha;

  String obscureString(String input) {
    int length = input.length;

    // If the string is less than 5 characters, show only the first and last character
    if (length < 3) {
      if (length == 1) {
        return input; // If the string is a single character, return it as is
      }
      return input[0] + '*' * (length - 2) + input[length - 1];
    }

    // For strings with 5 or more characters, show the first 3 and last 2 characters
    return " ${input.substring(0, 3)}${'*' * (length - 5)}${input.substring(length - 2)}";
  }

  TextAlign customAlignment({required Map customizacao}) {
    return switch (customizacao['alignment']) {
      0 => TextAlign.start,
      1 => TextAlign.center,
      2 => TextAlign.end,
      3 => TextAlign.justify,
      _ => TextAlign.center,
    };
  }

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

    return TextStyle(
      fontSize: fontSize.toDouble(),
      fontWeight: weight,
      fontStyle: style,
    );
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
