import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobcar_drivers/pages/dashboard.dart';
import 'package:mobcar_drivers/permissions/permission.dart';
import 'package:provider/provider.dart';

import 'appInfo/app_info.dart';
import 'auth/signin_page.dart';

void main() async
{
  WidgetsFlutterBinding.ensureInitialized();

  if(Platform.isAndroid)
  {
    await Firebase.initializeApp(
        name: "AgroTI",
        options: const FirebaseOptions(
            apiKey: "AIzaSyC4PVJOiuCCW7D8MhledgSX2a27IuQomaA",
            authDomain: "mob-car-android-app.firebaseapp.com",
            databaseURL: "https://mob-car-android-app-default-rtdb.firebaseio.com",
            projectId: "mob-car-android-app",
            storageBucket: "mob-car-android-app.firebasestorage.app",
            messagingSenderId: "929621081803",
            appId: "1:929621081803:web:085af6228838a80121a54e",
            measurementId: "G-S4T1YXL1PK"
        )
    );
  }
  else
  {
    await Firebase.initializeApp();
  }

  PermissionMethods permissionMethods = PermissionMethods();
  await permissionMethods.askLocationPermission();
  await permissionMethods.askNotificationPermission();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context)=> AppInfo(),
      child: MaterialApp(
        title: 'MobCar - Motorista',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: FirebaseAuth.instance.currentUser == null ? SignInPage() : Dashboard(),
      ),
    );
  }
}