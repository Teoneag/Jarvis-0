import 'package:flutter/material.dart';
import 'methods_prefix_infix_postfix.dart';

// TODO: Automatically detect if it's pre, inf, pos
// TODO: Error handeling

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

  void _updateResult() {
    setState(() {
      _isGood = false;
    });

    try {
      // String equation = _ecuationC.text.replaceAll(' ', '');
      String equation = _ecuationC.text.replaceAll('↑', '^');

      if (equation.isEmpty) {
        setState(() {
          _isGood = true;
          return;
        });
      }

      switch (_selectedNotation) {
        case 0: // prefix: ↑ + * 3 4 / 8 2 – 7 5
          _prefixResult = equation;
          _infixResult = MethodsPrefInfPos.prefToInf(equation);
          _postfixResult = MethodsPrefInfPos.prefToPost(equation);

          break;
        case 1: //infix: (X = (((A * B) - (C / D)) ↑ E))
          _prefixResult = MethodsPrefInfPos.infToX(equation, true);
          _infixResult = equation;
          _postfixResult = MethodsPrefInfPos.infToX(equation, false);
          break;
        case 2: //postfix: 3 4 * 8 2 / + 7 5 - ↑
          _prefixResult = MethodsPrefInfPos.postToPref(equation);
          _infixResult = MethodsPrefInfPos.postToInf(equation);
          _postfixResult = equation;
          break;
      }

      setState(() {
        _infixResult;
        _postfixResult;
        _prefixResult;
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
