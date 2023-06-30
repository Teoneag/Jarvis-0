import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    TodoMethods.syncTasks(_tasks, setState, _isSyncing);
  }

  @override
  void initState() {
    super.initState();
    TodoMethods.loadSyncTasks(_tasks, setState, _isSyncing);
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyQ): () =>
            TodoMethods.displayDialog(_tasks, _titleC, context, setState),
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
              return ListTile(
                // key: ValueKey(task.uid), // only for reordering (not doing now)
                leading: IconButton(
                  icon: const Icon(Icons.check_box_outline_blank),
                  onPressed: () =>
                      TodoMethods.markDoneTask(task, _tasks, setState),
                ),
                title: Column(
                  children: [
                    IntrinsicWidth(
                      child: TextField(
                        controller: task.textC,
                        decoration: const InputDecoration(isDense: true),
                        onChanged: (title) => TodoMethods.modifyTitle(
                            title, task, _tasks, setState),
                      ),
                    ),
                  ],
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
                        // decoration:
                        // const InputDecoration(border: InputBorder.none),
                      ),
                    ),
                    // Visibility(
                    //   visible: task.isDateVisible,
                    //   child: SfDateRangePicker(
                    //     onSelectionChanged: (value) {
                    //       task.dueDate = value.value;
                    //       task.dateC.text =
                    //           DateFormat('d MMM').format(value.value!);
                    //       task.lastModified = DateTime.now();
                    //       _saveTasksLocally();
                    //       FirestoreMethdods.addOrModifyTask(task);
                    //       task.isDateVisible = false;
                    //       setState(() {});
                    //     },
                    //     initialSelectedDate: task.dueDate,
                    //   ),
                    // ),
                  ],
                ),
                trailing: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        TodoMethods.archiveTask(task, _tasks, setState),
                  ),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () =>
                TodoMethods.displayDialog(_tasks, _titleC, context, setState),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
