import 'package:injectable/injectable.dart';
import 'app_database.dart';
import '../core/utils/constants.dart';

@singleton
class DatabaseService {
  AppDatabase? _database;

  Future<AppDatabase> get database async {
    _database ??= await $FloorAppDatabase
        .databaseBuilder(AppConstants.databaseName)
        .build();
    return _database!;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}

@module
abstract class DatabaseModule {
  @singleton
  @preResolve
  Future<AppDatabase> get appDatabase async {
    return await $FloorAppDatabase
        .databaseBuilder(AppConstants.databaseName)
        .build();
  }
}
