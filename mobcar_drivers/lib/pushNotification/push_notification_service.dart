import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobcar_drivers/global.dart';
import 'package:mobcar_drivers/model/trip_details.dart';
import 'package:mobcar_drivers/widgets/loading_dialog.dart';
import 'package:mobcar_drivers/widgets/notification_dialog.dart';

class PushNotificationService
{
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<String?> generateDeviceRecognitionToken() async
  {
    String? deviceRecognitionToken = await firebaseMessaging.getToken();
    
    DatabaseReference ref = FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("deviceToken");
    ref.set(deviceRecognitionToken);

    firebaseMessaging.subscribeToTopic("drivers");
    firebaseMessaging.subscribeToTopic("users");
    return null;
  }

  startListeningForNewNotification(BuildContext context) async
  {
    ///1. Terminated
    //Quando o aplicativo é completamente fechado e recebe uma notificação push
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMsg)
    {
      if(remoteMsg != null)
      {
        String tripID = remoteMsg.data["tripID"];

        retrieveTripRequestInfo(tripID, context);
      }
    });

    ///2. Foreground
    //Quando o aplicativo é aberto e recebe uma notificação push
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMsg)
    {
      if(remoteMsg != null)
      {
        String tripID = remoteMsg.data["tripID"];

        retrieveTripRequestInfo(tripID, context);
      }
    });

    ///3. Background
    //Quando o aplicativo está em segundo plano e recebe uma notificação push
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMsg)
    {
      if(remoteMsg != null)
      {
        String tripID = remoteMsg.data["tripID"];

        retrieveTripRequestInfo(tripID, context);
      }
    });
  }

  retrieveTripRequestInfo(String tripID, BuildContext context)
  {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingDialog(messageText: "obtendo detalhes...",),
    );

    DatabaseReference tripRequestsRef = FirebaseDatabase.instance.ref().child("tripRequests").child(tripID);

    tripRequestsRef.once().then((dataSnapshot)
    {
      Navigator.pop(context);

      audioPlayer.open(
        Audio(
          "assets/alert_sound.mp3"
        )
      );

      audioPlayer.play();

      TripDetails tripDetailsInfo = TripDetails();
      double pickUpLat = double.parse((dataSnapshot.snapshot.value! as Map)["pickUpLatLng"]["latitude"]);
      double pickUpLng = double.parse((dataSnapshot.snapshot.value! as Map)["pickUpLatLng"]["longitude"]);
      tripDetailsInfo.pickUpLatLng = LatLng(pickUpLat, pickUpLng);

      tripDetailsInfo.pickupAddress = (dataSnapshot.snapshot.value! as Map)["pickUpAddress"];

      double dropOffLat = double.parse((dataSnapshot.snapshot.value! as Map)["dropOffLatLng"]["latitude"]);
      double dropOffLng = double.parse((dataSnapshot.snapshot.value! as Map)["dropOffLatLng"]["longitude"]);
      tripDetailsInfo.dropOffLatLng = LatLng(dropOffLat, dropOffLng);

      tripDetailsInfo.dropOffAddress = (dataSnapshot.snapshot.value! as Map)["dropOffAddress"];

      tripDetailsInfo.userName = (dataSnapshot.snapshot.value! as Map)["userName"];
      tripDetailsInfo.userPhone = (dataSnapshot.snapshot.value! as Map)["userPhone"];

      tripDetailsInfo.tripID = tripID;

      showDialog(
        context: context,
        builder: (BuildContext context) => NotificationDialog(tripDetailsInfo: tripDetailsInfo,),
      );
    });
  }
}
