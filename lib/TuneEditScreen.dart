import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'ZoomImageScreen.dart';
import 'image.dart';

class TuneEditScreen extends StatefulWidget {
  final File imageFile;

  TuneEditScreen({Key? key, required this.imageFile}) : super(key: key);

  @override
  _TuneEditScreenState createState() => _TuneEditScreenState();
}

class _TuneEditScreenState extends State<TuneEditScreen> {
  double brightness = 1.0;
  late File displayedImage;
  late File originalImage;

  @override
  void initState() {
    super.initState();
    originalImage = widget.imageFile;
    displayedImage = widget.imageFile;
  }

  Widget brightnessSlider() {
    return Slider(
      min: 0.5,
      max: 1.5,
      divisions: 2,
      value: brightness,
      label: "Brightness: $brightness",
      onChanged: (double value) {
        setState(() {
          brightness = value;
        });
        updateImage();
      },
      activeColor: Colors.white,
      inactiveColor: Colors.white.withOpacity(0.5),
      thumbColor: Colors.white,
    );
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

  Future<void> updateImage() async {
    if (originalImage == null) return;
    final originalBytes = await originalImage.readAsBytes();
    img.Image? image = img.decodeImage(originalBytes);

    if (image != null) {
      img.Image adjustedImage = img.adjustColor(
        image,
        brightness: brightness,
      );

      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/temp_adjusted_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final File tempFile = File(path)..writeAsBytesSync(img.encodePng(adjustedImage));

      setState(() {
        displayedImage = tempFile;
      });
    }
  }

  Future<void> saveImage(File imageFile) async {
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final Directory tempDir = await getTemporaryDirectory();
    final String fileName = 'tuned_image_${DateTime.now().millisecondsSinceEpoch}.png';
    final File file = File('${tempDir.path}/$fileName');

    await file.writeAsBytes(imageBytes);
    ImageManager().addImagePath(file.path);

    Navigator.pop(context, file.path);
  }

  void resetImage() {
    setState(() {
      brightness = 1.0;
      updateImage();
    });
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
              flex: 2,
              child: GestureDetector(
                onTap: photoZoom,
                child: Center(
                  child: Container(
                    width: 360,
                    height: 300,
                    child: Image.file(displayedImage, key: UniqueKey(), fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
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
            ),
            SizedBox(height: 40),
            brightnessSlider(),
          ],
      ),
      ),
    );
  }
}
