/*
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_mx4resto/models/db.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  Map<String, Database> _database = Map(); // Singleton Database

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<void> init(Tbl tbl) async {
    if (_database[tbl.tableName] == null) {
      _database[tbl.tableName] = await _initDB(tbl);
    }
    return;
  }

  Future<Database> _initDB(Tbl tbl) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'acct.db';

    // Open/create the database at a given path
    var db = await openDatabase(path, version: 1);
    await _createTbl(db, tbl);
    return db;
  }

  Future<void> _createTbl(Database db, Tbl tbl) async {
    String fields = '';
    tbl.header.forEach((h) {
      fields +=
          ', ' + h.colKey + ' ' + h.colType + (h.isUnique ? ' UNIQUE' : '');
    });
    String tableName = tbl.tableName;

    print(tableName);
    print(fields);
    await db.execute(
        'CREATE TABLE IF NOT EXISTS $tableName(id INTEGER PRIMARY KEY AUTOINCREMENT $fields)');
  }

  // Fetch Operation: Get all Row objects from database
  Future<List<Map<String, dynamic>>> getRowMapList(String tblName) async {
    Database db = _database[tblName];

    //var result = await db.rawQuery('SELECT * FROM $tableName order by $colPriority ASC');

    var result = await db.query(tblName, orderBy: 'id ASC');
    return result;
  }

  // Insert Operation: Insert a Row object to database
  Future<int> insertRow(String tblName, Map row) async {
    Database db = _database[tblName];
    var result = await db.insert(tblName, row);
    return result;
  }

  // Update Operation: Update a Row object and save it to database

  Future<int> updateRow(String tblName, Map row) async {
    var db = _database[tblName];

    var result =
        await db.update(tblName, row, where: 'id = ?', whereArgs: [row['id']]);
    return result;
  }

  // Delete Operation: Delete a Row object from database

  Future<int> deleteRow(String tblName, Map row) async {
    var db = _database[tblName];
    //int result = await db.rawDelete('DELETE FROM $tableName WHERE $colId = $id');
    int result =
        await db.delete(tblName, where: 'id = ?', whereArgs: [row['id']]);
    return result;
  }

  // Get number of Row objects in database
  Future<int> getCount(String tblName) async {
    Database db = _database[tblName];
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT(*) from $tblName');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'Row List' [ List<Row> ]
  Future<List<TblRow>> getRowList(Tbl tbl) async {
    var rowMapList = await getRowMapList(tbl.tableName);
    int count = rowMapList.length;

    List<TblRow> rowList = List<TblRow>();
    for (int i = 0; i < count; i++) {
      Map<String, dynamic> c = Map();
      tbl.header.forEach((h) {
        c[h.colKey] = rowMapList[i][h.colKey];
      });
      rowList.add(TblRow(id: rowMapList[i]['id'], cols: c));
    }
    return rowList;
  }
}
*/
