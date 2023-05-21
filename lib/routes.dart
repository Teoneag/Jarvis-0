import 'package:flutter/material.dart';
import 'package:jarvis_0/coding/ACSL/computer_number_system.dart';
import 'package:jarvis_0/coding/coding_screen.dart';
import 'package:jarvis_0/main.dart';
import 'package:jarvis_0/superbet_calculator/superbet_calculator.dart';

class Routes {
  static const String home = '/';
  static const String superbetCalculator = '/superbetCalculator';
  static const String coding = '/coding';
  static const String acslComputerNumberSystem = '/acslComputerNumberSystem';
}

final Map<String, WidgetBuilder> routes = {
  Routes.superbetCalculator: (context) => const SuperBetCalculator(),
  Routes.home: (context) => const MyHomePage(),
  Routes.coding: (context) => const CodingScreen(),
  Routes.acslComputerNumberSystem: (context) => const ComputerNumberSystem(),
};
