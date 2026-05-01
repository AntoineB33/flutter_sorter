import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:trying_flutter/features/media_sorter/data/models/sheet_data_table.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/analysis_result.dart';
import 'package:trying_flutter/features/media_sorter/domain/models/column_type.dart';

// This is the file Drift will generate. It will show as an error until you run the generator.
part 'app_database.g.dart';

// The @DriftDatabase annotation tells the generator which tables to include
@DriftDatabase(
  tables: [
    SheetDataTables,
    SheetCellsTable,
    SheetColumnTypesTable,
    UpdateHistoriesTable,
    RowsBottomPosTable,
    ColRightPosTable,
    RowsManuallyAdjustedHeightTable,
    ColsManuallyAdjustedWidthTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  // We tell the database where to store the data with this constructor
  AppDatabase() : super(_openConnection());

  // You must bump this number whenever you change or add table definitions.
  @override
  int get schemaVersion => 2;
  
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // ⚠️ DEV ONLY: Wipes all data and recreates tables when version changes
        for (final table in allTables) {
          await m.drop(table);
        }
        await m.createAll();
      },
    );
  }
}

// This function finds the right location to save the SQLite file on the device
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'app_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
