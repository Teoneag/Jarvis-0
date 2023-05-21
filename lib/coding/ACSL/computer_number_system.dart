import 'package:flutter/material.dart';
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
  String _equationBase10 = '';
  String _errorMessage = '';
  bool _isGood = true;

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

      List<String> numbers =
          equation.split(RegExp(r"[+\-*/]")); // 10 + 2_16 - F_16
      for (var number in numbers) {
        String nrBase10 = number;
        if (!number.contains('_')) {
          continue;
        }
        final parts = number.split('_');
        final base = int.parse(parts[1]);
        final numberString = parts[0];
        if (![2, 8, 10, 16].contains(base)) {
          return;
        }
        nrBase10 = int.parse(numberString, radix: base).toString();
        _equationBase10 = _equationBase10.replaceAll(number, nrBase10);
      }

      final resultRightBase = MathNodeExpression.fromString(_equationBase10)
          .calc(MathVariableValues.none)
          .toInt()
          .toRadixString(_selectedBase)
          .toUpperCase();

      setState(() {
        _equationBase10;
        _resultFinal = resultRightBase.toString();
        _isGood = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Computer number system')),
      body: Column(
        children: [
          Padding(
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
                        hintText: 'Ex: F5AD_16 - (5 + 10_8) * 1110_2'),
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
                  items: <int>[2, 8, 10, 16]
                      .map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          _isGood
              ? Text(
                  'Your equation converted to base 10 is: " $_equationBase10 "')
              : Text('Error: $_errorMessage')
        ],
      ),
    );
  }
}
