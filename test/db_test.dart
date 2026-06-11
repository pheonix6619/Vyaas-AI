import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:ai_workspace/database/app_database.dart';
import 'package:ai_workspace/repositories/chat_repository.dart';
import 'package:drift/drift.dart';

void main() {
  test('Drift ChatRepository insert and watch message test', () async {
    final db = AppDatabase.testDb(NativeDatabase.memory());
    final repo = ChatRepository(db);

    final chatId = await repo.insertChat(ChatsCompanion(
      title: const Value('Test Chat'),
    ));

    await repo.insertMessage(ChatMessagesCompanion(
      chatId: Value(chatId),
      content: const Value('AI: helloooo'),
      isUser: const Value(false),
    ));

    final messages = await repo.watchMessages(chatId).first;
    expect(messages.length, 1);
    print('MESSAGE CONTENT IN DB: "${messages.first.content}"');
    expect(messages.first.content, 'AI: helloooo');
    
    await db.close();
  });
}
