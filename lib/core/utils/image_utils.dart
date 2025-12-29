import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/widgets.dart';

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

Image imageFromBase64String(String base64String) {
	return Image.memory(base64Decode(base64String));
}

Uint8List dataFromBase64String(String base64String) {
	return base64Decode(base64String);
}

String base64String(Uint8List data) {
	return base64Encode(data);
}