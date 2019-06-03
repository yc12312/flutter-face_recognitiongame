import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_face_contour_example/face_contour_painter.dart';
import 'package:firebase_face_contour_example/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_face_contour/firebase_face_contour.dart';

import 'package:firebase_face_contour_example/gloabals.dart' as gl;

import 'package:flutter_share_me/flutter_share_me.dart';

import 'package:flutter_sparkline/flutter_sparkline.dart';


class FaceContourDetectionScreen extends StatefulWidget {
  @override
  _FaceContourDetectionScreenState createState() =>
      _FaceContourDetectionScreenState();
}

class _FaceContourDetectionScreenState
    extends State<FaceContourDetectionScreen> {
  final FaceDetector faceDetector = FirebaseVision.instance.faceDetector(
      FaceDetectorOptions(
          enableClassification: true,
          enableLandmarks: false,
          enableContours: true,
          enableTracking: false));
  List<Face> faces;
  CameraController _camera;
  bool cameraEnabled = true;
  bool _isDetecting = false;
  CameraLensDirection _direction = CameraLensDirection.front;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {

    CameraDescription description = await getCamera(_direction);
    ImageRotation rotation = rotationIntToImageRotation(
      description.sensorOrientation,
    );

    _camera = CameraController(
      description,
      defaultTargetPlatform == TargetPlatform.iOS
          ? ResolutionPreset.low
          : ResolutionPreset.medium,
    );
    await _camera.initialize();

    _camera.startImageStream((CameraImage image) {
      if (_isDetecting) return;

      _isDetecting = true;

      detect(image, faceDetector.processImage, rotation).then(
        (dynamic result) {
          setState(() {
            faces = result;
          });

          _isDetecting = false;
        },
      ).catchError(
        (_) {
          _isDetecting = false;
        },
      );
    });
  }

  void _toggleCameraDirection() async {
    if (_direction == CameraLensDirection.back) {
      _direction = CameraLensDirection.front;
    } else {
      _direction = CameraLensDirection.back;
    }

    await _camera.stopImageStream();
    await _camera.dispose();

    setState(() {
      _camera = null;
    });

    _initializeCamera();
  }

  void showLeaderBoard(BuildContext context) {

    List<DocumentSnapshot> scoreBoard = new List();
    DocumentSnapshot temp;

    Firestore.instance.collection('users')
        .getDocuments().then((ds){
          scoreBoard = ds.documents;

          scoreBoard.sort((a, b) => b["score"].compareTo(a["score"]));

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: new Text("Score Board"),
                content: new Text("[Top 3 Scores]\n"
                    +"1. "+ scoreBoard[0]["email"].toString() +" "+ scoreBoard[0]["score"].toString()
                    + "\n2. "+scoreBoard[1]["email"].toString() +" "+ scoreBoard[1]["score"].toString()
                    +"\n3. "+ scoreBoard[2]["email"].toString() +" "+ scoreBoard[2]["score"].toString()),
                actions: <Widget>[
                  FlatButton(
                    child: new Text("Close"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            },
          );

    });

  }

  void showMyLog(BuildContext context) {

    List<double> data = new List();

    for(int i=0; i< gl.Logs.length; i++){
      data.add(gl.Logs[i].toDouble());
    }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("My Score History"),
            content: Container(
              height: 400.0,
              child: Column(
                children: <Widget>[
                  Text("[Score History]\n"),
                  Container(
                    height: 300.0,
                      child: Sparkline(data: data,))
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
  }

  void singOut() async{
    await gl.auth.signOut().whenComplete((){
      gl.High = 0;
      gl.point = 0;
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Point: "+gl.point.round().toString()),
        leading: IconButton(icon: Icon(Icons.arrow_back),
            onPressed: (){
              singOut();
            }),
        actions: <Widget>[
          IconButton(
              icon:
                  Icon(cameraEnabled ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  cameraEnabled = !cameraEnabled;
                });
              }),
          IconButton(
              icon:
              Icon(Icons.assessment),
              onPressed: () {
                showLeaderBoard(context);
              }),
          IconButton(
              icon:
              Icon(Icons.equalizer),
              onPressed: () {
                showMyLog(context);
              })

        ],
      ),
      body: _camera == null
          ? const Center(
        child: Text(
          'Initializing Camera...',
          style: TextStyle(
            color: Colors.green,
            fontSize: 30.0,
          ),
        ),
      )
          : LiveCameraWithFaceDetection(
        faces: faces,
        camera: _camera,
        cameraEnabled: cameraEnabled,

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleCameraDirection,
        child: _direction == CameraLensDirection.back
            ? const Icon(Icons.camera_front)
            : const Icon(Icons.camera_rear),
      ),
    );
  }
}

class LiveCameraWithFaceDetection extends StatelessWidget {
  final List<Face> faces;
  final CameraController camera;
  final bool cameraEnabled;

  const LiveCameraWithFaceDetection(
      {Key key, this.faces, this.camera, this.cameraEnabled = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          cameraEnabled
              ? CameraPreview(camera)
              : Container(
                  color: Colors.black,
                ),
          (faces != null && camera.value.isInitialized)
              ? CustomPaint(
                painter: FaceContourPainter(
                    Size(
                      camera.value.previewSize.height,
                      camera.value.previewSize.width,
                    ),
                    faces,
                    camera.description.lensDirection),
              ): Text("Nothing")
        ],
      ),
    );
  }
}
