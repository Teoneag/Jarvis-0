import 'package:flutter/material.dart';
import 'dart:math';

// class Bet {
//   final String uid;
//   int lastInput = 3;
//   double moneyOut = 0;
//   double profit = 0;
//   bool isFree = false;
//   List<double> odds = List<double>.generate(4, (_) => 0);
//   List<double> moneyIn = List<double>.generate(4, (_) => 0);
//   List<double> moneyFree = List<double>.generate(4, (_) => 0);

//   Bet({required this.uid, double? moneyFreeTotal, double? moneyInTotal}) {
//     moneyIn[3] = moneyInTotal ?? 100;
//     moneyFree[3] = moneyFreeTotal ?? 23;
//   }
// }

class ListItem extends StatefulWidget {
  final String uid;
  final void Function(String) onDelete;

  List<TextEditingController> oddsC =
      List<TextEditingController>.generate(4, (_) => TextEditingController());
  List<TextEditingController> moneyInC =
      List<TextEditingController>.generate(4, (_) => TextEditingController());
  List<TextEditingController> moneyFreeC =
      List<TextEditingController>.generate(4, (_) => TextEditingController());

  int lastInput = 3;
  double moneyOut = 0;
  double profit = 0;
  bool isFree = false;
  ListItem({super.key, required this.onDelete, required this.uid}) {
    moneyFreeC[3].text = '23';
  }

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  final List<String> columnNames = [
    'SC-1',
    'SC-X',
    'SC-2',
    'Total',
  ];

  @override
  void dispose() {
    for (int i = 0; i < 4; i++) {
      widget.oddsC[i].dispose();
      widget.moneyInC[i].dispose();
      widget.moneyFreeC[i].dispose();
    }
    super.dispose();
  }

  void _updateOddsTotal() {
    double oddsTotal = 0;

    for (int i = 0; i < 3; i++) {
      double odds = double.tryParse(widget.oddsC[i].text) ?? 0;
      if (odds != 0) {
        oddsTotal += 1 / odds;
      } else {
        widget.moneyInC[i].text = '';
      }
    }

    if (oddsTotal != 0) {
      setState(() {
        widget.oddsC[3].text = oddsTotal.toStringAsFixed(3);
      });
    }

    _updateMoney();
  }

  void _updateMoney({int? i}) {
    widget.lastInput = i ?? widget.lastInput;

    if (!widget.isFree) {
      if (widget.lastInput == 3) {
        widget.moneyOut =
            (double.tryParse(widget.moneyInC[widget.lastInput].text) ?? 0) *
                1 /
                (double.tryParse(widget.oddsC[3].text) ?? 0);
      } else {
        setState(() {
          widget.moneyOut =
              (double.tryParse(widget.moneyInC[widget.lastInput].text) ?? 0) *
                  (double.tryParse(widget.oddsC[widget.lastInput].text) ?? 0);
        });
      }
      if (widget.moneyOut == 0) {
        setState(() {
          widget.profit =
              widget.moneyOut - (double.tryParse(widget.moneyInC[3].text) ?? 0);
        });
        return;
      }

      double moneyInTotal = 0;
      for (int i = 0; i < 3; i++) {
        double odds = double.tryParse(widget.oddsC[i].text) ?? 0;
        if (odds != 0) {
          double money = widget.moneyOut / odds;
          moneyInTotal += money;
          if (i != widget.lastInput) {
            setState(() {
              widget.moneyInC[i].text = money.toStringAsFixed(3);
            });
          }
        }
      }

      setState(() {
        if (widget.lastInput != 3) {
          widget.moneyInC[3].text = moneyInTotal.toStringAsFixed(3);
        }
        widget.profit = widget.moneyOut - moneyInTotal;
      });
      return;
    }

    for (int i = 0; i < 3; i++) {
      setState(() {
        widget.moneyInC[i].text = '';
        widget.moneyFreeC[i].text = '';
      });
    }
    setState(() {
      widget.profit = 0;
    });

    List<double> odds = List<double>.generate(
        3, (index) => double.tryParse(widget.oddsC[index].text) ?? 0);

    int indexBiggestOdd =
        odds.indexWhere((element) => element == odds.reduce(max));

    double moneyFreeTotal = double.tryParse(widget.moneyFreeC[3].text) ?? 0;

    setState(() {
      widget.moneyFreeC[indexBiggestOdd].text =
          moneyFreeTotal.toStringAsFixed(3);
      widget.moneyOut = moneyFreeTotal * odds[indexBiggestOdd] - moneyFreeTotal;
    });

    double moneyInTotal = 0;
    for (int i = 0; i < 3; i++) {
      if (i != indexBiggestOdd) {
        double money = widget.moneyOut / odds[i];
        if (money.isFinite) {
          moneyInTotal += money;
          setState(() {
            widget.moneyInC[i].text = money.toStringAsFixed(3);
          });
        }
      }
    }
    setState(() {
      widget.moneyInC[3].text = moneyInTotal.toStringAsFixed(3);
      widget.profit = widget.moneyOut - moneyInTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    controller: widget.oddsC[i],
                    onChanged: (value) => _updateOddsTotal(),
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(hintText: 'Odds ${columnNames[i]}'),
                    textAlign: TextAlign.center,
                  ),
                ),
            ]),
            TableRow(
              children: [
                for (int i = 0; i < 4; i++)
                  TableCell(
                    child: TextField(
                      controller: widget.moneyInC[i],
                      style: const TextStyle(color: Colors.red),
                      onChanged: (value) => _updateMoney(i: i),
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
            if (widget.isFree)
              TableRow(
                children: [
                  for (int i = 0; i < 4; i++)
                    TableCell(
                      child: TextField(
                        controller: widget.moneyFreeC[i],
                        style: const TextStyle(color: Colors.orange),
                        onChanged: (value) => _updateMoney(i: i),
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
              'Win: ${widget.moneyOut.toStringAsFixed(3)}',
              style: const TextStyle(color: Colors.green, fontSize: 18),
            ),
            Text(
              'Profit: ${widget.profit.toStringAsFixed(3)}',
              style: TextStyle(
                  color: widget.profit < 0 ? Colors.red : Colors.green,
                  fontSize: 18),
            ),
            Switch(
                value: widget.isFree,
                onChanged: (value) {
                  setState(() {
                    widget.isFree = value;
                    _updateMoney();
                  });
                }),
            IconButton(
              onPressed: () {
                widget.onDelete(widget.uid);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const Divider(),
      ],
    );
  }
}
