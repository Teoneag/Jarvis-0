import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'tag_model.dart';

const titleS = 'title';
const lastModifiedS = 'lastModified';
const dueDateS = 'dueDate';
const tagsIdsS = 'tagsIds';

// class Sequence {
//   int s, e;
//   Sequence(this.s, this.e);
// }

class Task {
  // save
  String uid;
  DateTime lastModified;
  String title;
  DateTime? dueDate;
  Set<String> tagsIds = {};

  // ram
  Set<Tag> tags = {};
  final titleC = TextEditingController();
  final dateC = TextEditingController();
  final daysC = TextEditingController();
  bool isDateVisible = false;
  DateTime? time;
  DateTime? date;
  String dayOfWeek = '';
  // Sequence? seq;

  Task(
      {required this.title,
      String? uid,
      DateTime? lastModified,
      this.dueDate,
      Set<String>? tagsIds})
      : uid = uid ?? const Uuid().v1(),
        lastModified = lastModified ?? DateTime.now(),
        tagsIds = tagsIds ?? {} {
    titleC.text = title;
  }

  factory Task.fromSnap(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return Task(
      uid: snap.id,
      lastModified: DateTime.tryParse(data[lastModifiedS]),
      title: data[titleS],
      dueDate: DateTime.tryParse(data[dueDateS]),
      tagsIds: Set<String>.from(data[tagsIdsS]),
    );
  }

  factory Task.fromJson(String uid, Map<String, dynamic> json) {
    return Task(
      uid: uid,
      lastModified: DateTime.tryParse(json[lastModifiedS]),
      title: json[titleS],
      dueDate: DateTime.tryParse(json[dueDateS].toString()),
      tagsIds: Set<String>.from(json[tagsIdsS]),
    );
  }

  Map<String, dynamic> toJson() => {
        lastModifiedS: lastModified.toString(),
        titleS: title,
        dueDateS: dueDate.toString(),
        tagsIdsS: tagsIds.toList(),
      };

  void dispose() {
    titleC.dispose();
    dateC.dispose();
    daysC.dispose();
  }
}
