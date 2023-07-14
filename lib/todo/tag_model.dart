import 'package:cloud_firestore/cloud_firestore.dart';

import 'task_model.dart';

class Tag {
  String title;
  DateTime lastModified;

  Tag({required this.title, DateTime? lastModified})
      : lastModified = lastModified ?? DateTime.now();

  factory Tag.fromSnap(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return Tag(
      lastModified: DateTime.tryParse(data[lastModifiedS]),
      title: data[titleS],
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      lastModified: DateTime.tryParse(json[lastModifiedS]),
      title: json[titleS],
    );
  }

  Map<String, dynamic> toJson() => {
        lastModifiedS: lastModified.toString(),
        titleS: title,
      };
}
