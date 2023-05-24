import 'package:flutter/material.dart';
import 'package:jarvis_0/coding/ACSL/bases/methods_bases.dart';
import 'package:math_parser/math_parser.dart';

// TODO: Order of operations, so it doesn't need parantheses
// TODO: support | and &

class BitStringFlicking extends StatefulWidget {
  const BitStringFlicking({super.key});

  @override
  State<BitStringFlicking> createState() => _BitStringFlickingState();
}

class _BitStringFlickingState extends State<BitStringFlicking> {
  final TextEditingController _ecuationC = TextEditingController();
  String _resultFinal = '0';
  String _equation = '';
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
      _resultFinal = '0';
    });

    try {
      _equation = _ecuationC.text;
      while (_equation.contains('(')) {
        print(_equation);
        int i2 = _equation.indexOf(')');
        int i1 = i2 - 1;
        while (_equation[i1] != '(' && i1 > 0) {
          i1--;
        }
        i1++;
        String token = _equation.substring(i1, i2);
        _equation =
            _equation.replaceAll('($token)', MethodsBases.calculate(token));
      }
      setState(() {
        _isGood = true;
        _resultFinal = _equation;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          'Bit String flicking',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _ecuationC,
            onChanged: (value) => _updateResult(),
            decoration: InputDecoration(
                filled: true,
                fillColor: _isGood ? Colors.green : Colors.red,
                hintText:
                    'Ex: ((101110 AND (NOT 110110)) OR (LS3 101010))'), //(RS1 (LC4 (RC2 01101))) //(LS1 (10110 XOR ((RC3 abcde) AND 11011))) // ((RC14 (LC23 01101)) OR ((LS1 10011) AND (RS2 10111)))
          ),
        ),
        _isGood ? Text('= $_resultFinal') : Text('Error: $_errorMessage'),
      ],
    );
  }
}
