import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vsix_downloader/extension_downloader.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VSIX Downloader',
      darkTheme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      themeMode: ThemeMode.system,
      home: const ExtensionDownloader(),
    );
  }
}
