import 'package:injectable/injectable.dart';
import 'app_database.dart';
import '../core/utils/constants.dart';
import 'migrations.dart';

@singleton
class DatabaseService {
  AppDatabase? _database;

  Future<AppDatabase> get database async {
    _database ??= await $FloorAppDatabase
        .databaseBuilder(AppConstants.databaseName)
        .addMigrations([
          migration1to2,
          migration2to3,
          migration3to4,
          migration4to5,
          migration5to6,
          migration6to7,
        ])
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
        .addMigrations([
          migration1to2,
          migration2to3,
          migration3to4,
          migration4to5,
          migration5to6,
          migration6to7,
        ])
        .build();
  }
}
