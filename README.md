# The Complete Guide to SQFlite in Flutter

## 1. Understanding SQLite and SQFlite

### What is SQLite?
SQLite is a lightweight, serverless, and self-contained relational database engine that is widely used in mobile and desktop applications. Unlike traditional database systems, SQLite doesn't require a separate server process and stores the entire database as a single file on the device. This makes it incredibly efficient for local data storage in mobile apps.

### What is SQFlite?
SQFlite is a Flutter plugin that provides a complete SQLite database solution for Flutter applications. It allows developers to use SQLite databases in their Flutter apps across multiple platforms, including Android, iOS, and web.

## 2. Setting Up SQFlite in Your Flutter Project

### Step 1: Add Dependency
First, add SQFlite to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path: ^1.8.3
```

### Step 2: Import Necessary Packages
In your Dart files, you'll typically import these packages:

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
```

## 3. Database Model and Data Representation

Let's create a practical example with a `Todo` model to demonstrate SQFlite concepts:

```dart
// Model class representing a Todo item
class Todo {
  final int? id;
  final String title;
  final String description;
  final bool isCompleted;

  Todo({
    this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
  });

  // Convert a Todo object into a Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  // Create a Todo object from a Map
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
```

## 4. Database Helper Class

Create a database helper class to manage database operations:

```dart
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Ensure database is initialized
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    // Get the default databases location
    String path = join(await getDatabasesPath(), 'todos_database.db');
    
    // Open the database
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  // Create database schema
  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        isCompleted INTEGER DEFAULT 0
      )
    ''');
  }

  // CRUD Operations

  // Create (Insert) a new todo
  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    return await db.insert(
      'todos', 
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Read all todos
  Future<List<Todo>> getAllTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos');
    
    return List.generate(maps.length, (index) {
      return Todo.fromMap(maps[index]);
    });
  }

  // Update a todo
  Future<int> updateTodo(Todo todo) async {
    final db = await database;
    return await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  // Delete a todo
  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Complex Query: Find completed todos
  Future<List<Todo>> getCompletedTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'todos',
      where: 'isCompleted = ?',
      whereArgs: [1],
    );
    
    return List.generate(maps.length, (index) {
      return Todo.fromMap(maps[index]);
    });
  }

  // Close the database
  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
  }
}
```

## 5. Using the Database in a Flutter Widget

Here's an example of how to use the DatabaseHelper in a Flutter application:

```dart
class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Todo> _todos = [];

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final todos = await DatabaseHelper.instance.getAllTodos();
    setState(() {
      _todos = todos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo List')),
      body: ListView.builder(
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          final todo = _todos[index];
          return ListTile(
            title: Text(todo.title),
            subtitle: Text(todo.description),
            trailing: Checkbox(
              value: todo.isCompleted,
              onChanged: (bool? value) async {
                // Update todo completion status
                final updatedTodo = Todo(
                  id: todo.id,
                  title: todo.title,
                  description: todo.description,
                  isCompleted: value ?? false,
                );
                
                await DatabaseHelper.instance.updateTodo(updatedTodo);
                _loadTodos();
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implement add todo logic
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

## 6. Best Practices and Considerations

1. **Database Versioning**: Use the `version` parameter in `openDatabase` to manage schema migrations.
2. **Error Handling**: Always wrap database operations in try-catch blocks.
3. **Performance**: For large datasets, consider using batch operations and pagination.
4. **Closing the Database**: Always close the database when it's no longer needed.

## 7. Potential Limitations

- SQFlite is not suitable for large-scale, multi-user databases
- Limited concurrent write operations
- Not ideal for complex relational queries compared to full-featured SQL databases

## Conclusion

SQFlite provides a powerful, lightweight solution for local data persistence in Flutter applications. By understanding its core concepts and following best practices, you can effectively manage local data storage in your mobile apps.
