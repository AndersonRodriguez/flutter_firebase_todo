import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_todo/model/todo.dart';
import 'package:flutter_firebase_todo/screens/root_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  final TextEditingController _textEditingController = TextEditingController();

  List<Todo> _todos = [];

  late Query _todoQuery;

  late StreamSubscription<DatabaseEvent> _onTodoAddSuscription;
  late StreamSubscription<DatabaseEvent> _onTodoChangeSuscription;

  @override
  void initState() {
    super.initState();

    _todos = [];

    _todoQuery = _database
        .ref()
        .child('todo')
        .orderByChild('userId')
        .equalTo(widget.userId);

    _onTodoAddSuscription = _todoQuery.onChildAdded.listen(onEntryAdd);
    _onTodoChangeSuscription = _todoQuery.onChildChanged.listen(onEntryChange);
  }

  onEntryAdd(DatabaseEvent event) {
    setState(() {
      _todos.add(Todo.fromSnapshot(event.snapshot));
    });
  }

  onEntryChange(DatabaseEvent event) {
    var currentTodo =
        _todos.singleWhere((todo) => todo.key == event.snapshot.key);

    setState(() {
      _todos[_todos.indexOf(currentTodo)] = Todo.fromSnapshot(event.snapshot);
    });
  }

  signOut() async {
    try {
      await _auth.signOut();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const RootScreen(),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  addTodo(String text) {
    Todo todo = Todo(text, false, widget.userId);
    _database.ref().child('todo').push().set(todo.toJson());
    _textEditingController.clear();
  }

  updateTodo(Todo todo) {
    todo.completed = !todo.completed;
    _database.ref().child('todo').child(todo.key!).set(todo.toJson());
  }

  deleteTodo(Todo todo) {
    _database.ref().child('todo').child(todo.key!).remove();
  }

  _showAddTodoDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Agregar TODO',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextField(
              controller: _textEditingController,
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              addTodo(_textEditingController.text);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: showTodoList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTodoDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget showTodoList() {
    return ListView.builder(
      itemCount: _todos.length,
      itemBuilder: (context, index) {
        Todo todo = _todos[index];

        return Dismissible(
          key: Key(todo.key!),
          background: Container(
            color: Colors.red,
          ),
          onDismissed: (direction) {
            deleteTodo(todo);
          },
          child: ListTile(
            title: Text(todo.subject),
            trailing: IconButton(
              onPressed: () {
                updateTodo(todo);
              },
              icon: todo.completed
                  ? const Icon(
                      Icons.done_outline,
                      color: Colors.green,
                    )
                  : const Icon(Icons.done),
            ),
          ),
        );
      },
    );
  }
}
