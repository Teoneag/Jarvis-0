import 'package:flutter/material.dart';
import '/coding/ACSL/bases/bit_string_flicking.dart';
import '/coding/ACSL/bases/computer_number_system.dart';

class Bases extends StatelessWidget {
  const Bases({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bases')),
      body: const Column(
        children: [
          ComputerNumberSystem(),
          BitStringFlicking(),
        ],
      ),
    );
  }
}
