import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'home.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase, FirebaseOptions;


void main() async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      runApp(MaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.greenAccent,
          cardColor: Colors.blueAccent,
          useMaterial3: true,
        ),
        home: const Home(),
      ));
}