import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/models/todo_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database _db;

  DatabaseHelper._instance();

  String todoTable = 'todo_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colStatus = 'status';

  Future<Database> get db async {
    if (_db == null) {
      _db = await _initDb();
    }
    return _db;
  }

  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + 'todo_list.db';
    final todoListDb =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return todoListDb;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
      'CREATE TABLE $todoTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDate TEXT, $colStatus INTEGER)',
    );
  }

  Future<List<Map<String, dynamic>>> getTodoMapList() async {
    Database db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(todoTable);
    return result;
  }

  Future<List<Todo>> getTodoList() async {
    final List<Map<String, dynamic>> todoMapList = await getTodoMapList();
    final List<Todo> todoList = [];
    todoMapList.forEach((todoMap) {
      todoList.add(Todo.fromMap(todoMap));
    });
    todoList.sort((todoA, todoB) => todoA.date.compareTo(todoB.date));
    return todoList;
  }

  Future<int> insertTodo(Todo todo) async {
    Database db = await this.db;
    final int result = await db.insert(todoTable, todo.toMap());
    return result;
  }

  Future<int> updateTodo(Todo todo) async {
    Database db = await this.db;
    final int result = await db.update(
      todoTable,
      todo.toMap(),
      where: '$colId = ?',
      whereArgs: [todo.id],
    );
    return result;
  }

  Future<int> deleteTodo(int id) async {
    Database db = await this.db;
    final int result = await db.delete(todoTable, where: '$colId = ?', whereArgs: [id]);
    return result;
  }
}
