import 'dart:convert';
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
  String category;

  void _getImageAndClassify() async {
    PickedFile pickedFile = (await ImagePicker().getImage(
        source: ImageSource.camera, maxHeight: 1080, maxWidth: 1080));
    setState(() {
      if (pickedFile != null) {
        category = null;
        image = File(pickedFile.path);
      }
    });

    if (image != null) {
      var request = new http.MultipartRequest(
          "POST", Uri.parse("https://scene-net.herokuapp.com/predict"));
      request.files.add(
          http.MultipartFile(
              'image',
              image.readAsBytes().asStream(),
              image.lengthSync(),
              filename: "image.jpg")
      );


      request.send().then((response) async {
        var stringed = await http.Response.fromStream(response);
        final result = jsonDecode(stringed.body) as Map<String, dynamic>;

        if (response.statusCode == 200) {
          setState(() {
            category = result["category"];
          });
        } else {
          category = "Oops, there was an error.";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: image == null ? Center(
            child: IconButton(
                icon: Icon(Icons.add_a_photo), onPressed: _getImageAndClassify)
        ) : Column(
          children: [
            Image.file(image),
            category == null ? Text("Loading....") : Text(category),
            IconButton(
                icon: Icon(Icons.add_a_photo), onPressed: _getImageAndClassify)
          ],
        )
    );
  }
}
