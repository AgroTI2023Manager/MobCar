import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobcar_drivers/pushNotification/push_notification_service.dart';

import '../auth/signin_page.dart';
import '../global.dart';
import '../methods/google_map_methods.dart';
import '../permissions/permission.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
{
  double bottomMapPadding = 0;
  final Completer<GoogleMapController> googleMapCompleterController = Completer<GoogleMapController>();
  GoogleMapController? controllerGoogleMap;
  Position? currentPositionOfDriver;
  double searchContainerHeight = 220;
  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  DatabaseReference? newTripRequestReference;
  bool isDriverAvailable = false;
  Color colorToShow = Colors.black;
  String titleToShow = "ENTRE ONLINE AGORA";
  PermissionMethods permissionMethods = PermissionMethods();


  getCurrentLocation() async
  {
    Position userPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPositionOfDriver = userPosition;

    LatLng userLatLng = LatLng(currentPositionOfDriver!.latitude, currentPositionOfDriver!.longitude);

    CameraPosition positionCamera = CameraPosition(target: userLatLng, zoom: 15);
    controllerGoogleMap!.animateCamera(CameraUpdate.newCameraPosition(positionCamera));

    await GoogleMapMethods.convertGeoGraphicCoOrdinatesIntoHumanReadableAddress(currentPositionOfDriver!, context);

    await getDriverInfoAndCheckBlockStatus();

    await initializePushNotificationSystem();

    await permissionMethods.askNotificationPermission();


  }

  getDriverInfoAndCheckBlockStatus() async
  {
    DatabaseReference reference = FirebaseDatabase.instance.ref().child("drivers").child(FirebaseAuth.instance.currentUser!.uid);

    await reference.once().then((dataSnap)
    {
      if(dataSnap.snapshot.value != null)
      {
        if((dataSnap.snapshot.value as Map)["blockStatus"] == "no")
        {
          setState(() {
            driverName = (dataSnap.snapshot.value as Map)["name"];
            driverPhone = (dataSnap.snapshot.value as Map)["phone"];

            carColor = (dataSnap.snapshot.value as Map)["car_details"]["carColor"];
            carModel = (dataSnap.snapshot.value as Map)["car_details"]["carModel"];
            carNumber = (dataSnap.snapshot.value as Map)["car_details"]["carNumber"];
          });
        }
        else
        {
          FirebaseAuth.instance.signOut();
          Navigator.push(context, MaterialPageRoute(builder: (c)=> SignInPage()));
          associateMethods.showSnackBarMsg("você está bloqueado. Contate o administrador: agrotierp@gmail.com", context);
        }
      }
      else
      {
        FirebaseAuth.instance.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (c)=> SignInPage()));
      }
    });
  }

  goOnline()
  {
    //todos os motoristas que estão disponíveis para novas solicitações de viagem
    Geofire.initialize("onlineDrivers");
    
    Geofire.setLocation(
      FirebaseAuth.instance.currentUser!.uid,
      currentPositionOfDriver!.latitude,
      currentPositionOfDriver!.longitude,
    );

    newTripRequestReference = FirebaseDatabase.instance.ref()
        .child("drivers")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("newTripStatus");

    newTripRequestReference!.set("waiting");

    newTripRequestReference!.onValue.listen((event){});
  }

  setAndGetLocationUpdates()
  {
    positionStreamHomePage = Geolocator.getPositionStream().listen((Position position)
    {
      currentPositionOfDriver = position;

      if(isDriverAvailable == true)
      {
        Geofire.setLocation(
          FirebaseAuth.instance.currentUser!.uid,
          currentPositionOfDriver!.latitude,
          currentPositionOfDriver!.longitude,
        );
      }

      LatLng positionLatLng = LatLng(position.latitude, position.longitude);
      controllerGoogleMap!.animateCamera(CameraUpdate.newLatLng(positionLatLng));
    });
  }

  goOffline()
  {
    //pare de compartilhar atualizações de localização ao vivo do driver
    Geofire.removeLocation(FirebaseAuth.instance.currentUser!.uid);

    //pare de ouvir o newTripStatus
    newTripRequestReference!.onDisconnect();
    newTripRequestReference!.remove();
    newTripRequestReference = null;
  }

  initializePushNotificationSystem()
  {
    PushNotificationService notificationService = PushNotificationService();
    notificationService.generateDeviceRecognitionToken();
    notificationService.startListeningForNewNotification(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: sKey,

      ///google map
      body: Stack(
        children: [

          GoogleMap(
            padding: EdgeInsets.only(top: 26, bottom: bottomMapPadding),
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: googlePlexInitialPosition,
            onMapCreated: (GoogleMapController mapController)
            {
              controllerGoogleMap = mapController;

              googleMapCompleterController.complete(controllerGoogleMap);

              getCurrentLocation();
            },
          ),

          Container(
            height: 136,
            width: double.infinity,
            color: Colors.white,
          ),

          ///botão ir online offline
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ElevatedButton(
                  onPressed: ()
                  {
                    showModalBottomSheet(
                      context: context,
                      isDismissible: false,
                      builder: (BuildContext context)
                      {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5.0,
                                spreadRadius: 0.5,
                                offset: Offset(
                                  0.7,
                                  0.7,
                                ),
                              )
                            ]
                          ),
                          height: 222,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                            child: Column(
                              children: [

                                const SizedBox(height: 12,),

                                Text(
                                    (!isDriverAvailable) ? "ENTRE ONLINE AGORA" : "FIQUE OFFLINE AGORA",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 21,),

                                Text(
                                    (!isDriverAvailable)
                                        ? "Você está prestes a ficar online e ficará disponível para receber solicitações de viagens de usuários."
                                        : "Você está prestes a ficar offline e não receberá mais novas solicitações de viagem dos usuários.",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.black45,
                                  ),
                                ),

                                const SizedBox(height: 25,),

                                Row(
                                  children: [


                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: ()
                                        {
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                        ),
                                        child: const Text(
                                          "VOLTAR",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),



                                    const SizedBox(width: 16,),


                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: ()
                                        {
                                          if(!isDriverAvailable)
                                          {
                                            goOnline();

                                            setAndGetLocationUpdates();

                                            Navigator.pop(context);

                                            setState(() {
                                              colorToShow = Colors.blue;
                                              titleToShow = "FIQUE OFFLINE AGORA";
                                              isDriverAvailable = true;
                                            });
                                          }
                                          else
                                          {
                                            goOffline();

                                            Navigator.pop(context);

                                            setState(() {
                                              colorToShow = Colors.black;
                                              titleToShow = "ENTRE ONLINE AGORA";
                                              isDriverAvailable = false;
                                            });
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: (titleToShow == "ENTRE ONLINE AGORA") ? Colors.black : Colors.green,
                                        ),
                                        child: const Text(
                                            "CONFIRMA",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),


                                  ],
                                )


                              ],
                            ),
                          ),
                        );
                      }
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorToShow,
                  ),
                  child: Text(
                    titleToShow,
                    style: const TextStyle(
                      color: Colors.white,
                    ),

                  )
                ),

              ],

            ),
          ),


        ],
      ),

    );
  }
}