import 'package:firebase_face_contour_example/face_contour_detection.dart';
import 'dart:ui' as ui;
import 'package:firebase_face_contour_example/gloabals.dart' as gl;

import 'package:flame/flame.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_face_contour_example/game/Game.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Login extends StatelessWidget {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user = await _auth.signInWithCredential(credential);
    return user;
  }

  Future<void> _HandleSignIn(BuildContext context) async {

    _onLoading(context);

    _handleSignIn()
        .then((FirebaseUser user){
      firestoreThing(user,context);
    }).catchError((e) => print(e));


  }

  Future<void> _handleAnomSignIn(BuildContext context) async {
    _onLoading(context);

      await _auth.signInAnonymously().then((FirebaseUser result){
        firestoreThing(result, context);

      }).catchError((e)=> print(e));
  }

  void _onLoading(BuildContext context) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              Text("   Loading"),
            ],
          ),
        );
      },
    );
  }

  void firestoreThing(FirebaseUser user, BuildContext context) async{

    gl.id = user.uid;

    CollectionReference _collectionReference = Firestore.instance.collection('users');

    _collectionReference.reference().where("id", isEqualTo: user.uid).getDocuments().then((QuerySnapshot ds){

      if(ds.documents.length < 1){
        _collectionReference.reference().add({'id': user.uid, 'score' : 0, 'email':user.email == null?'Anomoymous':user.email,'Log': gl.Logs})
            .whenComplete((){
          _collectionReference.reference().where("id", isEqualTo: user.uid).getDocuments().then((QuerySnapshot ds_){
            gl.ds_ref = ds_.documents[0].reference;

            ds_.documents.forEach((doc){
              gl.High = doc["score"];
              gl.Logs = List.from(doc["Log"]);
            });

            Navigator.pop(context);

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GameWrapper(gl.tRexGame)),
            );

          });
        });

      }
      else {
        gl.ds_ref = ds.documents[0].reference;

        ds.documents.forEach((doc){
          gl.High = doc["score"];
          gl.Logs = List.from(doc["Log"]);
        });

        Navigator.pop(context);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GameWrapper(gl.tRexGame)),
        );
      }
    });


    }

  @override
  Widget build(BuildContext context) {
    gl.auth = _auth;

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
              _HandleSignIn(context);
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

  //To enable Touch
//  Flame.util.addGestureRecognizer(new TapGestureRecognizer()
//    ..onTapDown = (TapDownDetails evt) => gl.tRexGame.onTap());

  SystemChrome.setEnabledSystemUIOverlays([]);
}




