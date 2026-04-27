import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Users extends Table {
  TextColumn get employeeId => text()(); // Primary Key
  TextColumn get password => text()();

  @override
  Set<Column> get primaryKey => {employeeId};
}

class CapturedImages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get imagePath => text()();
  DateTimeColumn get deviceTimestamp => dateTime()();
  DateTimeColumn get lastActivity => dateTime()();
  IntColumn get timeOffset => integer().map(const DurationConverter())();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get place => text()();
  TextColumn get employeeId => text().references(Users, #employeeId)();

  // This flag tells us if the record has reached the cloud
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

class TimeAnchors extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get lastTick => dateTime()();
  IntColumn get uptimeSeconds => integer()(); // Seconds since boot
}

class DurationConverter extends TypeConverter<Duration, int> {
  const DurationConverter();

  @override
  Duration fromSql(int fromDb) {
    return Duration(microseconds: fromDb);
  }

  @override
  int toSql(Duration value) {
    return value.inMicroseconds;
  }
}

@DriftDatabase(tables: [Users, CapturedImages, TimeAnchors])
class AppDatabase extends _$AppDatabase {
  // After generating code, this class needs to define a `schemaVersion` getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/setup/
  AppDatabase() : super(_openConnection());

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // This will delete all tables and recreate them from scratch
      // DO NOT use this in production!
      for (final table in allTables) {
        await m.deleteTable(table.actualTableName);
      }
      await m.createAll();
    },
  );

  Future<void> clearUserData() {
    return delete(capturedImages).go();
  }

  Future<void> upsertTimeAnchor(DateTime wallTime, int uptimeSeconds) async {
    // Always delete old anchors and keep just one clean row
    await delete(timeAnchors).go();
    await into(timeAnchors).insert(
      TimeAnchorsCompanion.insert(
        lastTick: wallTime,
        uptimeSeconds: uptimeSeconds,
      ),
    );
  }

  @override
  int get schemaVersion => 17;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'my_database');
  }
}
