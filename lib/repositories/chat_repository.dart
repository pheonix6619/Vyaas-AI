import '../database/app_database.dart';
import '../models/message.dart';

class ChatRepository {
  final AppDatabase _db;
  ChatRepository(this._db);

  // Watch all chats
  Stream<List<Chat>> watchAllChats() => _db.select(_db.chats).watch();

  // Insert a new chat, returning its id.
  Future<int> insertChat(ChatsCompanion chat) => _db.into(_db.chats).insert(chat);

  // Watch messages for a specific chat id.
  Stream<List<ChatMessage>> watchMessages(int chatId) {
    final query = _db.select(_db.chatMessages)..where((tbl) => tbl.chatId.equals(chatId));
    return query.watch().map((rows) => rows.map((row) => ChatMessage(
      content: row.content,
      isUser: row.isUser,
    )).toList());
  }

  // Insert a message.
  Future<int> insertMessage(ChatMessagesCompanion message) => _db.into(_db.chatMessages).insert(message);

  // Delete all messages for a given chat ID.
  Future<void> clearChatMessages(int chatId) async {
    await (_db.delete(_db.chatMessages)..where((tbl) => tbl.chatId.equals(chatId))).go();
  }}
