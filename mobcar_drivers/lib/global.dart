import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'methods/associate_methods.dart';

AssociateMethods associateMethods = AssociateMethods();

String driverName = "";
String driverPhone = "";
String carColor = "";
String carModel = "";
String carNumber = "";

String googleMapKey = "AIzaSyCt5a_lmSLofiH7VKMtm-r_hYkXt_kP92s";


const CameraPosition googlePlexInitialPosition = CameraPosition(
target: LatLng(37.42796133580664, -122.085749655962),
zoom: 14.4746,
);

StreamSubscription<Position>? positionStreamHomePage;

final audioPlayer = AssetsAudioPlayer();