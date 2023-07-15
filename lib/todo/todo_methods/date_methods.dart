import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '/utils/utils.dart';
import '../task_model.dart';
import 'task_manager.dart';

// TODO: make a green highlight on valid part of date + part of title that's date
// TODO: add hour, minutes, year

class DateM {
  static void modifyDate(TaskObj tO, SyncObj sO) async {
    try {
      Task task = tO.task;
      if (task.date != null) task.dueDate = task.date;
      task.dueDate ??= DateTime.now();
      if (task.time != null) {
        task.dueDate = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
          task.time!.hour,
          task.time!.minute,
        );
      }
      task.lastModified = DateTime.now();
      task.isDateVisible = false;
      TaskM.saveTask(tO, sO);
    } catch (e) {
      print(e);
    }
  }

  static void showDate(
      Task task, int index, ScrollController scrollC, StateSetter setState) {
    // TODO: make scrolling work better
    task.isDateVisible = true;
    setState(() {});
    scrollC.jumpTo(index * 80.0);
  }

  static void dateToText(Task task) {
    // TODO: make red when overdue, if bigger than 31 days say month, year
    try {
      final dueDate = task.dueDate;
      if (dueDate == null) return;

      task.dayOfWeek = DateFormat('E').format(dueDate).toLowerCase();

      if (now.year == dueDate.year && now.month == dueDate.month) {
        task.dateC.text = 'this ${DateFormat('d').format(dueDate)}';
      } else {
        task.dateC.text = DateFormat('d MMM').format(dueDate).toLowerCase();
      }

      int diff = _substractDays(now, dueDate);
      if (diff == 0) {
        task.daysC.text = 'tod';
      } else if (diff == 1) {
        task.daysC.text = 'tom';
      } else {
        task.daysC.text = 'in $diff days';
      }
    } catch (e) {
      print(e);
    }
  }

  static void textToDate(String intpu, TaskObj tO, SyncObj sO) {
    final string = _text2ToDate(intpu, tO.task);
    if (string == null) {
      dateToText(tO.task);
    } else {
      tO.task.dateC.text = string;
    }
    tO.task.isDateVisible = false;
    TaskM.saveTask(tO, sO);
  }

  static void daysToDate(String input, TaskObj tO, SyncObj sO) {
    _text1ToDate(input, tO.task);
    tO.task.isDateVisible = false;
    TaskM.saveTask(tO, sO);
  }

  static void titleToDate(String title, TaskObj tO, SyncObj sO) {
    String? result = _text1ToDate(title, tO.task);
    result ??= _text2ToDate(title, tO.task);
    if (result == null) return;
    tO.task.title = tO.task.title.replaceAll(result, '');
    tO.task.title = tO.task.title.replaceAll('  ', ' ');
    tO.task.titleC.text = tO.task.title;
    TaskM.saveTask(tO, sO);
  }

  static String? _text1ToDate(String daysString, Task task) {
    try {
      // tod
      if (daysString.contains('tod')) {
        task.dueDate = now;
        return 'tod';
      }

      // tom
      if (daysString.contains('tom')) {
        task.dueDate = now.add(const Duration(days: 1));
        return 'tom';
      }

      // in 3 days
      RegExp r = RegExp(r'in (\d+) days');
      final match = r.firstMatch(daysString);
      if (match == null || match.group(0) == null) return null;
      int numberOfDays = int.parse(match.group(0)!.split(' ')[1]);
      task.dueDate = now.add(Duration(days: numberOfDays));
      return 'in $numberOfDays days';
    } catch (e) {
      print(e);
      return null;
    }
  }

  static String? _text2ToDate(String dateString, Task task) {
    try {
      int year = now.year;
      int month = now.month;
      int day = now.day;

      // 3 jul/10 jul
      RegExp r = RegExp(
          r"\b(3[01]|[12][0-9]|[1-9])\s(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)",
          caseSensitive: false);
      Match? match = r.firstMatch(dateString);
      if (match != null && match.group(0) != null) {
        List<String> parts = match.group(0)!.split(' ');
        month = monthMap[parts[1].toLowerCase()]!;
        day = int.parse(parts[0]);
        task.dueDate = DateTime(year, month, day);
        return match.group(0);
      }

      // 3.6
      r = RegExp(r"\b(3[01]|[12][0-9]|[1-9])\.(1[012]|[1-9])");
      match = r.firstMatch(dateString);
      if (match != null && match.group(0) != null) {
        List<String> parts = match.group(0)!.split('.');
        day = int.parse(parts[0]);
        month = int.parse(parts[1]);
        task.dueDate = DateTime(year, month, day);
        return match.group(0);
      }

      // this 6
      r = RegExp(r'this (\d+)');
      match = r.firstMatch(dateString);
      if (match != null && match.group(0) != null) {
        int dayOfMonth = int.parse(match.group(0)!.split(' ')[1]);
        task.dueDate = DateTime(now.year, now.month, dayOfMonth);
        return match.group(0);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static int _substractDays(DateTime d1, DateTime d2) {
    DateTime truncD1 = DateTime(d1.year, d1.month, d1.day);
    DateTime truncD2 = DateTime(d2.year, d2.month, d2.day);
    return truncD2.difference(truncD1).inDays;
  }
}

Map<String, int> monthMap = {
  'jan': 1,
  'feb': 2,
  'mar': 3,
  'apr': 4,
  'may': 5,
  'jun': 6,
  'jul': 7,
  'aug': 8,
  'sep': 9,
  'oct': 10,
  'nov': 11,
  'dec': 12,
};
