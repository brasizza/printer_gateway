import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_editor_flutter/json_editor_flutter.dart';
import 'package:printer_gateway/printer_gateway.dart';
import 'package:stub_printer/examples/template/template_controller.dart';
import 'package:stub_printer/examples/template/template_page.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  late final TemplateController templatePrinter;

  void _processTemplate(String data) {
    // Wait for user to stop typing for 1 second before triggering the search
    setState(() {
      templatePrinter.init(data);
    });
  }

  @override
  void initState() {
    super.initState();
    templatePrinter = TemplateController(printerGateway: PrinterGateway());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PRINTER TEMPLATE JSON!'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
                child: JsonEditor(
                    editors: const [Editors.text, Editors.tree],
                    enableMoreOptions: false,
                    themeColor: Colors.blue,
                    json: '[{}]',
                    onChanged: (data) {
                      _processTemplate(json.encode(data));
                    })),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: TemplatePage(
                  controller: templatePrinter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
