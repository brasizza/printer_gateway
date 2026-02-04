import 'package:esc_pos_printer_plus/esc_pos_printer_plus.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

class PrinterController {
  late final NetworkPrinter printer;
  Future<PosPrintResult> init() async {
    const PaperSize paper = PaperSize.mm80;
    final profile = await CapabilityProfile.load();
    printer = NetworkPrinter(paper, profile);
    return await printer.connect('192.168.5.111', port: 9100);
  }

  Future<void> printImage(List<dynamic> listImage) async {
    for (var image in listImage) {
      printer.imageRaster(image, align: PosAlign.left);
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  void cut() {
    printer.cut();
  }

  void disconnect() {
    printer.disconnect();
  }
}
