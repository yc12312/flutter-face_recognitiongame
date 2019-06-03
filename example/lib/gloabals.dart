library example.globals;

import 'package:firebase_face_contour_example/game/Game.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

double temp = 0;

TRexGame tRexGame;

double point = 0;

FirebaseAuth auth;

int High =0;

String id = null;

DocumentReference ds_ref;

List <dynamic> Logs = new List();

bool once = true;

