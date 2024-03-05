import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'ZoomImageScreen.dart';
import 'image.dart';

class FilterEditScreen extends StatefulWidget {
  final File imageFile;

  FilterEditScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  State<FilterEditScreen> createState() => _FilterEditScreenState();
}

class _FilterEditScreenState extends State<FilterEditScreen> {
  late File originalImage;
  late File displayedImage;

  @override
  void initState() {
    super.initState();
    originalImage = widget.imageFile;
    displayedImage = widget.imageFile;
  }

  Future<void> saveImage(File imageFile) async {
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final Directory tempDir = await getTemporaryDirectory();
    final String fileName = 'filtered_image_${DateTime.now().millisecondsSinceEpoch}.png';
    final File file = File('${tempDir.path}/$fileName');

    await file.writeAsBytes(imageBytes);

    ImageManager().addImagePath(file.path);

    Navigator.pop(context, file.path);
  }


  Future<void> imageFilter(Function filterOperation) async {
    var imageBytes = await originalImage.readAsBytes();
    var decodedImage = img.decodeImage(imageBytes)!;
    var filteredImage = filterOperation(decodedImage);
    var encodedImageBytes = img.encodePng(filteredImage);

    final tempFile = File('${(await getTemporaryDirectory()).path}/filtered_${DateTime.now().millisecondsSinceEpoch}.png');
    await tempFile.writeAsBytes(encodedImageBytes);

    setState(() {
      displayedImage = tempFile;
    });
  }

  void resetImage() {
    setState(() {
      displayedImage = originalImage;
    });
  }

  Widget imageButton(String imagePath, Function filterOperation) {
    return GestureDetector(
      onTap: () => imageFilter(filterOperation),
      child: Container(
        width: 100,
        height: 100,
        child: SvgPicture.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void photoZoom() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PhotoViewPage(imageFile: displayedImage),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("Edit Image"),
          centerTitle: true,
          backgroundColor: Colors.black,
        ),
          body: Column(
          children: <Widget>[
            Expanded(
              flex: 8,
              child: GestureDetector(
                onTap: photoZoom,
                child: Center(
                  child: Container(
                    width: 360,
                    height: 300,
                    child: Image.file(displayedImage, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    imageButton('assets/grayscale.svg',img.grayscale),
                    imageButton('assets/sepia.svg',img.sepia),
                    imageButton('assets/pixelate.svg', (image) => img.pixelate(image, size: 10)),
                    imageButton('assets/monochrome.svg', img.monochrome),
                    imageButton('assets/sketch.svg', img.sketch),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: ElevatedButton(
                    onPressed: resetImage,
                    child: Text(
                      "Original Image",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 40),
                Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: FloatingActionButton(
                    onPressed: () => saveImage(displayedImage),
                    child: Icon(Icons.check, size: 25.0),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
