import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:v_card/models/contact_model.dart';

class DbHelper {
  final String _createTableContact = '''create table $tableContact(
    $tableContactColId integer primary key autoincrement,
    $tableContactColName text,
    $tableContactColMobile text,
    $tableContactColDesignation text,
    $tableContactColCompany text,
    $tableContactColAddress text,
    $tableContactColEmail text,
    $tableContactColWebsite text,
    $tableContactColImage text,
    $tableContactColIsFavorite integer)''';

  Future<Database> _open() async {
    final root = await getDatabasesPath();
    final dbPath = p.join(root, 'contact.db');
    return openDatabase(
      dbPath,
      version: 2,
      onCreate: (db, version) {
        db.execute(_createTableContact);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion == 1) {
          await db
              .execute('alter table $tableContact rename to ${'contact_old'}');
          await db.execute(_createTableContact);
          final rows = await db.query('contact_old');
          for (var row in rows) {
            await db.insert(tableContact, row);
          }
          await db.execute('drop table if exists ${'contact_old'}');
        }
      },
    );
  }

  Future<int> insertContact(ContactModel contactModel) async {
    final db = await _open();
    return db.insert(tableContact, contactModel.toMap());
  }

  Future<List<ContactModel>> getAllContacts() async {
    final db = await _open();
    final mapList = await db.query(tableContact);
    return List.generate(
        mapList.length, (index) => ContactModel.fromMap(mapList[index]));
  }

  Future<ContactModel> getContactById(int id) async {
    final db = await _open();
    final map = await db
        .query(tableContact, where: '$tableContactColId=?', whereArgs: [id]);
    return ContactModel.fromMap(map.first);
  }

  Future<List<ContactModel>> getAllFavoriteContacts() async {
    final db = await _open();
    final mapList = await db.query(tableContact,
        where: '$tableContactColIsFavorite=?', whereArgs: [1]);
    return List.generate(
        mapList.length, (index) => ContactModel.fromMap(mapList[index]));
  }

  Future<int> deleteContact(int id) async {
    final db = await _open();
    return db
        .delete(tableContact, where: '$tableContactColId=?', whereArgs: [id]);
  }

  Future<int> updateContactField(int id, Map<String, dynamic> map) async {
    final db = await _open();
    return db.update(tableContact, map,
        where: '$tableContactColId=?', whereArgs: [id]);
  }

  Future<int> updateFavorite(int id, int value) async {
    final db = await _open();
    return db.update(
      tableContact,
      {tableContactColIsFavorite: value},
      where: '$tableContactColId=?',
      whereArgs: [id],
    );
  }
}
