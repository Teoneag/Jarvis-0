import 'package:flutter/material.dart';
import 'package:jarvis_0/todo/task_model.dart';
import 'package:jarvis_0/todo/todo_methods.dart';

class AddTaskDialog extends StatelessWidget {
  final TextEditingController titleC;
  final TaskSyncObject taskSyncObject;
  final Map<String, Task> tasks;

  const AddTaskDialog(
      {super.key,
      required this.titleC,
      required this.taskSyncObject,
      required this.tasks});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a task'),
      content: TextField(
        controller: titleC,
        decoration: const InputDecoration(hintText: 'Type your task'),
        autofocus: true,
        onSubmitted: (value) {
          Navigator.of(context).pop();
          TodoMethods.addTask(taskSyncObject, tasks, titleC);
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            TodoMethods.addTask(taskSyncObject, tasks, titleC);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
