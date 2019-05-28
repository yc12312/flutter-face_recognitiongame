import 'package:firebase_face_contour_example/face_contour_detection.dart';
import 'dart:ui' as ui;
import 'gloabals.dart' as gl;

import 'package:flame/flame.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_face_contour_example/game/Game.dart';


//FaceContourDetectionScreen()

//original main
//void main() async {
//  Flame.audio.disableLog();
//  List<ui.Image> image = await Flame.images.loadAll(["sprite.png"]);
//  TRexGame tRexGame = TRexGame(spriteImage: image[0]);
//  runApp(MaterialApp(
//    title: 'TRexGame',
//    home: Scaffold(
//      body: GameWrapper(tRexGame),
//    ),
//  ));
//
//  Flame.util.addGestureRecognizer(new TapGestureRecognizer()
//    ..onTapDown = (TapDownDetails evt) => tRexGame.onTap());
//
//  SystemChrome.setEnabledSystemUIOverlays([]);
//}

class Login extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 200.0,
              width: 200.0,
              child: Image.asset('assets/images/logo.png',
              fit: BoxFit.cover,)),
          Text('LAZY DINOSAUR',
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold
          ),),
          SizedBox(
            height: 50.0,
          ),
          Center(
            child: RaisedButton(
              child: Text('To Game'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameWrapper(gl.tRexGame)),
                );

              },
            ),
          ),
        ],
      ),
    );
  }
}

class GameWrapper extends StatelessWidget {

  final TRexGame tRexGame;
  GameWrapper(this.tRexGame);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          Container(
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              child: tRexGame.widget),
          Expanded(
            child: FaceContourDetectionScreen(),
          )
        ],
      ),
    );
  }
}

void main() async {
  Flame.audio.disableLog();
  List<ui.Image> image = await Flame.images.loadAll(["sprite.png"]);
//  TRexGame tRexGame = TRexGame(spriteImage: image[0]);
  gl.tRexGame = TRexGame(spriteImage: image[0]);
  runApp(MaterialApp(
    title: 'TRexGame',
    home: Scaffold(
      body: Login(),
    ),
  ));

  Flame.util.addGestureRecognizer(new TapGestureRecognizer()
    ..onTapDown = (TapDownDetails evt) => gl.tRexGame.onTap());

  SystemChrome.setEnabledSystemUIOverlays([]);
}




