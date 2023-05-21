import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:info_popup/info_popup.dart';

import 'bet_model.dart';

//: TODO: add your money at the top

class SuperBetCalculator extends StatefulWidget {
  const SuperBetCalculator({Key? key}) : super(key: key);

  @override
  State<SuperBetCalculator> createState() => _SuperBetCalculatorState();
}

class _SuperBetCalculatorState extends State<SuperBetCalculator> {
  List<Bet> listItems = [];

  @override
  void dispose() {
    for (var bet in listItems) {
      bet.dispose();
    }
    super.dispose();
  }

  void addRow() {
    final uid = const Uuid().v4();
    setState(() {
      listItems.add(Bet(
        uid: uid,
      ));
    });
  }

  void deleteRow(int index) {
    listItems[index].dispose();
    setState(() {
      listItems.removeAt(index);
    });
  }

  void _updateOddsTotal(int index) {
    final bet = listItems[index];
    double oddsTotal = 0;

    for (int i = 0; i < 3; i++) {
      double odds = double.tryParse(bet.oddsC[i].text) ?? 0;
      if (odds != 0) {
        oddsTotal += 1 / odds;
      } else {
        bet.moneyInC[i].text = '';
      }
    }

    if (oddsTotal != 0) {
      setState(() {
        bet.oddsC[3].text = oddsTotal.toStringAsFixed(3);
      });
    }

    _updateMoney(index: index);
  }

  void _updateMoney({int? currentInput, required int index}) {
    final bet = listItems[index];
    bet.lastInput = currentInput ?? bet.lastInput;

    if (!bet.isFree) {
      if (bet.lastInput == 3) {
        bet.moneyOut =
            (double.tryParse(bet.moneyInC[bet.lastInput].text) ?? 0) *
                1 /
                (double.tryParse(bet.oddsC[3].text) ?? 0);
      } else {
        setState(() {
          bet.moneyOut =
              (double.tryParse(bet.moneyInC[bet.lastInput].text) ?? 0) *
                  (double.tryParse(bet.oddsC[bet.lastInput].text) ?? 0);
        });
      }
      if (bet.moneyOut == 0) {
        setState(() {
          bet.profit =
              bet.moneyOut - (double.tryParse(bet.moneyInC[3].text) ?? 0);
        });
        return;
      }

      double moneyInTotal = 0;
      for (int i = 0; i < 3; i++) {
        double odds = double.tryParse(bet.oddsC[i].text) ?? 0;
        if (odds != 0) {
          double money = bet.moneyOut / odds;
          moneyInTotal += money;
          if (i != bet.lastInput) {
            setState(() {
              bet.moneyInC[i].text = money.toStringAsFixed(3);
            });
          }
        }
      }

      setState(() {
        if (bet.lastInput != 3) {
          bet.moneyInC[3].text = moneyInTotal.toStringAsFixed(3);
        }
        bet.profit = bet.moneyOut - moneyInTotal;
      });
      return;
    }

    for (int i = 0; i < 3; i++) {
      setState(() {
        bet.moneyInC[i].text = '';
        bet.moneyFreeC[i].text = '';
      });
    }
    setState(() {
      bet.profit = 0;
    });

    List<double> odds = List<double>.generate(
        3, (index) => double.tryParse(bet.oddsC[index].text) ?? 0);

    int indexBiggestOdd =
        odds.indexWhere((element) => element == odds.reduce(max));

    double moneyFreeTotal = double.tryParse(bet.moneyFreeC[3].text) ?? 0;

    setState(() {
      bet.moneyFreeC[indexBiggestOdd].text = moneyFreeTotal.toStringAsFixed(3);
      bet.moneyOut = moneyFreeTotal * odds[indexBiggestOdd] - moneyFreeTotal;
    });

    double moneyInTotal = 0;
    for (int i = 0; i < 3; i++) {
      if (i != indexBiggestOdd) {
        double money = bet.moneyOut / odds[i];
        if (money.isFinite) {
          moneyInTotal += money;
          setState(() {
            bet.moneyInC[i].text = money.toStringAsFixed(3);
          });
        }
      }
    }
    setState(() {
      bet.moneyInC[3].text = moneyInTotal.toStringAsFixed(3);
      bet.profit = bet.moneyOut - moneyInTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SuperBet calculator'),
        actions: const [
          Padding(
            padding: EdgeInsets.all(10),
            child: InfoPopupWidget(
              contentTitle:
                  'Press add a row,\nComplete the odds for SC-1, SC-X, SC-2,\nOdds Total is automatically calculated:\nThe smaller the better,\nComplete \'Total \$\' with ur money\nIf u also have a free bet, tap the switch\n23 is the defoutt free bet, u can modify it',
              child: Icon(
                Icons.info,
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: listItems.length + 1,
        itemBuilder: (context, index) {
          if (index < listItems.length) {
            final bet = listItems[index];
            return Column(
              children: [
                Table(
                  border: TableBorder.all(),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      children: [
                        for (int i = 0; i < 4; i++)
                          TableCell(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(child: Text(columnNames[i])),
                          )),
                      ],
                    ),
                    TableRow(children: [
                      for (int i = 0; i < 4; i++)
                        TableCell(
                          child: TextField(
                            controller: bet.oddsC[i],
                            onChanged: (value) => _updateOddsTotal(index),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                hintText: 'Odds ${columnNames[i]}'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ]),
                    TableRow(
                      children: [
                        for (int i = 0; i < 4; i++)
                          TableCell(
                            child: TextField(
                              controller: bet.moneyInC[i],
                              style: const TextStyle(color: Colors.red),
                              onChanged: (value) => _updateMoney(index: index),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  hintText: '${columnNames[i]} \$',
                                  suffix: const Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: Text('\$'),
                                  )),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                    if (bet.isFree)
                      TableRow(
                        children: [
                          for (int i = 0; i < 4; i++)
                            TableCell(
                              child: TextField(
                                controller: bet.moneyFreeC[i],
                                style: const TextStyle(color: Colors.orange),
                                onChanged: (value) =>
                                    _updateMoney(index: index),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    hintText: 'free ${columnNames[i]} \$',
                                    suffix: const Padding(
                                      padding: EdgeInsets.only(right: 8.0),
                                      child: Text('\$'),
                                    )),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Win: ${bet.moneyOut.toStringAsFixed(3)}',
                      style: const TextStyle(color: Colors.green, fontSize: 18),
                    ),
                    Text(
                      'Profit: ${bet.profit.toStringAsFixed(3)}',
                      style: TextStyle(
                          color: bet.profit < 0 ? Colors.red : Colors.green,
                          fontSize: 18),
                    ),
                    Switch(
                        value: bet.isFree,
                        onChanged: (value) {
                          setState(() {
                            bet.isFree = value;
                            _updateMoney(index: index);
                          });
                        }),
                    IconButton(
                      onPressed: () => deleteRow(index),
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else {
            return ElevatedButton(
              onPressed: addRow,
              child: const Text('Add Row'),
            );
          }
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }
}
