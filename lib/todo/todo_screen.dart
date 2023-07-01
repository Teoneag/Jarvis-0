import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/todo/task_widget.dart';
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
            TodoM.displayDialog(_tasks, _titleC, context, setState, _isSyncing),
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
                        onPressed: () =>
                            TodoM.syncTasks(_tasks, setState, _isSyncing),
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
            onPressed: () => TodoM.displayDialog(
                _tasks, _titleC, context, setState, _isSyncing),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
