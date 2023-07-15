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

class BoolW {
  bool v;

  BoolW(this.v);
}

DateTime now = DateTime.now();

DateTime today10 = DateTime(now.year, now.month, now.day, 10, 0);

class SyncObj {
  final StateSetter setState;
  final BoolW isSyncing;

  SyncObj(this.setState, this.isSyncing);
}
