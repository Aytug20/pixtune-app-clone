import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pixtune_clone/TuneEditScreen.dart';
import 'package:pixtune_clone/image.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'FilterEditScreen.dart';

class HomePage extends StatefulWidget {
  final String? imagePath;
  HomePage({Key? key, this.imagePath}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int imageIndex = 0;
  List<File> images = [];
  List<Uint8List> imagesUint8 = [];

  Future<void> shareImage(Uint8List imageBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final imageFile = File(
        '${directory.path}/filtered_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await imageFile.writeAsBytes(imageBytes);
    Share.shareFiles([imageFile.path]);
  }

  Future<void> saveGallery(File imageFile) async {
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final result = await ImageGallerySaver.saveImage(imageBytes,
        quality: 60,
        name: "filtered_image_${DateTime.now().millisecondsSinceEpoch}");
    if (result['isSuccess']) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Image saved to gallery!')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to save image.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Image Picker'),
          actions: [
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () async {
                if (imageIndex < ImageManager().lastImagePaths.length) {
                  String imagePath = ImageManager().lastImagePaths[imageIndex];
                  File imageFile = File(imagePath);
                  Uint8List imageBytes = await imageFile.readAsBytes();
                  shareImage(imageBytes);
                }
              },
            ),
            SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () async {
                saveGallery(images[imageIndex]);
              },
            ),
            SizedBox(width: 15),
          ],
          backgroundColor: Colors.black,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: imageIndex > 0
                          ? () => setState(() => imageIndex -= 1)
                          : null,
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: imageIndex == 0
                            ? Colors.grey[300]
                            : Color.fromARGB(204, 79, 0, 158),
                        size: 22,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: GestureDetector(
                          onTap: () => selectImage(context, setState, images,
                              imagesUint8, imageIndex),
                          child: Container(
                            height: 320,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: images.length == 0
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_rounded,
                                        color: Colors.black.withOpacity(0.3),
                                        size: 30,
                                      ),
                                      SizedBox(width: 16),
                                      Text(
                                        "Add Photo",
                                        style: TextStyle(
                                          color: Colors.black.withOpacity(0.3),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  )
                                : Image.file(images[imageIndex],
                                    fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: imageIndex < (images.length - 1)
                          ? () => setState(() => imageIndex += 1)
                          : null,
                      icon: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: imageIndex == (images.length - 1) ||
                                images.length == 0
                            ? Colors.grey[300]
                            : Color.fromARGB(204, 79, 0, 158),
                        size: 22,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                if (images.length > 0)
                  Center(
                    child: Text("Page ${imageIndex + 1}"),
                  ),
                SizedBox(height: 20),
                if (images.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  TuneEditScreen(imageFile: images[imageIndex]),
                            ),
                          )
                              .then((result) {
                            if (result != null) {
                              setState(() {
                                ImageManager()
                                    .replaceImagePath(imageIndex, result);
                                images[imageIndex] = File(result);
                              });
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.tune, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Tune",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (context) => FilterEditScreen(
                                  imageFile: images[imageIndex]),
                            ),
                          )
                              .then((result) {
                            if (result != null) {
                              setState(() {
                                ImageManager()
                                    .replaceImagePath(imageIndex, result);
                                images[imageIndex] = File(result);
                              });
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.filter, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Filter",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
