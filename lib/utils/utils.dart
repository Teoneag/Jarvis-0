import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:math_parser/math_parser.dart';

const successS = 'success';

Widget loadingCenter() {
  return const Center(
    child: CircularProgressIndicator(),
  );
}

formatDate1(DateTime date) {
  return DateFormat('dd/MM/yy').format(date);
}

calc(String equation) {
  try {
    return MathNodeExpression.fromString(equation)
        .calc(MathVariableValues.none)
        .toDouble();
  } catch (e) {
    return 0;
  }
}

class BoolWrapper {
  bool value;

  BoolWrapper(this.value);
}

DateTime now = DateTime.now();

DateTime today10 = DateTime(now.year, now.month, now.day, 10, 0);
