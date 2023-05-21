import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:info_popup/info_popup.dart';

import 'list_item.dart';

//: TODO: add your money at the top

class SuperBetCalculator extends StatefulWidget {
  const SuperBetCalculator({Key? key}) : super(key: key);

  @override
  State<SuperBetCalculator> createState() => _SuperBetCalculatorState();
}

class _SuperBetCalculatorState extends State<SuperBetCalculator> {
  List<ListItem> rows = [];
  // final TextEditingController _

  void addRow() {
    final uid = const Uuid().v4();
    setState(() {
      rows.add(ListItem(
        uid: uid,
        onDelete: deleteRow,
      ));
    });
  }

  void deleteRow(String uid) {
    setState(() {
      rows.removeWhere((item) => item.uid == uid);
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
      body: Column(
        children: [
          Row(
            children: [
              const Text('Your total money: '),
              Expanded(
                child: TextField(),
              ),
            ],
          ),
          SizedBox(
            height: 600,
            child: ListView.builder(
              itemCount: rows.length + 1,
              itemBuilder: (context, index) {
                if (index < rows.length) {
                  return rows[index];
                } else {
                  return ElevatedButton(
                    onPressed: addRow,
                    child: const Text('Add Row'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
