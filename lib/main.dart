import 'package:flutter/material.dart';
import 'package:sudoku_solver/pages/landing_page.dart';
import 'package:sudoku_solver/pages/sudoku.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'sudokuDLX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const LandingPage(),
    );
  }
}
