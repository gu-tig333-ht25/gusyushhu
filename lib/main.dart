import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TIG333 TODO',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: const TodoListPage(),
    );
  }
}

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final todos = [
      {"title": "Write a book", "done": false},
      {"title": "Do homework", "done": false},
      {"title": "Tidy room", "done": true},
      {"title": "Watch TV", "done": false},
      {"title": "Nap", "done": false},
      {"title": "Shop groceries", "done": false},
      {"title": "Have fun", "done": false},
      {"title": "Meditate", "done": false},
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.grey,
              centerTitle: true,
              title: const Text("TIG333 TODO"),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.more_vert),
                  splashRadius: 24,
                ),
              ],
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return ListTile(
            leading: Checkbox(value: todo["done"] as bool, onChanged: (_) {}),
            title: Text(
              todo["title"] as String,
              style: TextStyle(
                decoration: (todo["done"] as bool)
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            trailing: const Icon(Icons.close),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTodoPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddTodoPage extends StatelessWidget {
  const AddTodoPage({super.key});

  @override
  Widget build(BuildContext context) {
  return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.grey,
              centerTitle: true,
              title: const Text("TIG333 TODO"),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: "What are you going to do?",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: const Text("+ ADD")),
          ],
        ),
      ),
    );
  }
}
