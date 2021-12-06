import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
  FlutterTts flutterTts = FlutterTts();

  Future _speak(String text) async{
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(text);
  }

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

        if (response.statusCode == 200) {
          final result = jsonDecode(stringed.body) as Map<String, dynamic>;
          setState(() {
            category = "You are in ${result["category"]}";
          });
          if (soundOn) _speak("You are in $category.");
        } else {
          setState(() {
            category = "Oops, there was an error.";
          });
          if (soundOn) _speak(category);
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
                icon: Icon(Icons.mic_rounded),
                onPressed: () {
                  setState(() {
                    soundOn = false;
                  });
                }
            )
                : IconButton(
                icon: Icon(Icons.mic_off_rounded),
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
              Text("Welcome!",
                style: TextStyle(color: Colors.black, fontSize: 30),),
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
              Image.file(image, height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.6,),
              SizedBox(height: 20,),
              category == null
                  ? SpinKitDoubleBounce(color: Colors.purple, size: 45)
                  : Text(
                category, style: TextStyle(fontSize: 20),),
              SizedBox(height: 20,),
              TextButton.icon(
                  label: Text("Click another picture",
                    style: TextStyle(color: Colors.purple, fontSize: 25),),
                  icon: Icon(
                    Icons.add_a_photo, size: 30, color: Colors.purple,),
                  onPressed: _getImageAndClassify)
            ],
          ),
        )
    );
  }
}
