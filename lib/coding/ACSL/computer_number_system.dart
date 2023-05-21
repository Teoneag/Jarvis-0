import 'package:flutter/material.dart';
import 'dart:core';

class ComputerNumberSystem extends StatefulWidget {
  const ComputerNumberSystem({super.key});

  @override
  State<ComputerNumberSystem> createState() => _ComputerNumberSystemState();
}

class _ComputerNumberSystemState extends State<ComputerNumberSystem> {
  final TextEditingController _ecuationC = TextEditingController();
  String selectedValue = b10;
  String resultFinal = '';

  @override
  void dispose() {
    _ecuationC.dispose();
    super.dispose();
  }

  int parseOperand(String operand) {
    if (operand.contains('_')) {
      List<String> parts = operand.split('_');
      int base = int.parse(parts[1], radix: 10); // Base is 10 by default

      return int.parse(parts[0], radix: base);
    } else {
      return int.parse(operand, radix: 10);
    }
  }

  void _updateResult() {
    try {
      final String equation = _ecuationC.text.replaceAll(' ', '');
      print('Done removing spaces: $equation');

      List<String> parts = equation.split(RegExp(r"[+\-*/]"));
      print('Done splitting: ');
      for (var part in parts) {
        print(part);
      }

      // final String equation = _ecuationC.text.replaceAll(' ', '');

      // List<String> numbers = equation.split(RegExp(r'\+|-|\*|/'));
      // List<String> operators = equation.split(RegExp(r'[0-9A-F_a-f]'));

      // // // Remove empty strings resulting from the split
      // // numbers.removeWhere((element) => element.isEmpty);
      // // operators.removeWhere((element) => element.isEmpty);

      // int result = parseOperand(
      //     numbers[0]); // Initialize the result with the first operand

      // // Perform calculations based on the operators and operands
      // for (int i = 0; i < operators.length; i++) {
      //   String operator = operators[i];
      //   int operand = parseOperand(numbers[i + 1]);

      //   if (operator == '+') {
      //     result += operand;
      //   } else if (operator == '-') {
      //     result -= operand;
      //   } else if (operator == '*') {
      //     result *= operand;
      //   } else if (operator == '/') {
      //     result ~/= operand; // Use integer division
      //   }
      // }

      // final String equation = '+${_ecuationC.text.replaceAll(' ', '')}';
      // print('Done removing spaces');

      // List<String> equationParts = equation.split(RegExp(r'\+|\-|\*|\/'));
      // print('Done splitting');
      // for (var part in equationParts) {
      //   print(part);
      // }

      // List<int> numbers = equationParts.map((part) {
      //   if (!part.contains('_')) {
      //     return int.parse(part);
      //   }
      //   String numberString = part.substring(0, part.indexOf('_'));
      //   int base = int.parse(part.substring(part.indexOf('_') + 1));
      //   if (numberString.isEmpty || ![2, 8, 10, 16].contains(base)) {
      //     print('Nr or base not good: $numberString, $base');
      //     return 0;
      //     // TODO: make red
      //   }

      //   return int.parse(numberString, radix: base);
      // }).toList();

      // print('Done getting the nr: ');
      // for (var number in numbers) {
      //   print(number);
      // }

      // List<String> operators = equation.split(RegExp(r'[0-9A-F_a-f]'));
      // print('Done getting operators: ');
      // for (var op in operators) {
      //   print(op);
      // }
      // print('');

      // int result = numbers[0];
      // for (int i = 1; i < numbers.length; i++) {
      //   print('This is i: $i, this is the result: $result');
      //   String operator = operators[i];
      //   int number = numbers[i];

      //   switch (operator) {
      //     case '+':
      //       result += number;
      //       break;
      //     case '-':
      //       result -= number;
      //       break;
      //     case '*':
      //       result *= number;
      //       break;
      //     case '/':
      //       result = result ~/ number;
      //       break;
      //     default:
      //       setState(() {
      //         // Handle invalid operator
      //       });
      //   }
      // }
      // setState(() {
      //   resultFinal = result.toString();
      // });
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
                  decoration: const InputDecoration(
                      hintText: 'Ecuation ex.:  F5AD_16 - 69EB_16'),
                ),
              ),
              const SizedBox(width: 10),
              Text('$resultFinal'),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: selectedValue,
                onChanged: (value) {
                  setState(() {
                    selectedValue = value ?? b10;
                  });
                },
                items: <String>[b2, b8, b10, b16]
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
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

const String b2 = '2';
const String b8 = '8';
const String b10 = '10';
const String b16 = '16';

// class Nr {
//   int value;
//   String base;

//   Nr({required this.value, required this.base});
// }
