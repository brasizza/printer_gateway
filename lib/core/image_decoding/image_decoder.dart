import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

/// Class to handle image decoding and splitting into parts
///
class ImageDecoder {
  /// Splits the given image into vertical parts of specified maximum height
  ///
  Future<List<Uint8List>> splitImage(Uint8List uintImage, int maxHeight) async {
    final parts = <Uint8List>[];

    /// Load the image from bytes
    ///
    final image = await _loadImage(uintImage);

    /// Calculate the number of vertical parts needed
    ///
    int yParts = (image.height / maxHeight).ceil();
    int partHeight = (image.height / yParts).round();

    /// Iterate over each vertical part
    ///
    for (int i = 0; i < yParts; i++) {
      /// Extract a part of the image
      ///
      final partImage = await _extractImagePart(
          image, 0, i * partHeight, image.width, partHeight);

      /// Convert the extracted image part to byte data
      ///
      final partBytes = await _imageToByteData(partImage);

      /// Add the byte data of the part to the list if it's not null
      ///
      if (partBytes != null) {
        parts.add(partBytes);
      }
    }

    return parts;
  }

  /// Extracts a rectangular part from the image
  ///
  Future<ui.Image> _extractImagePart(
      ui.Image image, int x, int y, int width, int height) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();

    /// Define source and destination rectangles for cropping
    ///
    final src = Rect.fromLTWH(
        x.toDouble(), y.toDouble(), width.toDouble(), height.toDouble());
    final dst = Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());

    /// Draw the specified part of the image onto the canvas
    ///
    canvas.drawImageRect(image, src, dst, paint);

    /// End recording and create an image from the recorded picture
    ///
    final picture = recorder.endRecording();
    return picture.toImage(width, height);
  }

  /// Converts an image to byte data in PNG format
  ///
  Future<Uint8List?> _imageToByteData(ui.Image image) async {
    /// Get the byte data from the image in PNG format
    ///
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  /// Loads an image from byte data
  ///
  Future<ui.Image> _loadImage(Uint8List image) async {
    /// Instantiate an image codec from the byte data
    ///
    final codec = await ui.instantiateImageCodec(image);

    /// Get the first frame from the codec
    ///
    final frame = await codec.getNextFrame();

    /// Return the image from the frame
    ///
    return frame.image;
  }
}
