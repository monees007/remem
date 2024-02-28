import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "Memorize2.db";
  static const _databaseVersion = 1;

  // make this a singleton class
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    print(path);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
    
          CREATE TABLE stack (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL
                        
          );
                
          ''');
    await db.execute('''
    CREATE TABLE card (
            id INTEGER PRIMARY KEY,
            question TEXT NOT NULL,
            answer TEXT NOT NULL,
            stack_id INTEGER NOT NULL,
            FOREIGN KEY (stack_id) REFERENCES stack (id)
          );
          ''');
  }

  Future<int> insertStack(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('stack', row);
  }

  Future<int> insertCard(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('card', row);
  }

  Future<List<Map<String, dynamic>>> getCardsOfStack(int stackId) async {
    Database db = await instance.database;
    return await db.query('card', where: 'stack_id = ?', whereArgs: [stackId]);
  }

  void addSampleData() async {
    var stackId = await insertStack({
      'title': 'Capital City',
      'description': 'This is a sample stack',
    });

    await insertCard({
      'question': 'What is the capital of USA?',
      'answer': 'The capital of France is Washington DC.',
      'stack_id': stackId,
    });
    await insertCard({
      'question': 'What is the capital of Pakistan?',
      'answer': 'The capital of France is Islamabad.',
      'stack_id': stackId,
    });

    await insertCard({
      'question': 'What is the capital of Bangladesh?',
      'answer': 'The capital of France is Dhaka.',
      'stack_id': stackId,
    });

    await insertCard({
      'question': 'What is the capital of India?',
      'answer': 'The capital of France is New Delhi.',
      'stack_id': stackId,
    });
  }

  Future<List<Map<String, dynamic>>> getAllStacks() async {
    Database db = await instance.database;
    return await db.query('stack');
  }

  Future<void> deleteStack(int stackId) async {
    Database db = await instance.database;
    await db.delete('stack', where: 'id = ?', whereArgs: [stackId]);
  }

  Future<void> addStack(
      String name, String description, List<Map<String, String>> qaList) async {
    try {
      Database db = await instance.database;

      // Insert stack details into the 'stack' table
      int stackId =
          await db.insert('stack', {'title': name, 'description': description});

      // Insert each question and answer pair into the 'card' table
      for (var qa in qaList) {
        await db.insert('card', {
          'stack_id': stackId,
          'question': qa['question'],
          'answer': qa['answer'],
        });
      }
    } catch (e) {
      print("Error while adding stack: $e");
      rethrow;
    }
  }

  Future<void> updateStack(
      int stackId, String newTitle, String newDescription) async {
    Database db = await instance.database;

    // Update the given stack
    db.update(
      'stack',
      {'title': newTitle, 'description': newDescription},
      where: 'id = ?',
      whereArgs: [stackId],
    );
  }
}
