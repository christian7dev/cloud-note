import 'package:cloud_note/firebase_options.dart';
import 'package:cloud_note/screens/login_screen.dart';
import 'package:cloud_note/services/entry_point.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        FlutterQuillLocalizations.delegate,
      ],
      title: 'Flutter Login Demo',
      debugShowCheckedModeBanner: false, // Remove debug banner
      theme: ThemeData(
          primarySwatch: Colors.deepPurple, // Or any other nice color swatch
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // Optional: Define text themes, button themes etc. for consistency
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none, // Hide default border line
            ),
            filled: true,
            fillColor: Colors.grey.shade200, // Light background for fields
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.deepPurple, // Text color on button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple, // Link color
              )
          )
      ),
      themeMode: ThemeMode.system,
      home: const EntryPoint(), // Start with the login page
    );
  }
}