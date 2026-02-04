import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printer_gateway/printer_gateway.dart';
import 'package:stub_printer/core/utils.dart';

class TemplateController {
  final PrinterGateway printerGateway;
  String data = '';
  Uint8List? logoCliente;
  Uint8List? logoEpoc;
  TemplateController({required this.printerGateway});

  void init(String data) async {
    try {
      var object = json.decode(data);
      if (object != null) {
        this.data = data;
        printerGateway.addData(data);
        logoCliente =
            await Utils.i.convertAssetToUint8List('assets/logos/dash.png');
        logoEpoc =
            await Utils.i.convertAssetToUint8List('assets/logos/dash4.png');
        if (logoEpoc != null) {
          printerGateway.addFooterImage(logoEpoc!);
        }
        if (logoCliente != null) {
          printerGateway.addHeaderImage(logoCliente!);
        }
      }
    } catch (_) {
      this.data = '';
    }
  }

  Widget show({double maxWidth = 576, int margin = 0}) =>
      printerGateway.toWidget(maxWidth: maxWidth, margin: margin);

  Future<List<dynamic>> loadImage(BuildContext context,
      {int maxHeight = 2000, double maxWidth = 576, int margin = 0}) async {
    final image = await printerGateway.toEscPosPrinter(
      context,
      maxHeight: maxHeight,
      maxWidth: maxWidth,
      margin: margin,
    );
    if(!context.mounted){
      return image;

    }
    final image2 = await printerGateway.toImage(context);

    final Directory downloadsDir = await getApplicationDocumentsDirectory();
    await File('${downloadsDir.path}/image2.png').writeAsBytes(image2);

    return image;
  }
}
