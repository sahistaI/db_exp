
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {

  DbHelper._();

  static DbHelper getInstance() => DbHelper._();

  Database? mDB;

  static final String TABLE_NOTE = "note";
  static final String NOTE_COLUMN_ID = "n_id";
  static final String NOTE_COLUMN_TITLE = "n_title";
  static final String NOTE_COLUMN_DESC = "n_desc";
  static final String NOTE_COLUMN_CREATED_AT = "n_created_at";
  static final String NOTE_COMPLETE_AT = "n_complete_at";
  static final String NOTE_CHECKED = "n_check";

  Future<Database> initDB() async {
    mDB = mDB ?? await openDB();
    print("db Opened!!");
    return mDB!;
  }

  Future<Database> openDB() async {
    var dirPath = await getApplicationDocumentsDirectory();
    var dbPath = join(dirPath.path, "noteDB.db");

    return openDatabase(dbPath, version: 1, onCreate: (db, version) {
      print("db Created!!");
      db.execute("create table $TABLE_NOTE ( $NOTE_COLUMN_ID integer primary key autoincrement, $NOTE_COLUMN_TITLE text, $NOTE_COLUMN_DESC text, $NOTE_COLUMN_CREATED_AT text, $NOTE_COMPLETE_AT text, $NOTE_CHECKED boolean)");
    });
  }

  // insert
  Future<bool> addNote({required String title, required String desc, required String dueDateAt}) async {
    Database db = await initDB();

    int rowsEffected = await db.insert(TABLE_NOTE, {
      NOTE_COLUMN_TITLE: title,
      NOTE_COLUMN_DESC: desc,
      NOTE_COLUMN_CREATED_AT: DateTime.now().millisecondsSinceEpoch.toString(),
      NOTE_COMPLETE_AT: dueDateAt,
      NOTE_CHECKED : 0,

    });

    return rowsEffected > 0;
  }
  
  // select

  Future<List<Map<String,dynamic>>> fetchNote() async {
    
    Database db = await initDB();
    
    List<Map<String,dynamic>> allNotes = await  db.query(TABLE_NOTE);

    return allNotes;

    
  }

  // update


Future<bool> updateNote({required String title, required String desc, required int id}) async{

    Database db = await initDB();

    int rowsEffected = await db.update(TABLE_NOTE, {
      NOTE_COLUMN_TITLE: title,
      NOTE_COLUMN_DESC: desc,
    },where: "$NOTE_COLUMN_ID = ?", whereArgs: ['$id']);

    return rowsEffected>0;

}
 // delete

Future<bool> deleteNote ({required int id}) async{

    Database db = await initDB();
    
    int rowsEffected = await db.delete(TABLE_NOTE,where: "$NOTE_COLUMN_ID =?", whereArgs:['$id'] );

    return rowsEffected>0;

}

Future<bool> updateStatus({required int id, required bool isChecked}) async{

    Database db = await initDB();

    int rowsEffected = await db.update(TABLE_NOTE, {
      NOTE_CHECKED: isChecked ? 1:0
    }, where: "$NOTE_COLUMN_ID = ?", whereArgs: ['$id']);

    return rowsEffected >0;

}


  
  
}