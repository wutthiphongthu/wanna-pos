import 'package:injectable/injectable.dart';
import 'app_database.dart';

@singleton
class DatabaseService {
  AppDatabase? _database;

  Future<AppDatabase> get database async {
    _database ??=
        await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    return _database!;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
