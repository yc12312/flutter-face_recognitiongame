import 'dart:ui';

import 'package:flame/game.dart';
import 'package:firebase_face_contour_example/game/Horizon/horizon.dart';
import 'package:firebase_face_contour_example/game/collision/collision_utils.dart';
import 'package:firebase_face_contour_example/game/game_config.dart';
import 'package:firebase_face_contour_example/game/game_over/game_over.dart';
import 'package:firebase_face_contour_example/game/t_rex/config.dart';
import 'package:firebase_face_contour_example/game/t_rex/t_rex.dart';

import 'package:firebase_face_contour_example/gloabals.dart' as gl;

import 'package:cloud_firestore/cloud_firestore.dart';

enum TRexGameStatus { playing, waiting, gameOver }

class TRexGame extends BaseGame {

  TRex tRex;
  Horizon horizon;
  GameOverPanel gameOverPanel;
  TRexGameStatus status = TRexGameStatus.waiting;

  double currentSpeed = GameConfig.speed;
  double timePlaying = 0.0;

  TRexGame({Image spriteImage}) {
    tRex = new TRex(spriteImage);
    horizon = new Horizon(spriteImage);
    gameOverPanel = new GameOverPanel(spriteImage);

    this..add(horizon)..add(tRex)..add(gameOverPanel);
  }

  void onTap() {
    if (gameOver) {
      restart();
      return;
    }
    tRex.startJump(this.currentSpeed);
  }

  void updateFirestoreHigh(int high) async{
    DocumentReference ds_ref = gl.ds_ref;

    Firestore.instance.runTransaction((Transaction tx) async {

      DocumentSnapshot scoresnapthot = await tx.get(ds_ref);
      if (scoresnapthot.exists) {
        await tx.update(ds_ref, <String, dynamic>{'score': high});
      }
    });
  }

  //To D0: Update -> UI 제작
  void updateFirestoreLog(int score) async{

    DocumentReference ds_ref = gl.ds_ref;

    gl.Logs.add(score);

    Firestore.instance.runTransaction((Transaction tx) async {

      DocumentSnapshot scoresnapthot = await tx.get(ds_ref);
      if (scoresnapthot.exists) {
        await tx.update(ds_ref, <String, dynamic>{'Log': gl.Logs});
      }
    });
  }

  @override
  void update(double t) {

    tRex.update(t);
    horizon.updateWithSpeed(0.0, this.currentSpeed);

    if (gameOver){

      if(gl.once){

        if(gl.point.round()>gl.High){
          gl.High = gl.point.round();
          updateFirestoreHigh(gl.High);
        }

        updateFirestoreLog(gl.point.round());

        gl.once = false;
      }

      return;
    }

    if (tRex.playingIntro && tRex.x >= TRexConfig.startXPos) {
      startGame();
    } else if (tRex.playingIntro) {
      horizon.updateWithSpeed(0.0, this.currentSpeed);
    }

    if (this.playing) {
      gl.point = timePlaying;
      timePlaying += t;
      horizon.updateWithSpeed(t, this.currentSpeed);

      var obstacles = horizon.horizonLine.obstacleManager.components;
      bool collision =
          obstacles.length > 0 && checkForCollision(obstacles.first, tRex);
      if (!collision) {
        if (this.currentSpeed < GameConfig.maxSpeed) {
          this.currentSpeed += GameConfig.acceleration;
        }
      } else {
        doGameOver();
      }
    }
  }

  void startGame() {
    tRex.status = TRexStatus.running;
    status = TRexGameStatus.playing;
    tRex.hasPlayedIntro = true;
  }

  bool get playing => status == TRexGameStatus.playing;
  bool get gameOver => status == TRexGameStatus.gameOver;

  void doGameOver() {
    this.gameOverPanel.visible = true;
    stop();
    tRex.status = TRexStatus.crashed;
  }

  void stop() {
    this.status = TRexGameStatus.gameOver;
  }

  void restart() {
    status = TRexGameStatus.playing;
    tRex.reset();
    horizon.reset();
    currentSpeed = GameConfig.speed;
    gameOverPanel.visible = false;
    timePlaying = 0.0;
    gl.once = true;
  }
}
