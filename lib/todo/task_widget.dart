import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '/utils/utils.dart';
import 'task_model.dart';
import 'todo_methdos.dart';

class TaskWidget extends StatelessWidget {
  final Map<String, Task> tasks;
  final Task task;
  final StateSetter setState;
  final BoolWrapper isSyncing;
  final ScrollController scrollC;
  final int index;
  const TaskWidget(
    this.tasks,
    this.task,
    this.setState,
    this.isSyncing,
    this.scrollC,
    this.index, {
    super.key,
  });

// TODO
// modify this so it takes a taskObj and SyncObj parameters as input
  // todo queue
  // date from title
  // make the new task nicer

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          // key: ValueKey(task.uid), // only for reordering (not doing now)
          leading: IconButton(
            icon: const Icon(Icons.check_box_outline_blank),
            onPressed: () => TodoM.doneTask(
                TaskObj(tasks, task), SyncObj(setState, isSyncing)),
          ),
          title: TextField(
            controller: task.titleC,
            decoration:
                const InputDecoration(isDense: true, border: InputBorder.none),
            onSubmitted: (title) => TodoM.modifyTitle(
                TaskObj(tasks, task), title, SyncObj(setState, isSyncing)),
          ),
          subtitle: Row(
            children: [
              IntrinsicWidth(
                child: TextField(
                  controller: task.daysC,
                  onTap: () => TodoM.showDate(task, index, scrollC, setState),
                  onSubmitted: (value) => TodoM.textDaysToDate(value,
                      TaskObj(tasks, task), SyncObj(setState, isSyncing)),
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
                  onTap: () => TodoM.showDate(task, index, scrollC, setState),
                  onSubmitted: (value) => TodoM.textToDate(value,
                      TaskObj(tasks, task), SyncObj(setState, isSyncing)),
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
              onPressed: () => TodoM.archiveTask(
                  TaskObj(tasks, task), SyncObj(setState, isSyncing)),
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
                    // format text
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
                      // format text
                      onTimeChange: (time) {
                        if (time != today10) {
                          task.isTimeVisible = true;
                        } else {
                          task.isTimeVisible = false;
                        }
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
                            TodoM.modifyDate(
                                task.uid, tasks, SyncObj(setState, isSyncing));
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
