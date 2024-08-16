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
    return " " +
        input.substring(0, 3) +
        '*' * (length - 5) +
        input.substring(length - 2);
  }

  TextAlign customAlignment({required Map customizacao}) {
    return switch (customizacao['alinhamento']) {
      0 => TextAlign.start,
      1 => TextAlign.center,
      2 => TextAlign.end,
      3 => TextAlign.justify,
      _ => TextAlign.center,
    };
  }

  TextStyle customFont({required Map customizacao}) {
    double fontSize =
        (int.tryParse(customizacao['tamanho_fonte'].toString()) ?? 12)
            .toDouble();
    fontSize *= 1.5;

    FontWeight weight = switch (customizacao['estilo_fonte']['bold']) {
      true => FontWeight.bold,
      false => FontWeight.normal,
      _ => FontWeight.normal,
    };

    FontStyle style = switch (customizacao['estilo_fonte']['italico']) {
      true => FontStyle.italic,
      false => FontStyle.normal,
      _ => FontStyle.normal,
    };

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
    if (linha.containsKey('customizacao')) {
      style = customFont(customizacao: linha['customizacao']);
      align = customAlignment(customizacao: linha['customizacao']);
      if ((linha['customizacao'] as Map).containsKey('reverse')) {
        style = style.copyWith(color: Colors.white);
        containerColor = Colors.black;
      }
    }

    return Container(
      color: containerColor,
      child: Text(
        "${linha['content']}${linha.containsKey('sensive') ? obscureString(linha['sensive']) : ''}",
        style: style,
        textAlign: align,
      ),
    );
  }
}
