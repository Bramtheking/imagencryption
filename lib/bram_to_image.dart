import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:logging/logging.dart';

class BramToImageScreen extends StatefulWidget {
  @override
  _BramToImageScreenState createState() => _BramToImageScreenState();
}

class _BramToImageScreenState extends State<BramToImageScreen> {
  final log = Logger('BramToImageScreen'); // Logger instance
  File? _bramFile;
// Store parsed BRAMS values
  bool _isProcessing = false; // Track processing state
  File? _image; // For displaying the image after conversion

  @override
  void initState() {
    super.initState();
    _setupLogging(); // Setup logging configuration
  }

  void _setupLogging() {
    Logger.root.level = Level.ALL; // Set the log level (ALL shows everything)
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    });
  }

  // Use ImagePicker to pick any file (treating it as a .bram)
  Future<void> _pickBramFile() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _bramFile = File(pickedFile.path);
      });
      String bramsData = await _bramFile!.readAsString();
      log.info('BRAMS file data: $bramsData');
      _processBramsData(bramsData);
    } else {
      log.warning('No file selected');
    }
  }

  void _processBramsData(String bramsData) {
    log.info('Processing BRAMS data');
    setState(() {
      _isProcessing = true;
    });

    List<String> bramsValues = bramsData.split(', ');
    log.info('Parsed BRAMS values: ${bramsValues.length} items');

    int totalPixels = bramsValues.length;
    int width = (totalPixels > 0) ? _calculateWidth(totalPixels) : 100;
    int height = (width > 0) ? (totalPixels / width).round() : 1;

    log.info('Calculated width: $width, height: $height');
    _convertBramsToImage(bramsValues, width, height);
  }

  int _calculateWidth(int totalPixels) {
    log.info('Calculating width for $totalPixels pixels');
    return (totalPixels > 0) ? (totalPixels ~/ (totalPixels / 100).round()) : 100;
  }

  void _convertBramsToImage(List<String> bramsValues, int width, int height) {
    log.info('Converting BRAMS to Image');

    img.Image image = img.Image(width, height);

    int index = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (index >= bramsValues.length) break;
        String bramsValue = bramsValues[index];
        List<int> rgb = _convertBramsToRGB(bramsValue);
        image.setPixel(x, y, img.getColor(rgb[0], rgb[1], rgb[2]));
        index++;
      }
    }

    setState(() {
      _image = File('converted_image.png')..writeAsBytesSync(img.encodePng(image));
      log.info('Image conversion successful, file saved');
      _isProcessing = false;
    });
  }

  List<int> _convertBramsToRGB(String bramsValue) {
    bramsValue = bramsValue.replaceAll(RegExp(r'[()]'), '');
    List<String> parts = bramsValue.split(', ');

    int r = _bramsToValue(parts[0]);
    int g = _bramsToValue(parts[1]);
    int b = _bramsToValue(parts[2]);

    return [r, g, b];
  }

  int _bramsToValue(String brams) {
    int firstLetterValue = brams.codeUnitAt(0) - 65;
    int secondLetterValue = brams.codeUnitAt(1) - 65;

    return firstLetterValue * 26 + secondLetterValue;
  }

  Future<void> _saveImage() async {
    if (_image == null) {
      log.warning('No image to save');
      return;
    }
    final directory = await getExternalStorageDirectory();
    final path = '${directory!.path}/converted_image.png';
    await _image!.copy(path);
    log.info('Image saved to $path');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image saved to $path')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('.bram to Image')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              child: InkWell(
                onTap: _pickBramFile, // File picker
                child: Container(
                  width: 200,
                  height: 200,
                  child: Center(child: Text('Pick .bram File')),
                ),
              ),
            ),
            if (_isProcessing) const CircularProgressIndicator(), // Show progress indicator
            if (_image != null) Image.file(_image!, height: 200),
            if (_image != null)
              ElevatedButton(
                onPressed: _saveImage,
                child: const Text('Save Image'),
              ),
          ],
        ),
      ),
    );
  }
}
