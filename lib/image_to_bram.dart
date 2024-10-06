import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart'; // For app directory
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart'; // For clipboard
import 'package:flutter/foundation.dart'; // For compute

class ImageToBramScreen extends StatefulWidget {
  @override
  _ImageToBramScreenState createState() => _ImageToBramScreenState();
}

class _ImageToBramScreenState extends State<ImageToBramScreen> {
  File? _image;
  List<String> _bramsValues = [];
  bool _isProcessing = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _convertImageInBackground(); // Use background processing
    }
  }

  Future<void> _convertImageInBackground() async {
    if (_image == null) return;

    setState(() {
      _isProcessing = true;
    });

    // Read image data
    Uint8List imageData = await _image!.readAsBytes();

    // Offload heavy work to another isolate
    List<String> bramsValues = await compute(_processImage, imageData);

    setState(() {
      _bramsValues = bramsValues;
      _isProcessing = false;
    });
  }

  // Process image and convert pixels to BRAMS values
  static List<String> _processImage(Uint8List imageData) {
    img.Image? decodedImage = img.decodeImage(imageData);
    if (decodedImage == null) return [];

    // Resize the image to reduce memory usage
    img.Image resizedImage = img.copyResize(decodedImage, width: 500); // Resize width to 500, adjust as needed

    List<String> bramsValues = [];
    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        int pixel = resizedImage.getPixel(x, y);
        int r = img.getRed(pixel);
        int g = img.getGreen(pixel);
        int b = img.getBlue(pixel);
        bramsValues.add('(${_convertToBrams(r)}, ${_convertToBrams(g)}, ${_convertToBrams(b)})');
      }
    }
    return bramsValues;
  }

  // Convert RGB values to BRAMS format
  static String _convertToBrams(int value) {
    int quotient = value ~/ 26;
    int remainder = value % 26;
    String firstLetter = String.fromCharCode(65 + quotient);
    String secondLetter = String.fromCharCode(65 + remainder);
    return '$firstLetter$secondLetter';
  }

  // Save BRAMS values to a .bram file in the app's document directory
  Future<void> _saveBramsToFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/image_data.bram';
    final file = File(path);

    String bramsData = _bramsValues.join(', ');
    await file.writeAsString(bramsData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Brams data saved to $path')),
    );
  }

  Future<void> _copyToClipboard() async {
    final first10Codes = _bramsValues.take(10).join(', ');
    await Clipboard.setData(ClipboardData(text: first10Codes));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied first 10 BRAMS values to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image to .bram')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              child: InkWell(
                onTap: _pickImage,
                child: Container(
                  width: 200,
                  height: 200,
                  child: Center(child: Text('Pick Image')),
                ),
              ),
            ),
            if (_isProcessing) const CircularProgressIndicator(),
            if (!_isProcessing && _bramsValues.isNotEmpty)
              Column(
                children: [
                  const Text('First 10 .Brams Values:'),
                  SizedBox(
                    height: 200,
                    child: SingleChildScrollView(
                      child: Text(_bramsValues.take(10).join(', ')),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _saveBramsToFile,
                    child: const Text('Save as .bram'),
                  ),
                  ElevatedButton(
                    onPressed: _copyToClipboard,
                    child: const Text('Copy Codes'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
