import 'package:flutter/material.dart';
import '/coding/ACSL/computer_number_system.dart';
import '/coding/ACSL/prefix_infix_postfix.dart';
import '/coding/coding_screen.dart';
import '/main.dart';
import '/superbet_calculator/superbet_calculator.dart';

class Routes {
  static const String home = '/';
  static const String superbetCalculator = '/superbetCalculator';
  static const String coding = '/coding';
  static const String acslComputerNumberSystem = '/acslComputerNumberSystem';
  static const String acslPrefixPostfixInfix = '/acslPrefixPostfixInfix';
}

final Map<String, WidgetBuilder> routes = {
  Routes.superbetCalculator: (context) => const SuperBetCalculator(),
  Routes.home: (context) => const MyHomePage(),
  Routes.coding: (context) => const CodingScreen(),
  Routes.acslComputerNumberSystem: (context) => const ComputerNumberSystem(),
  Routes.acslPrefixPostfixInfix: (context) => const PrefixInfixPostfix(),
};
