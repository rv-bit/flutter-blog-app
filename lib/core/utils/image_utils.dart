import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:image_picker/image_picker.dart';

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

Future<Uint8List> compressImage(File file) async {
	final result = await FlutterImageCompress.compressWithFile(
		file.absolute.path,
		minWidth: 1920,
		minHeight: 1080,
		quality: 85, // Adjust quality (0-100)
	);
	
	return result ?? await file.readAsBytes();
}

widgets.Image imageFromBase64String(String base64String) {
    return widgets.Image.memory(base64Decode(base64String));
}

Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
}

String base64String(Uint8List data) {
    return base64Encode(data);
}