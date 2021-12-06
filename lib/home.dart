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
  bool soundOn = false;

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
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("SceneNet", textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),),
          elevation: 0,
          backgroundColor: Colors.white,
          actions: [
            soundOn
                ? IconButton(
                icon: Icon(Icons.mic_off_rounded),
                onPressed: () {
                  setState(() {
                    soundOn = false;
                  });
                }
            )
                : IconButton(
                icon: Icon(Icons.mic_rounded),
                onPressed: () {
                  setState(() {
                    soundOn = true;
                  });
                }
            )
          ],
          actionsIconTheme: IconThemeData(
              color: Colors.black
          ),
        ),
        body: image == null ? Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("Welcome!", style: TextStyle(color: Colors.black, fontSize: 30),),
              // SizedBox(height: 100,),
              Image.asset(
                  "assets/images/undraw_Artificial_intelligence_re_enpp.png"),
              IconButton(
                  icon: Icon(Icons.add_a_photo, size: 40,),
                  onPressed: _getImageAndClassify)
            ]
        ) : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.file(image, height: MediaQuery.of(context).size.height * 0.6,),
              category == null ? Text("Loading....") : Text(category),
              IconButton(
                  icon: Icon(Icons.add_a_photo, size: 40,), onPressed: _getImageAndClassify)
            ],
          ),
        )
    );
  }
}
