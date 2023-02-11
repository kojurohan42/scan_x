import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ScanX',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Scanx'),
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
  String? message = '';
  File? selectedImage;
  final ImagePicker _picker = ImagePicker();
  dynamic res, thresh, im_bw, matrix;

  Future _getImage() async {
// You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
      Permission.mediaLibrary,
    ].request();
    final pickedImage = await _picker.pickImage(source: ImageSource.camera);
    selectedImage = File(pickedImage!.path);
    setState(() {});
  }

  Future _getImageGallery() async {
// You can request multiple permissions at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.mediaLibrary,
    ].request();
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    selectedImage = File(pickedImage!.path);
    setState(() {});
  }

  _scanImage() async {
    final request = http.MultipartRequest(
        "POST",
        Uri.parse(
            "https://be5e-2407-54c0-1b10-be4-d486-aaea-3c-5795.in.ngrok.io/upload"));
    final headers = {"Content-type": "multipart/form-data"};
    request.files.add(http.MultipartFile('image',
        selectedImage!.readAsBytes().asStream(), selectedImage!.lengthSync(),
        filename: selectedImage!.path.split("/").last));
    request.headers.addAll(headers);
    final response = await request.send();
    http.Response res = await http.Response.fromStream(response);
    final resJson = jsonDecode(res.body);
    message = resJson['message'];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              selectedImage == null
                  ? Text("Please pick a image to scan")
                  : Image.file(selectedImage!),
              TextButton.icon(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.blue)),
                  onPressed: _scanImage,
                  icon: Icon(Icons.scanner_outlined, color: Colors.white),
                  label: Text(
                    "Scan",
                    style: TextStyle(color: Colors.white),
                  )),
              Text(
                'Text in Image',
                style: Theme.of(context).textTheme.headline4,
              ),
              Text(
                '$message',
                style: Theme.of(context).textTheme.headline4,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: _getImage,
                          child: const Text('Image from Camera'),
                        ),
                        ElevatedButton(
                          onPressed: _getImageGallery,
                          child: const Text('Image from Gallery'),
                        ),
                      ],
                    ),
                  ),
                );
              });
        },
        tooltip: 'getImage',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}
// ngrok http 4000

