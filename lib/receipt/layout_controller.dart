import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../customs/custom_builder.dart';

// ignore: constant_identifier_names
/// Type of fixed layout section in the receipt.
enum GenericType {
  /// Header section at the top of the receipt.
  HEADER,

  /// Footer section at the bottom of the receipt.
  FOOTER
}

/// Controller responsible for parsing JSON receipt data and building
/// the corresponding Flutter widget layout.
///
/// This controller handles the conversion of JSON-formatted receipt data
/// into a list of widgets that can be rendered. It supports various receipt
/// elements including text lines, columns, tables, headers, and footers.
class LayoutController {
  /// Creates a [LayoutController] instance.
  ///
  /// The [imageHeader] and [imageFooter] parameters are optional images
  /// that can be displayed in the header or footer sections of the receipt.
  LayoutController({required this.imageHeader, required this.imageFooter});

  /// Optional header image to be displayed at the top of the receipt.
  final Uint8List? imageHeader;

  /// Optional footer image to be displayed at the bottom of the receipt.
  final Uint8List? imageFooter;

  /// The list of widgets representing the complete receipt layout.
  List<Widget> layoutReceipt = <Widget>[];

  /// Parses JSON content and builds the receipt layout.
  ///
  /// Takes a [jsonContent] string containing the receipt data in JSON format
  /// and processes it to populate the [layoutReceipt] list with widgets.
  ///
  /// Supports special keys:
  /// - 'header': Creates a header section with optional image
  /// - 'footer': Creates a footer section with optional image
  /// - 'line': Creates a regular line item
  void parse(String jsonContent) {
    final List<dynamic> jsonData = json.decode(jsonContent) as List;
    for (final data in jsonData) {
      if (data.containsKey('header')) {
        final List<dynamic> header = data['header'] as List;
        _buildFixedLayout(header, GenericType.HEADER);
      } else if (data.containsKey('footer')) {
        final List<dynamic> footer = data['footer'] as List;
        _buildFixedLayout(footer, GenericType.FOOTER);
      } else {
        layoutReceipt.addAll(_buildLine(data));
      }
    }
  }

  /// Builds a line widget from the provided data.
  ///
  /// Handles different types of line layouts:
  /// - Simple text lines
  /// - Column-based layouts (two or more columns)
  /// - Table layouts with headers and items
  ///
  /// Returns a list of widgets representing the line content.
  List<Widget> _buildLine(Map<String, dynamic> data) {
    final List<Widget> returnWidgets = <Widget>[];
    final Map<dynamic, dynamic> linha = data['line'] as Map;

    if (linha.containsKey('column')) {
      final List<Widget> widgetHeader = <Widget>[];
      final List<Widget> widgetColunas = <Widget>[];
      final totalColunas = linha['column'].length;
      final Map<int, TableColumnWidth> columnWidth = <int, TableColumnWidth>{};
      final List<TableRow> row = <TableRow>[];

      if (totalColunas > 0) {
        final double razao = (100 / totalColunas);
        final List<dynamic> colunas = linha['column'] as List;
        final listCabecalho = colunas.firstWhere((c) => c.containsKey('header'),
            orElse: () => null);
        if (listCabecalho != null) {
          final List<dynamic> cabecalho = listCabecalho['header'] as List;

          for (int i = 0; i < cabecalho.length; i++) {
            columnWidth[i] = FractionColumnWidth(
                (int.tryParse(cabecalho[i]['row']['size'].toString()) ??
                        razao) /
                    100);
          }
        }

        if (listCabecalho != null) {
          final List<dynamic> cabecalho = listCabecalho['header'] as List;
          for (final cabeca in cabecalho) {
            final linha = cabeca['row'];
            if (linha != null) {
              widgetHeader.add(TableCell(
                child: CustomBuilder(linha: linha),
              ));
            }
          }
          if (widgetHeader.isNotEmpty) {
            row.add(
              TableRow(
                children: widgetHeader,
              ),
            );
          }
        }
        if (linha.containsKey('column')) {
          for (final coluna in linha['column']) {
            final linha = coluna['row'];
            if (linha != null) {
              widgetColunas.add(TableCell(
                child: CustomBuilder(linha: linha),
              ));
            } else {
              final items = (listCabecalho['items']);
              if (items != null) {
                final List<Widget> widgetItems = <Widget>[];
                for (final item in items) {
                  widgetItems.clear();
                  for (final itemLine in item) {
                    final linha = itemLine['row'];
                    if (linha != null) {
                      widgetItems.add(TableCell(
                        child: CustomBuilder(linha: linha),
                      ));
                    }
                  }
                  if (widgetItems.isNotEmpty) {
                    row.add(
                      TableRow(
                        children: <Widget>[...widgetItems],
                      ),
                    );
                  }
                }
              }
            }
          }
        }

        if (widgetColunas.isNotEmpty) {
          row.add(
            TableRow(
              children: widgetColunas,
            ),
          );
        }
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

  /// Builds a fixed layout section (header or footer) with optional image.
  ///
  /// Takes a list of [item] data and a [footer] type (HEADER or FOOTER)
  /// to determine positioning and styling of the section.
  ///
  /// If an image is available and the 'image' flag is set to true,
  /// the image will be displayed alongside the content.
  void _buildFixedLayout(List<dynamic> item, GenericType footer) {
    final List<Widget> headerLayout = <Widget>[];
    bool hasImage = false;
    for (final linha in item) {
      if (linha.containsKey('image')) {
        hasImage = linha['image'] ?? false;
      } else {
        if (linha.containsKey('line')) {
          headerLayout.addAll(_buildLine(linha));
        }
      }
    }

    final Uint8List? image = switch (footer) {
      GenericType.HEADER => imageHeader,
      GenericType.FOOTER => imageFooter,
    };
    if (footer == GenericType.FOOTER) {
      layoutReceipt.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
