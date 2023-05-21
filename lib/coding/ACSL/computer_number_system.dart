import 'package:flutter/material.dart';
// import 'dart:core';
import 'package:math_parser/math_parser.dart';

class ComputerNumberSystem extends StatefulWidget {
  const ComputerNumberSystem({super.key});

  @override
  State<ComputerNumberSystem> createState() => _ComputerNumberSystemState();
}

class _ComputerNumberSystemState extends State<ComputerNumberSystem> {
  final TextEditingController _ecuationC = TextEditingController();
  int _selectedBase = 10;
  String _resultFinal = '0.00';
  bool _isGood = false;

  @override
  void dispose() {
    _ecuationC.dispose();
    super.dispose();
  }

  void _updateResult() {
    setState(() {
      _isGood = false;
      _resultFinal = '0.00';
    });
    try {
      String equation = _ecuationC.text.replaceAll(' ', '');
      if (equation.isEmpty) {
        setState(() {
          _isGood = true;
          return;
        });
      }

      List<String> numbers = equation.split(RegExp(r"[+\-*/]"));
      for (var number in numbers) {
        String nrBase10 = number;
        if (number.contains('_')) {
          final parts = number.split('_');
          final base = int.parse(parts[1]);
          final numberString = parts[0];
          if (![2, 8, 10, 16].contains(base)) {
            return;
          }
          nrBase10 = int.parse(numberString, radix: base).toString();
        }
        equation = equation.replaceAll(number, nrBase10);
      }
      final expression = MathNodeExpression.fromString(equation);
      final result = expression.calc(MathVariableValues.none).toInt();
      final resultRightBase = result.toRadixString(_selectedBase).toUpperCase();
      setState(() {
        _resultFinal = resultRightBase.toString();
        _isGood = true;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Computer number system')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ecuationC,
                  onChanged: (value) => _updateResult(),
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: _isGood ? Colors.green : Colors.red,
                      hintText: 'Ecuation ex.:  F5AD_16 - 69EB_16'),
                ),
              ),
              const SizedBox(width: 10),
              Text('= $_resultFinal'),
              const SizedBox(width: 10),
              DropdownButton<int>(
                value: _selectedBase,
                onChanged: (value) {
                  setState(() {
                    _selectedBase = value ?? 10;
                  });
                  _updateResult();
                },
                items:
                    <int>[2, 8, 10, 16].map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class Nr {
//   int value;
//   String base;

//   Nr({required this.value, required this.base});
// }
