import 'package:flutter/material.dart';
import 'package:jarvis_0/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      routes: routes,
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jarvis0')),
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
                Navigator.of(context).pushNamed(Routes.coding);
              },
              child: const Text('Coding'),
            ),
          ],
        ),
      ),
    );
  }
}
