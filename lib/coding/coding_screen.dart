import 'package:flutter/material.dart';
import 'package:jarvis_0/routes.dart';

class CodingScreen extends StatelessWidget {
  const CodingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coding')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ACSL',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(Routes.acslComputerNumberSystem);
              },
              child: const Text('Bases'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(Routes.acslPrefixPostfixInfix);
              },
              child: const Text('Prefix Postfix Infix Notation'),
            ),
          ],
        ),
      ),
    );
  }
}
