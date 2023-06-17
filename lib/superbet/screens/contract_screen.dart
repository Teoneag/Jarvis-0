import 'package:flutter/material.dart';
import '/utils/utils.dart';
import '/superbet/firestore_methods.dart';
import '/superbet/contract_model.dart';

// TODO: add last time modified, save automatically only when there are changes, add refresh/undo, see if equation is valid, see if initial investemnt is payed, show charts with investment, profits

class SuperbetContractScreen extends StatefulWidget {
  final Contract contract;
  const SuperbetContractScreen({super.key, required this.contract});

  @override
  State<SuperbetContractScreen> createState() => _SuperbetContractScreenState();
}

class _SuperbetContractScreenState extends State<SuperbetContractScreen> {
  late TextEditingController _startDateC;
  late TextEditingController _endDateC;
  late TextEditingController _profitYouC;
  late TextEditingController _myFundingC;
  late TextEditingController _yourFundingC;
  final List<TextEditingController> _betsC = [];
  final List<TextEditingController> _withdrawsC = [];
  final List<TextEditingController> _payementsUToMeC = [];
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  List<double> results = [];
  double totalBets = 0;
  double totalWithdraws = 0;
  double totalpayementsUToMe = 0;

  void _calculateTotalBets() {
    totalBets = 0;
    for (var result in results) {
      totalBets += result;
    }
  }

  void _calculateTotalWithdraws() {
    totalWithdraws = 0;
    for (var withdraw in widget.contract.withdraws) {
      totalWithdraws += double.tryParse(withdraw) ?? 0;
    }
  }

  void _calculateTotalpayementsUToMe() {
    totalpayementsUToMe = 0;
    for (var payment in widget.contract.payementsUToMe) {
      totalpayementsUToMe += double.tryParse(payment) ?? 0;
    }
  }

  @override
  void initState() {
    super.initState();
    final data = widget.contract;
    _startDateC = TextEditingController(text: data.startDate);
    _endDateC = TextEditingController(text: data.endDate);
    _profitYouC = TextEditingController(text: '${data.profitYou}');
    _myFundingC = TextEditingController(text: '${data.myFunding}');
    _yourFundingC = TextEditingController(text: '${data.yourFunding}');
    for (var bet in data.bets) {
      _betsC.add(TextEditingController(text: bet));
      results.add(calc(bet));
      totalBets += calc(bet);
    }
    for (var withdraw in data.withdraws) {
      _withdrawsC.add(TextEditingController(text: '$withdraw'));
      totalWithdraws += double.tryParse(withdraw) ?? 0;
    }
    for (var payment in data.payementsUToMe) {
      _payementsUToMeC.add(TextEditingController(text: '$payment'));
      totalpayementsUToMe += double.tryParse(payment) ?? 0;
    }
  }

  @override
  void dispose() {
    _startDateC.dispose();
    _endDateC.dispose();
    _profitYouC.dispose();
    _myFundingC.dispose();
    _yourFundingC.dispose();
    for (var C in _betsC) {
      C.dispose();
    }
    for (var C in _withdrawsC) {
      C.dispose();
    }
    for (var C in _payementsUToMeC) {
      C.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.contract;
    return Scaffold(
      appBar: AppBar(
        title: Text(data.name),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Text('Contract: '),
                  IntrinsicWidth(
                    child: TextFormField(
                      controller: _startDateC,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid date';
                        }
                        data.startDate = value;
                        return null;
                      },
                      decoration: const InputDecoration(isDense: true),
                    ),
                  ),
                  const Icon(Icons.arrow_forward, size: 20),
                  IntrinsicWidth(
                    child: TextFormField(
                      controller: _endDateC,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid date';
                        }
                        data.endDate = value;
                        return null;
                      },
                      decoration: const InputDecoration(isDense: true),
                    ),
                  ),
                ]),
                Row(children: [
                  const Text('Type: '),
                  IntrinsicWidth(
                    child: DropdownButtonFormField(
                      value: data.type,
                      items: contractTypes.entries
                          .map((entry) => DropdownMenuItem(
                                value: entry.key,
                                child: Text(entry.key),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          data.type = value ?? '1';
                        });
                      },
                    ),
                  )
                ]),
                const SizedBox(height: 7),
                Text('  ${contractTypes[data.type]}'),
                Row(children: [
                  const Text('You get: '),
                  IntrinsicWidth(
                    child: TextFormField(
                      controller: _profitYouC,
                      validator: (value) {
                        try {
                          data.profitYou = int.tryParse(value!)!;
                          return null;
                        } catch (e) {
                          return 'Please enter a valid percentage';
                        }
                      },
                      decoration: const InputDecoration(isDense: true),
                    ),
                  ),
                  const Text('% of all profits on this account'),
                ]),
                Row(children: [
                  const Text('My initial funding: '),
                  IntrinsicWidth(
                    child: TextFormField(
                      controller: _myFundingC,
                      validator: (value) {
                        try {
                          data.myFunding = int.tryParse(value!)!;
                          return null;
                        } catch (e) {
                          return 'Please enter a valid number';
                        }
                      },
                      decoration: const InputDecoration(isDense: true),
                    ),
                  ),
                  const Text('ron'),
                ]),
                Row(children: [
                  const Text('Your initial funding: '),
                  IntrinsicWidth(
                    child: TextFormField(
                      controller: _yourFundingC,
                      validator: (value) {
                        try {
                          data.yourFunding = int.tryParse(value!)!;
                          return null;
                        } catch (e) {
                          return 'Please enter a valid number';
                        }
                      },
                      decoration: const InputDecoration(isDense: true),
                    ),
                  ),
                  const Text('ron'),
                ]),
                const Divider(),
                Text(
                  'Total profit: $totalBets ron',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _betsC.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Text('${results[index]} = '),
                        title: TextField(
                          controller: _betsC[index],
                          onChanged: (value) {
                            data.bets[index] = value;
                            try {
                              results[index] = calc(value);
                              _calculateTotalBets();
                              setState(() {});
                            } catch (e) {}
                          },
                          decoration: const InputDecoration(isDense: true),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _betsC[index].dispose();
                            _betsC.removeAt(index);
                            data.bets.removeAt(index);
                            results.removeAt(index);
                            _calculateTotalBets();
                            setState(() {});
                          },
                        ),
                      );
                    },
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        data.bets.add('0');
                        _betsC.add(TextEditingController(text: '0'));
                        results.add(0);
                      });
                    },
                    child: const Text('Add bet'),
                  ),
                ),
                const Divider(),
                Text(
                  'Total withdraw: $totalWithdraws ron',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _withdrawsC.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: TextField(
                          controller: _withdrawsC[index],
                          onChanged: (value) {
                            data.withdraws[index] = value;
                            _calculateTotalWithdraws();
                            setState(() {});
                          },
                          decoration: const InputDecoration(isDense: true),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _withdrawsC[index].dispose();
                            _withdrawsC.removeAt(index);
                            data.withdraws.removeAt(index);
                            _calculateTotalWithdraws();
                            setState(() {});
                          },
                        ),
                      );
                    },
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        data.withdraws.add('0');
                        _withdrawsC.add(TextEditingController(text: '0'));
                      });
                    },
                    child: const Text('Add withdraw'),
                  ),
                ),
                const Divider(),
                Text(
                  'Total payements(U -> Me): $totalpayementsUToMe ron',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _payementsUToMeC.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: TextField(
                          controller: _payementsUToMeC[index],
                          onChanged: (value) {
                            data.payementsUToMe[index] = value;
                            _calculateTotalpayementsUToMe();
                            setState(() {});
                          },
                          decoration: const InputDecoration(isDense: true),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _payementsUToMeC[index].dispose();
                            _payementsUToMeC.removeAt(index);
                            data.payementsUToMe.removeAt(index);
                            _calculateTotalpayementsUToMe();
                            setState(() {});
                          },
                        ),
                      );
                    },
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        data.payementsUToMe.add('0');
                        _payementsUToMeC.add(TextEditingController(text: '0'));
                      });
                    },
                    child: const Text('Add payment'),
                  ),
                ),
                const Divider(),
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : IconButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isLoading = true;
                              });
                              String res =
                                  await FirestoreMethods.updateContract(
                                      contract: data, name: data.name);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Save changes: $res')));
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                          icon: const Icon(Icons.save),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
