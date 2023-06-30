import 'package:flutter/material.dart';
import 'package:jarvis_0/todo/todo_screen.dart';
import '/main.dart';
import '/superbet/screens/superbet_screen.dart';
import '/superbet/contract_model.dart';
import '/superbet/screens/superbet_calculator_screen.dart';
import '/superbet/screens/contract_screen.dart';
import '/superbet/screens/contracts_screen.dart';
// import '../superbet/screens/automation_screen.dart';
import '/coding/coding_screen.dart';
import '/coding/ACSL/bases/bases.dart';
import '/coding/ACSL/prefix_infix_postfix/prefix_infix_postfix.dart';
import '/todo/todo_tag.dart';

class Routes {
  static const String homeScreen = '/';
  static const String superbetScreen = '/superbetScreen';
  static const String superbetCalculator = '/superbetCalculator';
  static const String superbetContractsList = '/superbetContractsList';
  static const String superbetContract = '/superbetContract';
  // static const String superbetAuto = '/superbetAuto';
  static const String codingScreen = '/codingScreen';
  static const String acslComputerNumberSystem = '/acslComputerNumberSystem';
  static const String acslPrefixPostfixInfix = '/acslPrefixPostfixInfix';
  static const String todoScreen = '/todoScreen';
  static const String todoTagScreen = '/todoTagScreen';
}

final Map<String, WidgetBuilder> routes = {
  Routes.homeScreen: (context) => const HomePage(),
  Routes.superbetScreen: (context) => const SuperbetScreen(),
  Routes.superbetCalculator: (context) => const SuperbetCalculatorScreen(),
  Routes.superbetContractsList: (context) => const SuperbetContractsScreen(),
  // Routes.superbetAuto: (context) => const SuperbetAuto(),
  Routes.codingScreen: (context) => const CodingScreen(),
  Routes.acslComputerNumberSystem: (context) => const Bases(),
  Routes.acslPrefixPostfixInfix: (context) => const PrefixInfixPostfix(),
  Routes.todoScreen: (context) => const TodoScreen(),
  Routes.todoTagScreen: (context) => const TodoTagScreen(),
};

Route<dynamic> generateLocalRoutes(settings) {
  switch (settings.name) {
    case Routes.superbetContract:
      return MaterialPageRoute(
          builder: (context) =>
              SuperbetContractScreen(contract: settings.arguments as Contract));
    default:
      return MaterialPageRoute(builder: routes[settings.name]!);
  }
}
