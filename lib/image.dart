import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pixtune_clone/showBottomMenuSheet.dart';
import 'dart:async';

class ImageManager {
  static final ImageManager _instance = ImageManager._internal();

  factory ImageManager() => _instance;

  ImageManager._internal();

  final StreamController<List<String>> imagePathsController = StreamController<List<String>>.broadcast();
  List<String> imagePaths = [];

  Stream<List<String>> get imagePathsStream => imagePathsController.stream;

  List<String> get lastImagePaths => imagePaths;

  void addImagePath(String newPath) {
    imagePaths.add(newPath);
    imagePathsController.sink.add(imagePaths);
  }

  void replaceImagePath(int index, String newPath) {
    if (index >= 0 && index < imagePaths.length) {
      imagePaths[index] = newPath;
      imagePathsController.sink.add(imagePaths);
    }
  }

  void dispose() {
    imagePathsController.close();
  }
}

Widget imageButton(String imagePath, Function onTap) {
  return GestureDetector(
    onTap: () => onTap(),
    child: Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
    ),
  );
}

void pickImage(BuildContext context, Function(Function()) setState, ImageSource imageSource, List<File> images, List<Uint8List> imagesUint8, int imageIndex) async {
  ImagePicker? picker = ImagePicker();

  try {
    final image = await picker.pickImage(
      source: imageSource,
      imageQuality: 80,
    );

    if (image == null) return null;

    final imageUint8 = await image.readAsBytes();

    final imageFile = File(image.path);

    setState(() {
      images.add(imageFile);
      imagesUint8.add(imageUint8);
      print("Current images list: $images");
      imageIndex += 1;
    });

    Navigator.of(context, rootNavigator: true).pop();

    picker = null;
  } on PlatformException catch (e) {
    print("Failed to pick image: $e");

    picker = null;
  }
}

Future<void> selectImage(BuildContext context, Function(Function()) setState, List<File> images, List<Uint8List> imagesUint8, int imageIndex) async {
  List options = [
    {
      "title": "Take From Camera",
      "fn": () => pickImage(
        context,
        setState,
        ImageSource.camera,
        images,
        imagesUint8,
        imageIndex,
      ),
      "icon": Icons.camera_alt_rounded,
    },
    {
      "title": "Select From Gallery",
      "fn": () => pickImage(
        context,
        setState,
        ImageSource.gallery,
        images,
        imagesUint8,
        imageIndex,
      ),
      "icon": Icons.photo_library_rounded,
    },
  ];

  showBottomMenuSheet(context, options, height: 450);
}


