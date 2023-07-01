import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/todo/task_model.dart';
import '/todo/task_widget.dart';
import '/todo/todo_methods.dart';
import '/utils/utils.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _titleC = TextEditingController();
  final Map<String, Task> _tasks = {};
  final BoolWrapper _isSyncing = BoolWrapper(false);

  @override
  void initState() {
    super.initState();
    TodoMethods.loadSyncTasks(TaskSyncObject(setState, _isSyncing), _tasks);
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyQ): () =>
            TodoMethods.displayDialog(
                TaskSyncObject(setState, _isSyncing), _tasks, _titleC, context),
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
                        onPressed: () => TodoMethods.syncTasks(
                            TaskSyncObject(setState, _isSyncing), _tasks),
                      ),
              ),
            ],
          ),
          body: ListView.builder(
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              final task = _tasks.values.elementAt(index);
              return TaskWidget(_tasks, task, setState, _isSyncing);
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => TodoMethods.displayDialog(
                TaskSyncObject(setState, _isSyncing), _tasks, _titleC, context),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
