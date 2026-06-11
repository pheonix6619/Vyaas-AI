import 'dart:convert';

import 'package:drift/drift.dart';
import 'connection/connection.dart';

import 'security_service.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Chats, ChatMessages, Resumes, QueueJobs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  /// Named constructor for unit and widget tests – uses an in-memory DB
  /// passed directly so no file-system access is needed.
  AppDatabase.testDb(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Drop and recreate all tables for development schema upgrades
          for (final table in allTables) {
            await m.drop(table);
          }
          await m.createAll();
        },
      );
}

// Table definitions
class Chats extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withDefault(const Constant('Untitled'))();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
  TextColumn get activeModel => text().nullable()();
  TextColumn get provider => text().nullable()();
}

@DataClassName('ChatMessageEntry')
class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get chatId => integer()();
  TextColumn get content => text()();
  BoolColumn get isUser => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();
  IntColumn get promptTokens => integer().withDefault(const Constant(0))();
  IntColumn get completionTokens => integer().withDefault(const Constant(0))();
}

@DataClassName('ResumeEntry')
class Resumes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fullName => text()();
  TextColumn get title => text().nullable()();
  TextColumn get email => text()();
  TextColumn get phone => text()();
  TextColumn get website => text().nullable()();
  TextColumn get linkedin => text().nullable()();
  TextColumn get github => text().nullable()();
  TextColumn get objective => text().nullable()();
  TextColumn get aiObjective => text().nullable()();
  TextColumn get jdText => text().nullable()();
  TextColumn get education => text()(); // JSON List<Education>
  TextColumn get skills => text()(); // JSON Map<String, List<String>>
  TextColumn get projects => text()(); // JSON List<Project>
  TextColumn get experience => text().nullable()(); // JSON List<WorkExperience>
  TextColumn get certifications => text().nullable()(); // JSON List<Certification>
  TextColumn get achievements => text().nullable()(); // JSON List<String>
  DateTimeColumn get lastModified => dateTime().clientDefault(() => DateTime.now())();
}

class QueueJobs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get taskTitle => text()();
  IntColumn get priorityCode => integer().withDefault(const Constant(0))();
  TextColumn get statusString => text().withDefault(const Constant('pending'))();
  RealColumn get progressValue => real().withDefault(const Constant(0.0))();
  DateTimeColumn get scheduledTime => dateTime().nullable()();
  TextColumn get taskType => text().nullable()();
  TextColumn get payload => text().nullable()();
  TextColumn get result => text().nullable()();
}


