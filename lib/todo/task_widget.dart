import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '/utils/utils.dart';
import 'tag_model.dart';
import 'task_model.dart';
import 'todo_methods/date_methods.dart';
import 'todo_methods/task_manager.dart';
import 'todo_methods/todo_methdos.dart';

class TaskWidget extends StatelessWidget {
  late final TaskObj tO;
  late final SyncObj sO;
  final Task task;
  final Map<String, Task> tasks;
  final Map<String, Tag> tags;
  final StateSetter setState;
  final BoolWrapper isSyncing;
  final ScrollController scrollC;
  final int index;

  TaskWidget(
    this.tags,
    this.tasks,
    this.task,
    this.setState,
    this.isSyncing,
    this.scrollC,
    this.index, {
    super.key,
  }) {
    tO = TaskObj(tasks, task);
    sO = SyncObj(setState, isSyncing);
  }

// TODO: add tags
// TODO: todo queue
// TODO: make the new task nicer
// TODO: save only if different

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          // key: ValueKey(task.uid), // only for reordering (not doing now)
          leading: IconButton(
            icon: const Icon(Icons.check_box_outline_blank),
            onPressed: () => TodoM.doneTask(tO, sO),
          ),
          title: TextField(
            controller: task.titleC,
            decoration:
                const InputDecoration(isDense: true, border: InputBorder.none),
            onSubmitted: (title) => TodoM.modifyTitle(tags, tO, title, sO),
          ),
          subtitle: Row(
            children: [
              IntrinsicWidth(
                child: TextField(
                  controller: task.daysC,
                  onTap: () => DateM.showDate(task, index, scrollC, setState),
                  onSubmitted: (value) => DateM.daysToDate(value, tO, sO),
                  decoration: const InputDecoration(
                    hintText: 'days',
                    isDense: true,
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              IntrinsicWidth(
                child: TextField(
                  controller: task.dateC,
                  onTap: () => DateM.showDate(task, index, scrollC, setState),
                  onSubmitted: (value) => DateM.textToDate(value, tO, sO),
                  decoration: const InputDecoration(
                    hintText: 'date',
                    isDense: true,
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(task.dayOfWeek),
            ],
          ),
          trailing: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => TodoM.archiveTask(tO, sO),
            ),
          ),
        ),
        Visibility(
          visible: task.isDateVisible,
          child: Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Row(
              children: [
                Expanded(
                  child: SfDateRangePicker(
                    onSelectionChanged: (date) => task.date = date.value,
                    initialSelectedDate: task.dueDate,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TimePickerSpinner(
                      normalTextStyle: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                      highlightedTextStyle: const TextStyle(
                        fontSize: 25,
                        color: Colors.blue,
                      ),
                      time: today10,
                      onTimeChange: (time) {
                        task.time = time;
                        setState(() {});
                      },
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              task.isDateVisible = false;
                            });
                            FocusScope.of(context).unfocus();
                            SystemChannels.textInput
                                .invokeMethod('TextInput.hide');
                          },
                          icon: const Icon(Icons.close),
                        ),
                        IconButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            SystemChannels.textInput
                                .invokeMethod('TextInput.hide');
                            DateM.modifyDate(tO, sO);
                          },
                          icon: const Icon(Icons.check),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
