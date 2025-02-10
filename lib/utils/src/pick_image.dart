// Dart imports:
import 'dart:io';

// Package imports:
import 'package:image_picker/image_picker.dart';

class PickImage {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage() async {
    try {
      XFile? tmpImage = await _picker.pickImage(source: ImageSource.gallery);

      if (tmpImage != null) {
        File image = File(tmpImage.path);
        return image;
      }

      return null;
    } catch (e) {
      throw e.toString();
    }
  }
}
