import 'package:flutter/material.dart';

class Bet {
  final String uid;
  bool isOk = false;
  int lastInput = 3;
  double moneyOut = 0;
  double profit = 0;
  bool isFree = false;
  List<TextEditingController> oddsC =
      List<TextEditingController>.generate(4, (_) => TextEditingController());
  List<TextEditingController> moneyInC =
      List<TextEditingController>.generate(4, (_) => TextEditingController());
  List<TextEditingController> moneyFreeC =
      List<TextEditingController>.generate(4, (_) => TextEditingController());

  Bet(
      {required this.uid,
      String? moneyFreeTotal,
      String? moneyInTotal,
      String? moneyFreeBet}) {
    moneyInC[3].text = moneyInTotal ?? '100';
    moneyFreeC[3].text = moneyFreeTotal ?? '23';
    if (moneyFreeBet != null && moneyFreeBet != '') {
      isFree = true;
      moneyFreeC[3].text = moneyFreeBet;
    }
  }

  void dispose() {
    for (int i = 0; i < 4; i++) {
      oddsC[i].dispose();
      moneyInC[i].dispose();
      moneyFreeC[i].dispose();
    }
  }
}

final List<String> columnNames = [
  'SC-1',
  'SC-X',
  'SC-2',
  'Total',
];
