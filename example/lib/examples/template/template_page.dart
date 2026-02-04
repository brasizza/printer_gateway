import 'package:flutter/material.dart';
import 'package:stub_printer/examples/template/template_controller.dart';

import '../../core/printer/printer_controller.dart';

class TemplatePage extends StatelessWidget {
  final TemplateController controller;
  const TemplatePage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return controller.data.isEmpty
        ? const Center(
            child: Text('Aguardando template'),
          )
        : Scaffold(
            appBar: AppBar(),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                        child: controller.show(
                      maxWidth: 500,
                      margin: 20,
                    )),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final listImage = await controller.loadImage(context,
                        maxHeight: 2000, margin: 20);
                    final PrinterController printerController =
                        PrinterController();
                    await printerController.init();
                    await printerController.printImage(listImage);
                    printerController.cut();
                    printerController.disconnect();
                  },
                  child: const Text(
                    "Imprimir",
                  ),
                )
              ],
            ),
          );
  }
}
