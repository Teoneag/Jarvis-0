import 'package:flutter/material.dart';
import '/main.dart';
import '/superbet/contract_model.dart';
import '../superbet/screens/contract_screen.dart';
import '../superbet/screens/contracts_screen.dart';
import '../superbet/screens/superbet_screen.dart';
import '/coding/coding_screen.dart';
import '/coding/ACSL/bases/bases.dart';
import '/coding/ACSL/prefix_infix_postfix/prefix_infix_postfix.dart';
import '../superbet/screens/superbet_calculator_screen.dart';

class Routes {
  static const String home = '/';
  static const String superbetScreen = '/superbetScreen';
  static const String superbetCalculator = '/superbetCalculator';
  static const String superbetContractsList = '/superbetContractsList';
  static const String superbetContract = '/superbetContract';
  static const String codingScreen = '/codingScreen';
  static const String acslComputerNumberSystem = '/acslComputerNumberSystem';
  static const String acslPrefixPostfixInfix = '/acslPrefixPostfixInfix';
}

final Map<String, WidgetBuilder> routes = {
  Routes.home: (context) => const HomePage(),
  Routes.superbetScreen: (context) => const SuperbetScreen(),
  Routes.superbetCalculator: (context) => const SuperbetCalculatorScreen(),
  Routes.superbetContractsList: (context) => const SuperbetContractsScreen(),
  Routes.codingScreen: (context) => const CodingScreen(),
  Routes.acslComputerNumberSystem: (context) => const Bases(),
  Routes.acslPrefixPostfixInfix: (context) => const PrefixInfixPostfix(),
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
