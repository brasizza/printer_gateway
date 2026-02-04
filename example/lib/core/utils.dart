import 'package:flutter/services.dart';

class Utils {
  static Utils? _instance;
  // Avoid self instance
  Utils._();
  static Utils get i => _instance ??= Utils._();

  Future<Uint8List> convertAssetToUint8List(String assetPath) async {
    ByteData byteData = await rootBundle.load(assetPath);
    Uint8List imageData = byteData.buffer.asUint8List();
    return imageData;
  }
}
