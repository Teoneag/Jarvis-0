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
// solve focus pb (q not working after using the textfield)

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _titleC = TextEditingController();
  final Map<String, Task> _tasks = {};
  final BoolWrapper _isSyncing = BoolWrapper(false);
  final ScrollController _scrollC = ScrollController();

  @override
  void initState() {
    super.initState();
    TodoM.loadSyncTasks(_tasks, SyncObj(setState, _isSyncing));
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyQ): () =>
            TodoM.displayDialog(
                _tasks, _titleC, context, SyncObj(setState, _isSyncing)),
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
                        onPressed: () => TodoM.syncTasks(
                            _tasks, SyncObj(setState, _isSyncing)),
                      ),
              ),
            ],
          ),
          body: ListView.builder(
            controller: _scrollC,
            itemCount: _tasks.length,
            itemBuilder: (context, i) {
              final task = _tasks.values.elementAt(i);
              return TaskWidget(
                  _tasks, task, setState, _isSyncing, _scrollC, i);
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => TodoM.displayDialog(
                _tasks, _titleC, context, SyncObj(setState, _isSyncing)),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
