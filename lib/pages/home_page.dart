import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crud/models/todo.dart';
import 'package:firebase_crud/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textEditingController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Todos"),
        backgroundColor: Colors.blueAccent,
      ),
      body: _buildUi(),
      floatingActionButton: FloatingActionButton(
        onPressed: _displayInputDialog,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUi() {
    return SafeArea(
      child: Column(
        children: [
          _messagesListView(),
        ],
      ),
    );
  }

  Widget _messagesListView() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.80,
      width: MediaQuery.of(context).size.width,
      child: StreamBuilder(
        stream: _databaseService.getTodos(),
        builder: (context, snapshot) {
          List todos = snapshot.data?.docs ?? [];

          if (todos.isEmpty) {
            return const Center(child: Text("Add A Todos"));
          }
          return ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                Todo todo = todos[index].data();
                String todoId = todos[index].id;
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: ListTile(
                    tileColor: Theme.of(context).colorScheme.primaryContainer,
                    title: Text(todo.task),
                    subtitle: Text(DateFormat("dd-MM-yyyy h:mm:a")
                        .format(todo.updatedOn.toDate())),
                    trailing: Checkbox(
                      value: todo.isDone,
                      onChanged: (value) {
                        Todo updatedTodo = todo.copywith(
                            isDone: !todo.isDone, updatedOn: Timestamp.now());
                        _databaseService.updateTodo(todoId, updatedTodo);
                      },
                    ),
                    onLongPress: () {
                      _databaseService.deleteTodo(todoId);
                    },
                  ),
                );
              });
        },
      ),
    );
  }

  void _displayInputDialog() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Add a Todo"),
            content: TextField(
              controller: _textEditingController,
              decoration: const InputDecoration(hintText: "Add Todo"),
            ),
            actions: [
              MaterialButton(
                onPressed: () {
                  Todo todo = Todo(
                      task: _textEditingController.text,
                      isDone: false,
                      createdOn: Timestamp.now(),
                      updatedOn: Timestamp.now());
                  _databaseService.addTodo(todo);
                },
                color: Colors.lightBlue,
                child: const Text("Add Todo"),
              )
            ],
          );
        });
  }
}
