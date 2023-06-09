import 'package:cloud_firestore/cloud_firestore.dart';
import '/superbet/contract_model.dart';
import '../utils/utils.dart';

const contractsS = 'contracts';

class FirestoreMethods {
  static final _firestore = FirebaseFirestore.instance;

  static Future<String> createContract({
    // TODO: check if the name already exists
    required String name,
  }) async {
    try {
      if (name.isEmpty) {
        print('Please enter the name');
        return 'Please enter the name';
      }
      await _firestore
          .collection(contractsS)
          .doc(name)
          .set(Contract(name: name).toJson());
      return successS;
    } catch (e) {
      print(e);
      return '$e';
    }
    // your id, your card
  }

  static Future<String> deleteContract({required String name}) async {
    try {
      _firestore.collection(contractsS).doc(name).delete();
      return successS;
    } catch (e) {
      print(e);
      return '$e';
    }
  }

  static Future<String> updateContract(
      {required Contract contract, required String name}) async {
    try {
      await _firestore
          .collection(contractsS)
          .doc(name)
          .update(contract.toJson());
      return successS;
    } catch (e) {
      print(e);
      return '$e';
    }
  }
}
