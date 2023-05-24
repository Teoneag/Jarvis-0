import 'package:infix_expression_parser/infix_expression_converter.dart';

class MethodsPrefInfPos {
  static bool _isOperator(String str) {
    return str == '+' ||
        str == '-' ||
        str == '*' ||
        str == '/' ||
        str == '^' ||
        str == '↑';
  }

  static String prefToInf(String equation) {
    List<String> equationParts = equation.split(" ");
    try {
      List<String> stack = [];
      int i = equationParts.length - 1;
      for (i; i >= 0; i--) {
        if (!_isOperator(equationParts[i])) {
          stack.insert(0, equationParts[i]);
        } else {
          String str = "(${stack[0]}${equationParts[i]}${stack[1]})";
          stack.removeAt(0);
          stack.removeAt(0);
          stack.insert(0, str);
        }
      }
      return stack[0];
    } catch (e) {
      return 'Error: $e';
    }
  }

  static String prefToPost(String equation) {
    List<String> equationParts = equation.split(" ");
    try {
      List<String> stack = [];
      for (int i = equationParts.length - 1; i >= 0; i--) {
        if (!_isOperator(equationParts[i])) {
          stack.add(equationParts[i]);
        } else {
          String operand1 = stack.removeLast();
          String operand2 = stack.removeLast();
          String str = "$operand1 $operand2 ${equationParts[i]}";
          stack.add(str);
        }
      }
      return stack[0];
    } catch (e) {
      return 'Error: $e';
    }
  }

  static String postToInf(String equation) {
    List<String> equationParts = equation.split(" ");
    try {
      List<String> stack = [];
      for (int i = 0; i < equationParts.length; i++) {
        if (!_isOperator(equationParts[i])) {
          stack.add(equationParts[i]);
        } else {
          String str =
              "(${stack[stack.length - 2]} ${equationParts[i]} ${stack[stack.length - 1]})";
          stack.removeRange(stack.length - 2, stack.length);
          stack.add(str);
        }
      }
      return stack[0];
    } catch (e) {
      return 'Error: $e';
    }
  }

  static String postToPref(String equation) {
    List<String> equationParts = equation.split(" ");
    try {
      List<String> stack = [];
      for (int i = 0; i < equationParts.length; i++) {
        if (!_isOperator(equationParts[i])) {
          stack.add(equationParts[i]);
        } else {
          String operand2 = stack.removeLast();
          String operand1 = stack.removeLast();
          String str = "${equationParts[i]} $operand1 $operand2";
          stack.add(str);
        }
      }
      return stack[0];
    } catch (e) {
      return 'Error: $e';
    }
  }

  static String _toX(String equation, bool isPre) {
    if (isPre) {
      return InfixExpressionConverter(expression: equation).toPrefixNotation();
    }
    return InfixExpressionConverter(expression: equation).toPostfixNotation();
  }

  static String infToX(String equation, bool isPre) {
    if (!equation.contains('=')) {
      return _toX(equation, isPre);
    }
    final equationParts = equation.split('=');
    final prefix1 = _toX(equationParts[0], isPre);
    final prefix2 = _toX(equationParts[1], isPre);
    return '= $prefix1 $prefix2';
  }
}
