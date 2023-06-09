import 'package:flutter/material.dart';
import '../../utils/routes.dart';

class SuperbetScreen extends StatelessWidget {
  const SuperbetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Superbet')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(Routes.superbetCalculator);
              },
              child: const Text('Superbet calculator'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(Routes.superbetContractsList);
              },
              child: const Text('Contracts with people'),
            ),
          ],
        ),
      ),
    );
  }
}
