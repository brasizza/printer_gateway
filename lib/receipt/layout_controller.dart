import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../customs/custom_builder.dart';

// ignore: constant_identifier_names
enum GenericType { HEADER, FOOTER }

class LayoutController {
  final Uint8List? imageHeader;
  final Uint8List? imageFooter;

  List<Widget> layoutReceipt = [];

  LayoutController({required this.imageHeader, required this.imageFooter});

  void parse(String jsonContent) {
    final jsonData = json.decode(jsonContent) as List;
    for (var data in jsonData) {
      if (data.containsKey('header')) {
        final header = data['header'] as List;
        _buildFixedLayout(header, GenericType.HEADER);
      } else if (data.containsKey('footer')) {
        final footer = data['footer'] as List;
        _buildFixedLayout(footer, GenericType.FOOTER);
      } else {
        layoutReceipt.addAll(_buildLine(data));
      }
    }
  }

  List<Widget> _buildLine(data) {
    final returnWidgets = <Widget>[];
    final linha = data['line'] as Map;

    if (linha.containsKey('column')) {
      final widgetHeader = <Widget>[];
      final widgetColunas = <Widget>[];
      final totalColunas = linha['column'].length;
      Map<int, TableColumnWidth> columnWidth = {};

      if (totalColunas > 0) {
        final razao = (100 / totalColunas);
        final colunas = linha['column'] as List;
        final listCabecalho = colunas.firstWhere((c) => c.containsKey('header'), orElse: () => null);
        if (listCabecalho != null) {
          final cabecalho = listCabecalho['header'] as List;

          for (var i = 0; i < cabecalho.length; i++) {
            columnWidth[i] = FractionColumnWidth((int.tryParse(cabecalho[i]['row']['size'].toString()) ?? razao) / 100);
          }
        }
        for (var coluna in linha['column']) {
          final linha = coluna['row'];

          widgetColunas.add(TableCell(
            child: CustomBuilder(linha: linha),
          ));
        }
        final row = <TableRow>[];
        if (listCabecalho != null) {
          final cabecalho = listCabecalho['header'] as List;
          for (var cabeca in cabecalho) {
            final linha = cabeca['row'];
            widgetHeader.add(TableCell(
              child: CustomBuilder(linha: linha),
            ));
          }
          row.add(
            TableRow(
              children: widgetHeader,
            ),
          );
        }
        row.add(
          TableRow(
            children: widgetColunas,
          ),
        );

        returnWidgets.add(Table(
          columnWidths: columnWidth,
          children: row,
        ));
      } else {
        returnWidgets.add(
          CustomBuilder(linha: linha),
        );
      }
    } else {
      returnWidgets.add(
        CustomBuilder(linha: linha),
      );
    }

    return returnWidgets;
  }

  void _buildFixedLayout(List<dynamic> item, GenericType footer) {
    final headerLayout = <Widget>[];
    bool hasImage = false;
    for (var linha in item) {
      if (linha.containsKey('image')) {
        hasImage = linha['image'] ?? false;
      } else {
        if (linha.containsKey('line')) {
          headerLayout.addAll(_buildLine(linha));
        }
      }
    }

    final image = switch (footer) {
      GenericType.HEADER => imageHeader,
      GenericType.FOOTER => imageFooter,
    };
    if (footer == GenericType.FOOTER) {
      layoutReceipt.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: headerLayout,
            )),
            (image != null && hasImage)
                ? Image.memory(
                    color: Colors.black,
                    image,
                  )
                : const SizedBox.shrink(),
          ],
        ),
      );
    } else {
      layoutReceipt.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            (image != null && hasImage)
                ? ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Colors.grey,
                      BlendMode.saturation,
                    ),
                    child: Image.memory(
                      image,
                      fit: BoxFit.scaleDown,
                      width: 200,
                      height: 200,
                    ),
                  )
                : const SizedBox.shrink(),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: headerLayout,
            )),
          ],
        ),
      );
    }
  }
}
