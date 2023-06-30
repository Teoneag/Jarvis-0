import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '/todo/todo_methdos.dart';
import '/utils/utils.dart';
import '/todo/task_model.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _titleC = TextEditingController();
  final Map<String, Task> _tasks = {};
  final BoolWrapper _isSyncing = BoolWrapper(false);

  void _pressedSync() {
    if (_isSyncing.value) {
      return;
    }
    TodoM.syncTasks(_tasks, setState, _isSyncing);
  }

  @override
  void initState() {
    super.initState();
    TodoM.loadSyncTasks(_tasks, setState, _isSyncing);
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyQ): () =>
            TodoM.displayDialog(_tasks, _titleC, context, setState),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Todo'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: _isSyncing.value
                    ? loadingCenter()
                    : IconButton(
                        icon: const Icon(Icons.sync),
                        onPressed: _pressedSync,
                      ),
              ),
            ],
          ),
          body: ListView.builder(
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              final task = _tasks.values.elementAt(index);
              return Column(
                children: [
                  ListTile(
                    // key: ValueKey(task.uid), // only for reordering (not doing now)
                    leading: IconButton(
                      icon: const Icon(Icons.check_box_outline_blank),
                      onPressed: () =>
                          TodoM.markDoneTask(task, _tasks, setState),
                    ),
                    title: TextField(
                      controller: task.titleC,
                      decoration: const InputDecoration(
                          isDense: true, border: InputBorder.none),
                      onChanged: (title) =>
                          TodoM.modifyTitle(title, task, _tasks, setState),
                    ),
                    subtitle: Column(
                      children: [
                        IntrinsicWidth(
                          child: TextField(
                            controller: task.dateC,
                            onTap: () {
                              task.isDateVisible = true;
                              setState(() {});
                            },
                            onSubmitted: (value) {
                              task.isDateVisible = false;
                              setState(() {});
                            },
                            decoration: const InputDecoration(
                              hintText: 'Date',
                              isDense: true,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            TodoM.archiveTask(task, _tasks, setState),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: task.isDateVisible,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: SfDateRangePicker(
                              // onSelectionChanged: (value) => TodoM.modifyDate(
                              //     value, task, _tasks, setState),
                              initialSelectedDate: task.dueDate,
                            ),
                          ),
                          Column(
                            children: [
                              TimePickerSpinner(
                                  // initialTime
                                  // onTimeChange: (time) {},
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
                                    onPressed: () {},
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
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () =>
                TodoM.displayDialog(_tasks, _titleC, context, setState),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
