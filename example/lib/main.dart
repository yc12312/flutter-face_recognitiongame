import 'package:firebase_face_contour_example/face_contour_detection.dart';
import 'dart:ui' as ui;
import 'gloabals.dart' as gl;

import 'package:flame/flame.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_face_contour_example/game/Game.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Login extends StatelessWidget {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      await _googleSignIn.signIn().then((result)=>{
      Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GameWrapper(gl.tRexGame)),
                )
      });
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleAnomSignIn(BuildContext context) async {

    try {
      await _auth.signInAnonymously().then((result)=>{
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GameWrapper(gl.tRexGame)),
      )
      });
    } catch (error) {
      print(error);
    }
  }

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
          Text('LAZY DINO',
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold
          ),),
          SizedBox(
            height: 50.0,
          ),
          Center(
            child: RaisedButton(
              child: Text('Google Login'),
              onPressed: () {
                _handleSignIn(context);
              },
            ),
          ),
          Center(
            child: RaisedButton(
              child: Text('Anonoymous Login'),
              onPressed: () {
                _handleAnomSignIn(context);
              },
            ),
          )
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




