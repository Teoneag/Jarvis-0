import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/utils/utils.dart';
import '../task_model.dart';
import 'task_manager.dart';

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
      // check with text
      task.lastModified = DateTime.now();
      task.isDateVisible = false;
      TaskM.saveTask(tO, sO);
    } catch (e) {
      print(e);
    }
  }

  static void showDate(
      Task task, int index, ScrollController scrollC, StateSetter setState) {
    // make scrolling work better
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

  static void textToDate(String dateString, TaskObj tO, SyncObj sO) {
    _textToDate(dateString, tO.task);
    tO.task.isDateVisible = false;
    TaskM.saveTask(tO, sO);
  }

  static void daysToDate(String daysString, TaskObj tO, SyncObj sO) {
    _daysToDate(daysString, tO.task);
    tO.task.isDateVisible = false;
    TaskM.saveTask(tO, sO);
  }

  static void titleToDate(String title, Task task) {
    _textToDate(title, task);
    _daysToDate(title, task);
  }

  static void _daysToDate(String daysString, Task task) {
    try {
      // TODO: make green the expressions
      if (daysString.contains('tod')) {
        task.dueDate = DateTime.now();
        return;
      }

      if (daysString.contains('tom')) {
        task.dueDate = DateTime.now().add(const Duration(days: 1));
        return;
      }

      RegExp r = RegExp(
          r'in (\d+) days'); //TODO: check if it's in 10 days, not only 10
      final match = r.firstMatch(daysString);
      if (match == null || match.group(0) == null) return;
      int numberOfDays = int.parse(match.group(0)!.split(' ')[1]);
      task.dueDate = now.add(Duration(days: numberOfDays));
    } catch (e) {
      print(e);
    }
  }

  static void _textToDate(String dateString, Task task) {
    // TODO: make green the expressions
    try {
      int year = DateTime.now().year;
      int month = DateTime.now().month;
      int day = DateTime.now().day;
      int hour = 10;
      int minute = 0;

      // find format 1: 3 jul/10 jul
      RegExp r = RegExp(
          r"\b(3[01]|[12][0-9]|[1-9])\s(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)",
          caseSensitive: false);
      Match? match = r.firstMatch(dateString);
      if (match != null) {
        List<String> parts = match.group(0)!.split(' ');
        month = monthMap[parts[1].toLowerCase()]!;
        day = int.parse(parts[0]);
        task.dueDate = DateTime(year, month, day, hour, minute);
        return;
      }

      // find format 2: 3.6
      r = RegExp(r"\b(3[01]|[12][0-9]|[1-9])\.(1[012]|[1-9])");
      match = r.firstMatch(dateString);
      if (match != null) {
        List<String> parts = match.group(0)!.split('.');
        day = int.parse(parts[0]);
        month = int.parse(parts[1]);
        task.dueDate = DateTime(year, month, day, hour, minute);
        return;
      }

      // find format this 6
      r = RegExp(r'\d+');
      match = r.firstMatch(dateString);
      if (match != null) {
        int dayOfMonth = int.parse(match.group(0)!);
        task.dueDate = DateTime(now.year, now.month, dayOfMonth);
        return;
      }

      // no date found
      dateToText(task);
    } catch (e) {
      print(e);
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
