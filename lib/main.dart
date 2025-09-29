import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TodoProvider(),
      child: const TodoApp(),
    ),
  );
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TIG333 TODO',
      home: const TodoListPage(),
    );
  }
}

enum FilterOption { all, done, undone }

class Todo {
  String id;
  String title;
  bool done;

  Todo(this.title, {this.done = false, this.id = ""});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      json['title'],
      done: json['done'],
      id: json['id'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {"title": title, "done": done};
  }
}

// Provider
class TodoProvider extends ChangeNotifier {
  final String apiKey = "7865019f-5b97-4ce6-86ba-e896b6aa8709";
  final String baseUrl = "https://todoapp-api.apps.k8s.gu.se/todos";

  List<Todo> _todos = [];
  FilterOption _filter = FilterOption.all;

  List<Todo> get todos {
    switch (_filter) {
      case FilterOption.done:
        return _todos.where((t) => t.done).toList();
      case FilterOption.undone:
        return _todos.where((t) => !t.done).toList();
      case FilterOption.all:
        return _todos;
    }
  }

  FilterOption get filter => _filter;

  Future<void> fetchTodos() async {
    final url = Uri.parse("$baseUrl?key=$apiKey");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _todos = data.map((json) => Todo.fromJson(json)).toList();
      notifyListeners();
    } else {
      throw Exception("Failed to load todos");
    }
  }

  Future<void> addTodo(String title) async {
    final url = Uri.parse("$baseUrl?key=$apiKey");
    final response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"title": title, "done": false}));
    if (response.statusCode == 200) {
      await fetchTodos();
    } else {
      throw Exception("Failed to add todo");
    }
  }

  Future<void> toggleDone(int index) async {
    final todo = todos[index];
    final url = Uri.parse("$baseUrl/${todo.id}?key=$apiKey");
    final response = await http.put(url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"title": todo.title, "done": !todo.done}));
    if (response.statusCode == 200) {
      await fetchTodos();
    } else {
      throw Exception("Failed to update todo");
    }
  }

  Future<void> removeTodo(int index) async {
    final todo = todos[index];
    final url = Uri.parse("$baseUrl/${todo.id}?key=$apiKey");
    final response = await http.delete(url);
    if (response.statusCode == 200) {
      await fetchTodos();
    } else {
      throw Exception("Failed to delete todo");
    }
  }

  void changeFilter(FilterOption option) {
    _filter = option;
    notifyListeners();
  }
}

// Main skärm
class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<TodoProvider>();
    provider.fetchTodos();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TodoProvider>();
    final todos = provider.todos;

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
                PopupMenuButton<FilterOption>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: provider.changeFilter,
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: FilterOption.all,
                      child: Text('All'),
                    ),
                    PopupMenuItem(
                      value: FilterOption.done,
                      child: Text('Done'),
                    ),
                    PopupMenuItem(
                      value: FilterOption.undone,
                      child: Text('Undone'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: todos.isEmpty
          ? const Center(child: Text("No Todos"))
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return ListTile(
                  leading: Checkbox(
                    value: todo.done,
                    onChanged: (_) => provider.toggleDone(index),
                  ),
                  title: Text(
                    todo.title,
                    style: TextStyle(
                      decoration:
                          todo.done ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => provider.removeTodo(index),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTodo = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTodoPage()),
          );
          if (newTodo != null && newTodo is String && newTodo.trim().isNotEmpty) {
            provider.addTodo(newTodo);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Add sida
class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  final TextEditingController _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      Navigator.pop(context, text);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "What are you going to do?",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text("+ ADD"),
            ),
          ],
        ),
      ),
    );
  }
}
