import 'package:flutter/material.dart';
import 'image_to_bram.dart';  // Import the new screen
import 'bram_to_image.dart'; // Import the new screen
import 'package:url_launcher/url_launcher.dart'; // To open URLs

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Encryption .bram',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Image Encryption .bram'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> _launchURL() async {
    const url = 'https://bramwelagina.my.canva.site/bramsnumbersystem';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[200],
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // Add paragraph above the cards
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'The BRAMS number system is a unique way of encoding numerical values as pairs of letters. '
                    'This system is used to convert color values (RGB) into a simplified, encoded format. Each '
                    'color value is broken down into a two-letter representation, helping to compress the information '
                    'for easier storage and transfer.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: _launchURL,
                    child: const Text(
                      'Learn more about the BRAMS number system',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Existing Row with the Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ImageToBramScreen()),
                      );
                    },
                    child: Container(
                      width: 150,
                      height: 150,
                      child: const Center(child: Text('Image to .bram')),
                    ),
                  ),
                ),
                Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BramToImageScreen()),
                      );
                    },
                    child: Container(
                      width: 150,
                      height: 150,
                      child: const Center(child: Text('.bram to Image')),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
