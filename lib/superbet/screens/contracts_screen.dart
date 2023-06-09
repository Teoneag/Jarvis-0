import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jarvis_0/superbet/contract_model.dart';
import 'package:jarvis_0/superbet/firestore_methods.dart';
import 'package:jarvis_0/utils/routes.dart';
import 'package:jarvis_0/utils/utils.dart';

// TODO: when adding a new contract, push the contract screen, so u can already edit it

class SuperbetContractsScreen extends StatefulWidget {
  const SuperbetContractsScreen({super.key});

  @override
  State<SuperbetContractsScreen> createState() =>
      _SuperbetContractsScreenState();
}

class _SuperbetContractsScreenState extends State<SuperbetContractsScreen> {
  void _addContract(BuildContext context) {
    String name = '';
    String res = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter name'),
        content: TextFormField(
          onChanged: (value) {
            name = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              name = '';
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                res = await FirestoreMethods.createContract(name: name);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Add: $res')));
              } catch (e) {
                print(e);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Superbet contracts')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection(contractsS).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingCenter();
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final contract = Contract.fromSnap(snapshot.data!.docs[index]);
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(Routes.superbetContract,
                            arguments: contract);
                      },
                      child: Text(
                        contract.name,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        String res = await FirestoreMethods.deleteContract(
                            name: contract.name);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Delete: $res')));
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addContract(context),
        tooltip: 'Add new contract',
        child: const Icon(Icons.add),
      ),
    );
  }
}
