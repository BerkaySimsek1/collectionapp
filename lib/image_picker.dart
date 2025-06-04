import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

// Single image picker for gallery
Future<XFile?> pickImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  return image;
}

// Single image picker with source selection
Future<XFile?> pickImageWithSource(ImageSource source) async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: source);
  return image;
}

// Multiple image picker
Future<List<XFile>> pickMultipleImages({int maxImages = 5}) async {
  final ImagePicker picker = ImagePicker();
  final List<XFile> images = await picker.pickMultiImage();

  if (images.length > maxImages) {
    return images.take(maxImages).toList();
  }

  return images;
}

// Image compression utility
Future<File?> compressImage(File file, {int quality = 70}) async {
  final compressedFile = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    "${file.parent.path}/compressed_${file.uri.pathSegments.last}",
    quality: quality,
    minWidth: 800,
    minHeight: 600,
  );
  return compressedFile != null ? File(compressedFile.path) : null;
}

// Convert XFile to File
File xFileToFile(XFile xFile) {
  return File(xFile.path);
}
