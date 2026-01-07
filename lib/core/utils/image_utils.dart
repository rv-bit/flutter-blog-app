import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:image_picker/image_picker.dart';

// Function to pick multiple images from gallery, uses image_picker package as most reliable
// Source: https://pub.dev/packages/image_picker and adapted from https://github.com/RivaanRanawat/flutter_twitter_clone/blob/4f2c8a3bf02a0f5c72da5c56815c749b24c778ad/lib/core/utils.dart
// The pickImageCamera was created internally, for single image picking when the user wants to take a photo.
Future<List<File>> pickImages() async {
	List<File> images = [];
	final ImagePicker picker = ImagePicker();
	final imageFiles = await picker.pickMultiImage();
	if (imageFiles.isNotEmpty) {
		for (final image in imageFiles) {
			images.add(File(image.path));
		}
	}
	return images;
}

Future<File?> pickImage() async {
	final ImagePicker picker = ImagePicker();
	final imageFile = await picker.pickImage(source: ImageSource.gallery);
	if (imageFile != null) {
		return File(imageFile.path);
	}
	return null;
}

Future<File?> pickImageCamera() async {
	final ImagePicker picker = ImagePicker();
	final imageFile = await picker.pickImage(source: ImageSource.camera);
	if (imageFile != null) {
		return File(imageFile.path);
	}
	return null;
}

// Function to compress image file before upload, uses flutter_image_compress package
// Source: https://github.com/fluttercandies/flutter_image_compress?tab=readme-ov-file#usage
// This was due because have ran into some android devices, where they have upload / download limits on image size, so we need to compress the image before uploading to database.
Future<Uint8List> compressImage(File file) async {
	final result = await FlutterImageCompress.compressWithFile(
		file.absolute.path,
		minWidth: 1920,
		minHeight: 1080,
		quality: 85, // Adjust quality (0-100)
	);
	
	return result ?? await file.readAsBytes();
}

// This code is to take a base64 string and convert it to an image widget, which can be displayed in the app.
// Code was adapted from: https://stackoverflow.com/a/55699979 
widgets.Image imageFromBase64String(String base64String) {
    return widgets.Image.memory(base64Decode(base64String));
}

Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
}

String base64String(Uint8List data) {
    return base64Encode(data);
}