import 'package:flutter/material.dart';
import 'package:infix_expression_parser/infix_expression_converter.dart';

class PrefixInfixPostfix extends StatefulWidget {
  const PrefixInfixPostfix({super.key});

  @override
  State<PrefixInfixPostfix> createState() => _PrefixInfixPostfixState();
}

List<String> notations = ['Prefix', 'Infix', 'Postfix'];

class _PrefixInfixPostfixState extends State<PrefixInfixPostfix> {
  final TextEditingController _ecuationC = TextEditingController();
  int _selectedNotation = 1;
  String _prefixResult = '';
  String _infixResult = '';
  String _postfixResult = '';
  String _errorMessage = '';
  bool _isGood = true;

  @override
  void dispose() {
    _ecuationC.dispose();
    super.dispose();
  }

  bool isOperator(String x) {
    switch (x) {
      case "+":
      case "-":
      case "/":
      case "*":
      case "^":
      case "%":
        return true;
    }
    return false;
  }

  String preToInfix(String prefixEquation) {
    print('Starting');
    try {
      List<String> stack = [];
      int i = prefixEquation.length - 1;
      for (i; i >= 0; i--) {
        print('i: $i');
        print(stack);
        if (!isOperator(prefixEquation[i])) {
          stack.insert(0, prefixEquation[i]);
        } else {
          String str = "(${stack[0]}${prefixEquation[i]}${stack[1]})";
          print('str: $str');
          stack.removeAt(0);
          stack.removeAt(0);
          stack.insert(0, str);
        }
      }
      return stack[0];
    } catch (e) {
      print(e);
      return '';
    }
  }

  void _updateResult() {
    print("Done: ${preToInfix('+ 3 4')}");
    setState(() {
      _isGood = false;
    });

    try {
      String equation = _ecuationC.text.replaceAll(' ', '');
      equation = equation.replaceAll('↑', '^');

      if (equation.isEmpty) {
        setState(() {
          _isGood = true;
          return;
        });
      }

      String postfix = '';
      String prefix = '';
      String infix = '';
      switch (_selectedNotation) {
        case 0: // prefix

          break;
        case 1: //infix
          if (equation.contains('=')) {
            final equation1 = equation.split('=')[0];
            final equation2 = equation.split('=')[1];
            // print('$equation1, $equation2');
            final converter1 = InfixExpressionConverter(expression: equation1);
            final postfix1 = converter1.toPostfixNotation();
            final prefix1 = converter1.toPrefixNotation();

            final converter2 = InfixExpressionConverter(expression: equation2);
            final postfix2 = converter2.toPostfixNotation();
            final prefix2 = converter2.toPrefixNotation();

            prefix = '= $prefix1 $prefix2';
            postfix = '$postfix1 $postfix2 =';
            infix = equation;
          } else {
            final converter = InfixExpressionConverter(expression: equation);
            postfix = converter.toPostfixNotation();
            prefix = converter.toPrefixNotation();
            infix = equation;
          }

          break;
        case 2: //postfix
          break;
      }
      setState(() {
        _infixResult = infix;
        _postfixResult = postfix;
        _prefixResult = prefix;
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
      appBar: AppBar(title: const Text('Prefix Postfix Infix Notation')),
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
                        hintText: 'Ex: (X = (((A * B) - (C / D)) ↑ E))'),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: notations[_selectedNotation],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedNotation = notations
                          .indexWhere((element) => element == newValue);
                    });
                    _updateResult();
                  },
                  items:
                      notations.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          if (!_isGood)
            Text('Error: $_errorMessage')
          else
            Column(
              children: [
                Text('Prefix: " $_prefixResult "'),
                Text('Infix: " $_infixResult "'),
                Text('Postfix: " $_postfixResult "'),
              ],
            ),
        ],
      ),
    );
  }
}
