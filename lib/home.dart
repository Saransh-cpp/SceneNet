import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  File image;

  void _getImageFromCamera() async {
    PickedFile pickedFile = (await ImagePicker().getImage(
        source: ImageSource.camera, maxHeight: 1080, maxWidth: 1080));
    setState(() {
      image = File(pickedFile.path);
    });

    var request = new http.MultipartRequest("POST", Uri.parse("https://scene-net.herokuapp.com/predict"));
    request.files.add(
        // http.MultipartFile.fromBytes("image", await image.readAsBytes(), contentType: MediaType('image', 'jpeg'))
        http.MultipartFile(
            'image',
            image.readAsBytes().asStream(),
            image.lengthSync(),
            filename: "image.jpg")
    );

    print("Sending");
    request.send().then((response) async {
      print("sent");
      var stringed = await http.Response.fromStream(response);
      print(stringed.body);
      if (response.statusCode == 200) {
        print(response.toString());
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IconButton(
            icon: Icon(Icons.add_a_photo), onPressed: _getImageFromCamera),
      ),
    );
  }
}
