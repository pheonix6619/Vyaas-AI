// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ChatsTable extends Chats with TableInfo<$ChatsTable, Chat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Untitled'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  static const VerificationMeta _activeModelMeta =
      const VerificationMeta('activeModel');
  @override
  late final GeneratedColumn<String> activeModel = GeneratedColumn<String>(
      'active_model', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _providerMeta =
      const VerificationMeta('provider');
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
      'provider', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, createdAt, activeModel, provider];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chats';
  @override
  VerificationContext validateIntegrity(Insertable<Chat> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('active_model')) {
      context.handle(
          _activeModelMeta,
          activeModel.isAcceptableOrUnknown(
              data['active_model']!, _activeModelMeta));
    }
    if (data.containsKey('provider')) {
      context.handle(_providerMeta,
          provider.isAcceptableOrUnknown(data['provider']!, _providerMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Chat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Chat(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      activeModel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}active_model']),
      provider: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider']),
    );
  }

  @override
  $ChatsTable createAlias(String alias) {
    return $ChatsTable(attachedDatabase, alias);
  }
}

class Chat extends DataClass implements Insertable<Chat> {
  final int id;
  final String title;
  final DateTime createdAt;
  final String? activeModel;
  final String? provider;
  const Chat(
      {required this.id,
      required this.title,
      required this.createdAt,
      this.activeModel,
      this.provider});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || activeModel != null) {
      map['active_model'] = Variable<String>(activeModel);
    }
    if (!nullToAbsent || provider != null) {
      map['provider'] = Variable<String>(provider);
    }
    return map;
  }

  ChatsCompanion toCompanion(bool nullToAbsent) {
    return ChatsCompanion(
      id: Value(id),
      title: Value(title),
      createdAt: Value(createdAt),
      activeModel: activeModel == null && nullToAbsent
          ? const Value.absent()
          : Value(activeModel),
      provider: provider == null && nullToAbsent
          ? const Value.absent()
          : Value(provider),
    );
  }

  factory Chat.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Chat(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      activeModel: serializer.fromJson<String?>(json['activeModel']),
      provider: serializer.fromJson<String?>(json['provider']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'activeModel': serializer.toJson<String?>(activeModel),
      'provider': serializer.toJson<String?>(provider),
    };
  }

  Chat copyWith(
          {int? id,
          String? title,
          DateTime? createdAt,
          Value<String?> activeModel = const Value.absent(),
          Value<String?> provider = const Value.absent()}) =>
      Chat(
        id: id ?? this.id,
        title: title ?? this.title,
        createdAt: createdAt ?? this.createdAt,
        activeModel: activeModel.present ? activeModel.value : this.activeModel,
        provider: provider.present ? provider.value : this.provider,
      );
  Chat copyWithCompanion(ChatsCompanion data) {
    return Chat(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      activeModel:
          data.activeModel.present ? data.activeModel.value : this.activeModel,
      provider: data.provider.present ? data.provider.value : this.provider,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Chat(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('activeModel: $activeModel, ')
          ..write('provider: $provider')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, createdAt, activeModel, provider);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chat &&
          other.id == this.id &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.activeModel == this.activeModel &&
          other.provider == this.provider);
}

class ChatsCompanion extends UpdateCompanion<Chat> {
  final Value<int> id;
  final Value<String> title;
  final Value<DateTime> createdAt;
  final Value<String?> activeModel;
  final Value<String?> provider;
  const ChatsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.activeModel = const Value.absent(),
    this.provider = const Value.absent(),
  });
  ChatsCompanion.insert({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.activeModel = const Value.absent(),
    this.provider = const Value.absent(),
  });
  static Insertable<Chat> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<DateTime>? createdAt,
    Expression<String>? activeModel,
    Expression<String>? provider,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (activeModel != null) 'active_model': activeModel,
      if (provider != null) 'provider': provider,
    });
  }

  ChatsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<DateTime>? createdAt,
      Value<String?>? activeModel,
      Value<String?>? provider}) {
    return ChatsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      activeModel: activeModel ?? this.activeModel,
      provider: provider ?? this.provider,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (activeModel.present) {
      map['active_model'] = Variable<String>(activeModel.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('activeModel: $activeModel, ')
          ..write('provider: $provider')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessageEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _chatIdMeta = const VerificationMeta('chatId');
  @override
  late final GeneratedColumn<int> chatId = GeneratedColumn<int>(
      'chat_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isUserMeta = const VerificationMeta('isUser');
  @override
  late final GeneratedColumn<bool> isUser = GeneratedColumn<bool>(
      'is_user', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_user" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  static const VerificationMeta _promptTokensMeta =
      const VerificationMeta('promptTokens');
  @override
  late final GeneratedColumn<int> promptTokens = GeneratedColumn<int>(
      'prompt_tokens', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _completionTokensMeta =
      const VerificationMeta('completionTokens');
  @override
  late final GeneratedColumn<int> completionTokens = GeneratedColumn<int>(
      'completion_tokens', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, chatId, content, isUser, createdAt, promptTokens, completionTokens];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(Insertable<ChatMessageEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('chat_id')) {
      context.handle(_chatIdMeta,
          chatId.isAcceptableOrUnknown(data['chat_id']!, _chatIdMeta));
    } else if (isInserting) {
      context.missing(_chatIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('is_user')) {
      context.handle(_isUserMeta,
          isUser.isAcceptableOrUnknown(data['is_user']!, _isUserMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('prompt_tokens')) {
      context.handle(
          _promptTokensMeta,
          promptTokens.isAcceptableOrUnknown(
              data['prompt_tokens']!, _promptTokensMeta));
    }
    if (data.containsKey('completion_tokens')) {
      context.handle(
          _completionTokensMeta,
          completionTokens.isAcceptableOrUnknown(
              data['completion_tokens']!, _completionTokensMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessageEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessageEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      chatId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chat_id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      isUser: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_user'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      promptTokens: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}prompt_tokens'])!,
      completionTokens: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}completion_tokens'])!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessageEntry extends DataClass
    implements Insertable<ChatMessageEntry> {
  final int id;
  final int chatId;
  final String content;
  final bool isUser;
  final DateTime createdAt;
  final int promptTokens;
  final int completionTokens;
  const ChatMessageEntry(
      {required this.id,
      required this.chatId,
      required this.content,
      required this.isUser,
      required this.createdAt,
      required this.promptTokens,
      required this.completionTokens});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['chat_id'] = Variable<int>(chatId);
    map['content'] = Variable<String>(content);
    map['is_user'] = Variable<bool>(isUser);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['prompt_tokens'] = Variable<int>(promptTokens);
    map['completion_tokens'] = Variable<int>(completionTokens);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      chatId: Value(chatId),
      content: Value(content),
      isUser: Value(isUser),
      createdAt: Value(createdAt),
      promptTokens: Value(promptTokens),
      completionTokens: Value(completionTokens),
    );
  }

  factory ChatMessageEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessageEntry(
      id: serializer.fromJson<int>(json['id']),
      chatId: serializer.fromJson<int>(json['chatId']),
      content: serializer.fromJson<String>(json['content']),
      isUser: serializer.fromJson<bool>(json['isUser']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      promptTokens: serializer.fromJson<int>(json['promptTokens']),
      completionTokens: serializer.fromJson<int>(json['completionTokens']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'chatId': serializer.toJson<int>(chatId),
      'content': serializer.toJson<String>(content),
      'isUser': serializer.toJson<bool>(isUser),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'promptTokens': serializer.toJson<int>(promptTokens),
      'completionTokens': serializer.toJson<int>(completionTokens),
    };
  }

  ChatMessageEntry copyWith(
          {int? id,
          int? chatId,
          String? content,
          bool? isUser,
          DateTime? createdAt,
          int? promptTokens,
          int? completionTokens}) =>
      ChatMessageEntry(
        id: id ?? this.id,
        chatId: chatId ?? this.chatId,
        content: content ?? this.content,
        isUser: isUser ?? this.isUser,
        createdAt: createdAt ?? this.createdAt,
        promptTokens: promptTokens ?? this.promptTokens,
        completionTokens: completionTokens ?? this.completionTokens,
      );
  ChatMessageEntry copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessageEntry(
      id: data.id.present ? data.id.value : this.id,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      content: data.content.present ? data.content.value : this.content,
      isUser: data.isUser.present ? data.isUser.value : this.isUser,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      promptTokens: data.promptTokens.present
          ? data.promptTokens.value
          : this.promptTokens,
      completionTokens: data.completionTokens.present
          ? data.completionTokens.value
          : this.completionTokens,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageEntry(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('content: $content, ')
          ..write('isUser: $isUser, ')
          ..write('createdAt: $createdAt, ')
          ..write('promptTokens: $promptTokens, ')
          ..write('completionTokens: $completionTokens')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, chatId, content, isUser, createdAt, promptTokens, completionTokens);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessageEntry &&
          other.id == this.id &&
          other.chatId == this.chatId &&
          other.content == this.content &&
          other.isUser == this.isUser &&
          other.createdAt == this.createdAt &&
          other.promptTokens == this.promptTokens &&
          other.completionTokens == this.completionTokens);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessageEntry> {
  final Value<int> id;
  final Value<int> chatId;
  final Value<String> content;
  final Value<bool> isUser;
  final Value<DateTime> createdAt;
  final Value<int> promptTokens;
  final Value<int> completionTokens;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.chatId = const Value.absent(),
    this.content = const Value.absent(),
    this.isUser = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.promptTokens = const Value.absent(),
    this.completionTokens = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    this.id = const Value.absent(),
    required int chatId,
    required String content,
    this.isUser = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.promptTokens = const Value.absent(),
    this.completionTokens = const Value.absent(),
  })  : chatId = Value(chatId),
        content = Value(content);
  static Insertable<ChatMessageEntry> custom({
    Expression<int>? id,
    Expression<int>? chatId,
    Expression<String>? content,
    Expression<bool>? isUser,
    Expression<DateTime>? createdAt,
    Expression<int>? promptTokens,
    Expression<int>? completionTokens,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chatId != null) 'chat_id': chatId,
      if (content != null) 'content': content,
      if (isUser != null) 'is_user': isUser,
      if (createdAt != null) 'created_at': createdAt,
      if (promptTokens != null) 'prompt_tokens': promptTokens,
      if (completionTokens != null) 'completion_tokens': completionTokens,
    });
  }

  ChatMessagesCompanion copyWith(
      {Value<int>? id,
      Value<int>? chatId,
      Value<String>? content,
      Value<bool>? isUser,
      Value<DateTime>? createdAt,
      Value<int>? promptTokens,
      Value<int>? completionTokens}) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      createdAt: createdAt ?? this.createdAt,
      promptTokens: promptTokens ?? this.promptTokens,
      completionTokens: completionTokens ?? this.completionTokens,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<int>(chatId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (isUser.present) {
      map['is_user'] = Variable<bool>(isUser.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (promptTokens.present) {
      map['prompt_tokens'] = Variable<int>(promptTokens.value);
    }
    if (completionTokens.present) {
      map['completion_tokens'] = Variable<int>(completionTokens.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('chatId: $chatId, ')
          ..write('content: $content, ')
          ..write('isUser: $isUser, ')
          ..write('createdAt: $createdAt, ')
          ..write('promptTokens: $promptTokens, ')
          ..write('completionTokens: $completionTokens')
          ..write(')'))
        .toString();
  }
}

class $ResumesTable extends Resumes with TableInfo<$ResumesTable, ResumeEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResumesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _fullNameMeta =
      const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
      'full_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _websiteMeta =
      const VerificationMeta('website');
  @override
  late final GeneratedColumn<String> website = GeneratedColumn<String>(
      'website', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _linkedinMeta =
      const VerificationMeta('linkedin');
  @override
  late final GeneratedColumn<String> linkedin = GeneratedColumn<String>(
      'linkedin', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _githubMeta = const VerificationMeta('github');
  @override
  late final GeneratedColumn<String> github = GeneratedColumn<String>(
      'github', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _objectiveMeta =
      const VerificationMeta('objective');
  @override
  late final GeneratedColumn<String> objective = GeneratedColumn<String>(
      'objective', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _aiObjectiveMeta =
      const VerificationMeta('aiObjective');
  @override
  late final GeneratedColumn<String> aiObjective = GeneratedColumn<String>(
      'ai_objective', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _jdTextMeta = const VerificationMeta('jdText');
  @override
  late final GeneratedColumn<String> jdText = GeneratedColumn<String>(
      'jd_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _educationMeta =
      const VerificationMeta('education');
  @override
  late final GeneratedColumn<String> education = GeneratedColumn<String>(
      'education', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _skillsMeta = const VerificationMeta('skills');
  @override
  late final GeneratedColumn<String> skills = GeneratedColumn<String>(
      'skills', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _projectsMeta =
      const VerificationMeta('projects');
  @override
  late final GeneratedColumn<String> projects = GeneratedColumn<String>(
      'projects', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _experienceMeta =
      const VerificationMeta('experience');
  @override
  late final GeneratedColumn<String> experience = GeneratedColumn<String>(
      'experience', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _certificationsMeta =
      const VerificationMeta('certifications');
  @override
  late final GeneratedColumn<String> certifications = GeneratedColumn<String>(
      'certifications', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _achievementsMeta =
      const VerificationMeta('achievements');
  @override
  late final GeneratedColumn<String> achievements = GeneratedColumn<String>(
      'achievements', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastModifiedMeta =
      const VerificationMeta('lastModified');
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
      'last_modified', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      clientDefault: () => DateTime.now());
  @override
  List<GeneratedColumn> get $columns => [
        id,
        fullName,
        title,
        email,
        phone,
        website,
        linkedin,
        github,
        objective,
        aiObjective,
        jdText,
        education,
        skills,
        projects,
        experience,
        certifications,
        achievements,
        lastModified
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'resumes';
  @override
  VerificationContext validateIntegrity(Insertable<ResumeEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta,
          fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('website')) {
      context.handle(_websiteMeta,
          website.isAcceptableOrUnknown(data['website']!, _websiteMeta));
    }
    if (data.containsKey('linkedin')) {
      context.handle(_linkedinMeta,
          linkedin.isAcceptableOrUnknown(data['linkedin']!, _linkedinMeta));
    }
    if (data.containsKey('github')) {
      context.handle(_githubMeta,
          github.isAcceptableOrUnknown(data['github']!, _githubMeta));
    }
    if (data.containsKey('objective')) {
      context.handle(_objectiveMeta,
          objective.isAcceptableOrUnknown(data['objective']!, _objectiveMeta));
    }
    if (data.containsKey('ai_objective')) {
      context.handle(
          _aiObjectiveMeta,
          aiObjective.isAcceptableOrUnknown(
              data['ai_objective']!, _aiObjectiveMeta));
    }
    if (data.containsKey('jd_text')) {
      context.handle(_jdTextMeta,
          jdText.isAcceptableOrUnknown(data['jd_text']!, _jdTextMeta));
    }
    if (data.containsKey('education')) {
      context.handle(_educationMeta,
          education.isAcceptableOrUnknown(data['education']!, _educationMeta));
    } else if (isInserting) {
      context.missing(_educationMeta);
    }
    if (data.containsKey('skills')) {
      context.handle(_skillsMeta,
          skills.isAcceptableOrUnknown(data['skills']!, _skillsMeta));
    } else if (isInserting) {
      context.missing(_skillsMeta);
    }
    if (data.containsKey('projects')) {
      context.handle(_projectsMeta,
          projects.isAcceptableOrUnknown(data['projects']!, _projectsMeta));
    } else if (isInserting) {
      context.missing(_projectsMeta);
    }
    if (data.containsKey('experience')) {
      context.handle(
          _experienceMeta,
          experience.isAcceptableOrUnknown(
              data['experience']!, _experienceMeta));
    }
    if (data.containsKey('certifications')) {
      context.handle(
          _certificationsMeta,
          certifications.isAcceptableOrUnknown(
              data['certifications']!, _certificationsMeta));
    }
    if (data.containsKey('achievements')) {
      context.handle(
          _achievementsMeta,
          achievements.isAcceptableOrUnknown(
              data['achievements']!, _achievementsMeta));
    }
    if (data.containsKey('last_modified')) {
      context.handle(
          _lastModifiedMeta,
          lastModified.isAcceptableOrUnknown(
              data['last_modified']!, _lastModifiedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResumeEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResumeEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      fullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      website: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}website']),
      linkedin: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}linkedin']),
      github: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}github']),
      objective: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}objective']),
      aiObjective: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ai_objective']),
      jdText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}jd_text']),
      education: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}education'])!,
      skills: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}skills'])!,
      projects: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}projects'])!,
      experience: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}experience']),
      certifications: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}certifications']),
      achievements: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}achievements']),
      lastModified: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_modified'])!,
    );
  }

  @override
  $ResumesTable createAlias(String alias) {
    return $ResumesTable(attachedDatabase, alias);
  }
}

class ResumeEntry extends DataClass implements Insertable<ResumeEntry> {
  final int id;
  final String fullName;
  final String? title;
  final String email;
  final String phone;
  final String? website;
  final String? linkedin;
  final String? github;
  final String? objective;
  final String? aiObjective;
  final String? jdText;
  final String education;
  final String skills;
  final String projects;
  final String? experience;
  final String? certifications;
  final String? achievements;
  final DateTime lastModified;
  const ResumeEntry(
      {required this.id,
      required this.fullName,
      this.title,
      required this.email,
      required this.phone,
      this.website,
      this.linkedin,
      this.github,
      this.objective,
      this.aiObjective,
      this.jdText,
      required this.education,
      required this.skills,
      required this.projects,
      this.experience,
      this.certifications,
      this.achievements,
      required this.lastModified});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['email'] = Variable<String>(email);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || website != null) {
      map['website'] = Variable<String>(website);
    }
    if (!nullToAbsent || linkedin != null) {
      map['linkedin'] = Variable<String>(linkedin);
    }
    if (!nullToAbsent || github != null) {
      map['github'] = Variable<String>(github);
    }
    if (!nullToAbsent || objective != null) {
      map['objective'] = Variable<String>(objective);
    }
    if (!nullToAbsent || aiObjective != null) {
      map['ai_objective'] = Variable<String>(aiObjective);
    }
    if (!nullToAbsent || jdText != null) {
      map['jd_text'] = Variable<String>(jdText);
    }
    map['education'] = Variable<String>(education);
    map['skills'] = Variable<String>(skills);
    map['projects'] = Variable<String>(projects);
    if (!nullToAbsent || experience != null) {
      map['experience'] = Variable<String>(experience);
    }
    if (!nullToAbsent || certifications != null) {
      map['certifications'] = Variable<String>(certifications);
    }
    if (!nullToAbsent || achievements != null) {
      map['achievements'] = Variable<String>(achievements);
    }
    map['last_modified'] = Variable<DateTime>(lastModified);
    return map;
  }

  ResumesCompanion toCompanion(bool nullToAbsent) {
    return ResumesCompanion(
      id: Value(id),
      fullName: Value(fullName),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      email: Value(email),
      phone: Value(phone),
      website: website == null && nullToAbsent
          ? const Value.absent()
          : Value(website),
      linkedin: linkedin == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedin),
      github:
          github == null && nullToAbsent ? const Value.absent() : Value(github),
      objective: objective == null && nullToAbsent
          ? const Value.absent()
          : Value(objective),
      aiObjective: aiObjective == null && nullToAbsent
          ? const Value.absent()
          : Value(aiObjective),
      jdText:
          jdText == null && nullToAbsent ? const Value.absent() : Value(jdText),
      education: Value(education),
      skills: Value(skills),
      projects: Value(projects),
      experience: experience == null && nullToAbsent
          ? const Value.absent()
          : Value(experience),
      certifications: certifications == null && nullToAbsent
          ? const Value.absent()
          : Value(certifications),
      achievements: achievements == null && nullToAbsent
          ? const Value.absent()
          : Value(achievements),
      lastModified: Value(lastModified),
    );
  }

  factory ResumeEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResumeEntry(
      id: serializer.fromJson<int>(json['id']),
      fullName: serializer.fromJson<String>(json['fullName']),
      title: serializer.fromJson<String?>(json['title']),
      email: serializer.fromJson<String>(json['email']),
      phone: serializer.fromJson<String>(json['phone']),
      website: serializer.fromJson<String?>(json['website']),
      linkedin: serializer.fromJson<String?>(json['linkedin']),
      github: serializer.fromJson<String?>(json['github']),
      objective: serializer.fromJson<String?>(json['objective']),
      aiObjective: serializer.fromJson<String?>(json['aiObjective']),
      jdText: serializer.fromJson<String?>(json['jdText']),
      education: serializer.fromJson<String>(json['education']),
      skills: serializer.fromJson<String>(json['skills']),
      projects: serializer.fromJson<String>(json['projects']),
      experience: serializer.fromJson<String?>(json['experience']),
      certifications: serializer.fromJson<String?>(json['certifications']),
      achievements: serializer.fromJson<String?>(json['achievements']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fullName': serializer.toJson<String>(fullName),
      'title': serializer.toJson<String?>(title),
      'email': serializer.toJson<String>(email),
      'phone': serializer.toJson<String>(phone),
      'website': serializer.toJson<String?>(website),
      'linkedin': serializer.toJson<String?>(linkedin),
      'github': serializer.toJson<String?>(github),
      'objective': serializer.toJson<String?>(objective),
      'aiObjective': serializer.toJson<String?>(aiObjective),
      'jdText': serializer.toJson<String?>(jdText),
      'education': serializer.toJson<String>(education),
      'skills': serializer.toJson<String>(skills),
      'projects': serializer.toJson<String>(projects),
      'experience': serializer.toJson<String?>(experience),
      'certifications': serializer.toJson<String?>(certifications),
      'achievements': serializer.toJson<String?>(achievements),
      'lastModified': serializer.toJson<DateTime>(lastModified),
    };
  }

  ResumeEntry copyWith(
          {int? id,
          String? fullName,
          Value<String?> title = const Value.absent(),
          String? email,
          String? phone,
          Value<String?> website = const Value.absent(),
          Value<String?> linkedin = const Value.absent(),
          Value<String?> github = const Value.absent(),
          Value<String?> objective = const Value.absent(),
          Value<String?> aiObjective = const Value.absent(),
          Value<String?> jdText = const Value.absent(),
          String? education,
          String? skills,
          String? projects,
          Value<String?> experience = const Value.absent(),
          Value<String?> certifications = const Value.absent(),
          Value<String?> achievements = const Value.absent(),
          DateTime? lastModified}) =>
      ResumeEntry(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        title: title.present ? title.value : this.title,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        website: website.present ? website.value : this.website,
        linkedin: linkedin.present ? linkedin.value : this.linkedin,
        github: github.present ? github.value : this.github,
        objective: objective.present ? objective.value : this.objective,
        aiObjective: aiObjective.present ? aiObjective.value : this.aiObjective,
        jdText: jdText.present ? jdText.value : this.jdText,
        education: education ?? this.education,
        skills: skills ?? this.skills,
        projects: projects ?? this.projects,
        experience: experience.present ? experience.value : this.experience,
        certifications:
            certifications.present ? certifications.value : this.certifications,
        achievements:
            achievements.present ? achievements.value : this.achievements,
        lastModified: lastModified ?? this.lastModified,
      );
  ResumeEntry copyWithCompanion(ResumesCompanion data) {
    return ResumeEntry(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      title: data.title.present ? data.title.value : this.title,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      website: data.website.present ? data.website.value : this.website,
      linkedin: data.linkedin.present ? data.linkedin.value : this.linkedin,
      github: data.github.present ? data.github.value : this.github,
      objective: data.objective.present ? data.objective.value : this.objective,
      aiObjective:
          data.aiObjective.present ? data.aiObjective.value : this.aiObjective,
      jdText: data.jdText.present ? data.jdText.value : this.jdText,
      education: data.education.present ? data.education.value : this.education,
      skills: data.skills.present ? data.skills.value : this.skills,
      projects: data.projects.present ? data.projects.value : this.projects,
      experience:
          data.experience.present ? data.experience.value : this.experience,
      certifications: data.certifications.present
          ? data.certifications.value
          : this.certifications,
      achievements: data.achievements.present
          ? data.achievements.value
          : this.achievements,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResumeEntry(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('title: $title, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('website: $website, ')
          ..write('linkedin: $linkedin, ')
          ..write('github: $github, ')
          ..write('objective: $objective, ')
          ..write('aiObjective: $aiObjective, ')
          ..write('jdText: $jdText, ')
          ..write('education: $education, ')
          ..write('skills: $skills, ')
          ..write('projects: $projects, ')
          ..write('experience: $experience, ')
          ..write('certifications: $certifications, ')
          ..write('achievements: $achievements, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      fullName,
      title,
      email,
      phone,
      website,
      linkedin,
      github,
      objective,
      aiObjective,
      jdText,
      education,
      skills,
      projects,
      experience,
      certifications,
      achievements,
      lastModified);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResumeEntry &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.title == this.title &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.website == this.website &&
          other.linkedin == this.linkedin &&
          other.github == this.github &&
          other.objective == this.objective &&
          other.aiObjective == this.aiObjective &&
          other.jdText == this.jdText &&
          other.education == this.education &&
          other.skills == this.skills &&
          other.projects == this.projects &&
          other.experience == this.experience &&
          other.certifications == this.certifications &&
          other.achievements == this.achievements &&
          other.lastModified == this.lastModified);
}

class ResumesCompanion extends UpdateCompanion<ResumeEntry> {
  final Value<int> id;
  final Value<String> fullName;
  final Value<String?> title;
  final Value<String> email;
  final Value<String> phone;
  final Value<String?> website;
  final Value<String?> linkedin;
  final Value<String?> github;
  final Value<String?> objective;
  final Value<String?> aiObjective;
  final Value<String?> jdText;
  final Value<String> education;
  final Value<String> skills;
  final Value<String> projects;
  final Value<String?> experience;
  final Value<String?> certifications;
  final Value<String?> achievements;
  final Value<DateTime> lastModified;
  const ResumesCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.title = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.website = const Value.absent(),
    this.linkedin = const Value.absent(),
    this.github = const Value.absent(),
    this.objective = const Value.absent(),
    this.aiObjective = const Value.absent(),
    this.jdText = const Value.absent(),
    this.education = const Value.absent(),
    this.skills = const Value.absent(),
    this.projects = const Value.absent(),
    this.experience = const Value.absent(),
    this.certifications = const Value.absent(),
    this.achievements = const Value.absent(),
    this.lastModified = const Value.absent(),
  });
  ResumesCompanion.insert({
    this.id = const Value.absent(),
    required String fullName,
    this.title = const Value.absent(),
    required String email,
    required String phone,
    this.website = const Value.absent(),
    this.linkedin = const Value.absent(),
    this.github = const Value.absent(),
    this.objective = const Value.absent(),
    this.aiObjective = const Value.absent(),
    this.jdText = const Value.absent(),
    required String education,
    required String skills,
    required String projects,
    this.experience = const Value.absent(),
    this.certifications = const Value.absent(),
    this.achievements = const Value.absent(),
    this.lastModified = const Value.absent(),
  })  : fullName = Value(fullName),
        email = Value(email),
        phone = Value(phone),
        education = Value(education),
        skills = Value(skills),
        projects = Value(projects);
  static Insertable<ResumeEntry> custom({
    Expression<int>? id,
    Expression<String>? fullName,
    Expression<String>? title,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? website,
    Expression<String>? linkedin,
    Expression<String>? github,
    Expression<String>? objective,
    Expression<String>? aiObjective,
    Expression<String>? jdText,
    Expression<String>? education,
    Expression<String>? skills,
    Expression<String>? projects,
    Expression<String>? experience,
    Expression<String>? certifications,
    Expression<String>? achievements,
    Expression<DateTime>? lastModified,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (title != null) 'title': title,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (website != null) 'website': website,
      if (linkedin != null) 'linkedin': linkedin,
      if (github != null) 'github': github,
      if (objective != null) 'objective': objective,
      if (aiObjective != null) 'ai_objective': aiObjective,
      if (jdText != null) 'jd_text': jdText,
      if (education != null) 'education': education,
      if (skills != null) 'skills': skills,
      if (projects != null) 'projects': projects,
      if (experience != null) 'experience': experience,
      if (certifications != null) 'certifications': certifications,
      if (achievements != null) 'achievements': achievements,
      if (lastModified != null) 'last_modified': lastModified,
    });
  }

  ResumesCompanion copyWith(
      {Value<int>? id,
      Value<String>? fullName,
      Value<String?>? title,
      Value<String>? email,
      Value<String>? phone,
      Value<String?>? website,
      Value<String?>? linkedin,
      Value<String?>? github,
      Value<String?>? objective,
      Value<String?>? aiObjective,
      Value<String?>? jdText,
      Value<String>? education,
      Value<String>? skills,
      Value<String>? projects,
      Value<String?>? experience,
      Value<String?>? certifications,
      Value<String?>? achievements,
      Value<DateTime>? lastModified}) {
    return ResumesCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      title: title ?? this.title,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      linkedin: linkedin ?? this.linkedin,
      github: github ?? this.github,
      objective: objective ?? this.objective,
      aiObjective: aiObjective ?? this.aiObjective,
      jdText: jdText ?? this.jdText,
      education: education ?? this.education,
      skills: skills ?? this.skills,
      projects: projects ?? this.projects,
      experience: experience ?? this.experience,
      certifications: certifications ?? this.certifications,
      achievements: achievements ?? this.achievements,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (website.present) {
      map['website'] = Variable<String>(website.value);
    }
    if (linkedin.present) {
      map['linkedin'] = Variable<String>(linkedin.value);
    }
    if (github.present) {
      map['github'] = Variable<String>(github.value);
    }
    if (objective.present) {
      map['objective'] = Variable<String>(objective.value);
    }
    if (aiObjective.present) {
      map['ai_objective'] = Variable<String>(aiObjective.value);
    }
    if (jdText.present) {
      map['jd_text'] = Variable<String>(jdText.value);
    }
    if (education.present) {
      map['education'] = Variable<String>(education.value);
    }
    if (skills.present) {
      map['skills'] = Variable<String>(skills.value);
    }
    if (projects.present) {
      map['projects'] = Variable<String>(projects.value);
    }
    if (experience.present) {
      map['experience'] = Variable<String>(experience.value);
    }
    if (certifications.present) {
      map['certifications'] = Variable<String>(certifications.value);
    }
    if (achievements.present) {
      map['achievements'] = Variable<String>(achievements.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResumesCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('title: $title, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('website: $website, ')
          ..write('linkedin: $linkedin, ')
          ..write('github: $github, ')
          ..write('objective: $objective, ')
          ..write('aiObjective: $aiObjective, ')
          ..write('jdText: $jdText, ')
          ..write('education: $education, ')
          ..write('skills: $skills, ')
          ..write('projects: $projects, ')
          ..write('experience: $experience, ')
          ..write('certifications: $certifications, ')
          ..write('achievements: $achievements, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }
}

class $QueueJobsTable extends QueueJobs
    with TableInfo<$QueueJobsTable, QueueJob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueueJobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _taskTitleMeta =
      const VerificationMeta('taskTitle');
  @override
  late final GeneratedColumn<String> taskTitle = GeneratedColumn<String>(
      'task_title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priorityCodeMeta =
      const VerificationMeta('priorityCode');
  @override
  late final GeneratedColumn<int> priorityCode = GeneratedColumn<int>(
      'priority_code', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusStringMeta =
      const VerificationMeta('statusString');
  @override
  late final GeneratedColumn<String> statusString = GeneratedColumn<String>(
      'status_string', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _progressValueMeta =
      const VerificationMeta('progressValue');
  @override
  late final GeneratedColumn<double> progressValue = GeneratedColumn<double>(
      'progress_value', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _scheduledTimeMeta =
      const VerificationMeta('scheduledTime');
  @override
  late final GeneratedColumn<DateTime> scheduledTime =
      GeneratedColumn<DateTime>('scheduled_time', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _taskTypeMeta =
      const VerificationMeta('taskType');
  @override
  late final GeneratedColumn<String> taskType = GeneratedColumn<String>(
      'task_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
      'result', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        taskTitle,
        priorityCode,
        statusString,
        progressValue,
        scheduledTime,
        taskType,
        payload,
        result
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_jobs';
  @override
  VerificationContext validateIntegrity(Insertable<QueueJob> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_title')) {
      context.handle(_taskTitleMeta,
          taskTitle.isAcceptableOrUnknown(data['task_title']!, _taskTitleMeta));
    } else if (isInserting) {
      context.missing(_taskTitleMeta);
    }
    if (data.containsKey('priority_code')) {
      context.handle(
          _priorityCodeMeta,
          priorityCode.isAcceptableOrUnknown(
              data['priority_code']!, _priorityCodeMeta));
    }
    if (data.containsKey('status_string')) {
      context.handle(
          _statusStringMeta,
          statusString.isAcceptableOrUnknown(
              data['status_string']!, _statusStringMeta));
    }
    if (data.containsKey('progress_value')) {
      context.handle(
          _progressValueMeta,
          progressValue.isAcceptableOrUnknown(
              data['progress_value']!, _progressValueMeta));
    }
    if (data.containsKey('scheduled_time')) {
      context.handle(
          _scheduledTimeMeta,
          scheduledTime.isAcceptableOrUnknown(
              data['scheduled_time']!, _scheduledTimeMeta));
    }
    if (data.containsKey('task_type')) {
      context.handle(_taskTypeMeta,
          taskType.isAcceptableOrUnknown(data['task_type']!, _taskTypeMeta));
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    }
    if (data.containsKey('result')) {
      context.handle(_resultMeta,
          result.isAcceptableOrUnknown(data['result']!, _resultMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QueueJob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueueJob(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      taskTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_title'])!,
      priorityCode: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority_code'])!,
      statusString: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status_string'])!,
      progressValue: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}progress_value'])!,
      scheduledTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}scheduled_time']),
      taskType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}task_type']),
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload']),
      result: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}result']),
    );
  }

  @override
  $QueueJobsTable createAlias(String alias) {
    return $QueueJobsTable(attachedDatabase, alias);
  }
}

class QueueJob extends DataClass implements Insertable<QueueJob> {
  final int id;
  final String taskTitle;
  final int priorityCode;
  final String statusString;
  final double progressValue;
  final DateTime? scheduledTime;
  final String? taskType;
  final String? payload;
  final String? result;
  const QueueJob(
      {required this.id,
      required this.taskTitle,
      required this.priorityCode,
      required this.statusString,
      required this.progressValue,
      this.scheduledTime,
      this.taskType,
      this.payload,
      this.result});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['task_title'] = Variable<String>(taskTitle);
    map['priority_code'] = Variable<int>(priorityCode);
    map['status_string'] = Variable<String>(statusString);
    map['progress_value'] = Variable<double>(progressValue);
    if (!nullToAbsent || scheduledTime != null) {
      map['scheduled_time'] = Variable<DateTime>(scheduledTime);
    }
    if (!nullToAbsent || taskType != null) {
      map['task_type'] = Variable<String>(taskType);
    }
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    if (!nullToAbsent || result != null) {
      map['result'] = Variable<String>(result);
    }
    return map;
  }

  QueueJobsCompanion toCompanion(bool nullToAbsent) {
    return QueueJobsCompanion(
      id: Value(id),
      taskTitle: Value(taskTitle),
      priorityCode: Value(priorityCode),
      statusString: Value(statusString),
      progressValue: Value(progressValue),
      scheduledTime: scheduledTime == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledTime),
      taskType: taskType == null && nullToAbsent
          ? const Value.absent()
          : Value(taskType),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      result:
          result == null && nullToAbsent ? const Value.absent() : Value(result),
    );
  }

  factory QueueJob.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueueJob(
      id: serializer.fromJson<int>(json['id']),
      taskTitle: serializer.fromJson<String>(json['taskTitle']),
      priorityCode: serializer.fromJson<int>(json['priorityCode']),
      statusString: serializer.fromJson<String>(json['statusString']),
      progressValue: serializer.fromJson<double>(json['progressValue']),
      scheduledTime: serializer.fromJson<DateTime?>(json['scheduledTime']),
      taskType: serializer.fromJson<String?>(json['taskType']),
      payload: serializer.fromJson<String?>(json['payload']),
      result: serializer.fromJson<String?>(json['result']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskTitle': serializer.toJson<String>(taskTitle),
      'priorityCode': serializer.toJson<int>(priorityCode),
      'statusString': serializer.toJson<String>(statusString),
      'progressValue': serializer.toJson<double>(progressValue),
      'scheduledTime': serializer.toJson<DateTime?>(scheduledTime),
      'taskType': serializer.toJson<String?>(taskType),
      'payload': serializer.toJson<String?>(payload),
      'result': serializer.toJson<String?>(result),
    };
  }

  QueueJob copyWith(
          {int? id,
          String? taskTitle,
          int? priorityCode,
          String? statusString,
          double? progressValue,
          Value<DateTime?> scheduledTime = const Value.absent(),
          Value<String?> taskType = const Value.absent(),
          Value<String?> payload = const Value.absent(),
          Value<String?> result = const Value.absent()}) =>
      QueueJob(
        id: id ?? this.id,
        taskTitle: taskTitle ?? this.taskTitle,
        priorityCode: priorityCode ?? this.priorityCode,
        statusString: statusString ?? this.statusString,
        progressValue: progressValue ?? this.progressValue,
        scheduledTime:
            scheduledTime.present ? scheduledTime.value : this.scheduledTime,
        taskType: taskType.present ? taskType.value : this.taskType,
        payload: payload.present ? payload.value : this.payload,
        result: result.present ? result.value : this.result,
      );
  QueueJob copyWithCompanion(QueueJobsCompanion data) {
    return QueueJob(
      id: data.id.present ? data.id.value : this.id,
      taskTitle: data.taskTitle.present ? data.taskTitle.value : this.taskTitle,
      priorityCode: data.priorityCode.present
          ? data.priorityCode.value
          : this.priorityCode,
      statusString: data.statusString.present
          ? data.statusString.value
          : this.statusString,
      progressValue: data.progressValue.present
          ? data.progressValue.value
          : this.progressValue,
      scheduledTime: data.scheduledTime.present
          ? data.scheduledTime.value
          : this.scheduledTime,
      taskType: data.taskType.present ? data.taskType.value : this.taskType,
      payload: data.payload.present ? data.payload.value : this.payload,
      result: data.result.present ? data.result.value : this.result,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueueJob(')
          ..write('id: $id, ')
          ..write('taskTitle: $taskTitle, ')
          ..write('priorityCode: $priorityCode, ')
          ..write('statusString: $statusString, ')
          ..write('progressValue: $progressValue, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('taskType: $taskType, ')
          ..write('payload: $payload, ')
          ..write('result: $result')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, taskTitle, priorityCode, statusString,
      progressValue, scheduledTime, taskType, payload, result);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueJob &&
          other.id == this.id &&
          other.taskTitle == this.taskTitle &&
          other.priorityCode == this.priorityCode &&
          other.statusString == this.statusString &&
          other.progressValue == this.progressValue &&
          other.scheduledTime == this.scheduledTime &&
          other.taskType == this.taskType &&
          other.payload == this.payload &&
          other.result == this.result);
}

class QueueJobsCompanion extends UpdateCompanion<QueueJob> {
  final Value<int> id;
  final Value<String> taskTitle;
  final Value<int> priorityCode;
  final Value<String> statusString;
  final Value<double> progressValue;
  final Value<DateTime?> scheduledTime;
  final Value<String?> taskType;
  final Value<String?> payload;
  final Value<String?> result;
  const QueueJobsCompanion({
    this.id = const Value.absent(),
    this.taskTitle = const Value.absent(),
    this.priorityCode = const Value.absent(),
    this.statusString = const Value.absent(),
    this.progressValue = const Value.absent(),
    this.scheduledTime = const Value.absent(),
    this.taskType = const Value.absent(),
    this.payload = const Value.absent(),
    this.result = const Value.absent(),
  });
  QueueJobsCompanion.insert({
    this.id = const Value.absent(),
    required String taskTitle,
    this.priorityCode = const Value.absent(),
    this.statusString = const Value.absent(),
    this.progressValue = const Value.absent(),
    this.scheduledTime = const Value.absent(),
    this.taskType = const Value.absent(),
    this.payload = const Value.absent(),
    this.result = const Value.absent(),
  }) : taskTitle = Value(taskTitle);
  static Insertable<QueueJob> custom({
    Expression<int>? id,
    Expression<String>? taskTitle,
    Expression<int>? priorityCode,
    Expression<String>? statusString,
    Expression<double>? progressValue,
    Expression<DateTime>? scheduledTime,
    Expression<String>? taskType,
    Expression<String>? payload,
    Expression<String>? result,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskTitle != null) 'task_title': taskTitle,
      if (priorityCode != null) 'priority_code': priorityCode,
      if (statusString != null) 'status_string': statusString,
      if (progressValue != null) 'progress_value': progressValue,
      if (scheduledTime != null) 'scheduled_time': scheduledTime,
      if (taskType != null) 'task_type': taskType,
      if (payload != null) 'payload': payload,
      if (result != null) 'result': result,
    });
  }

  QueueJobsCompanion copyWith(
      {Value<int>? id,
      Value<String>? taskTitle,
      Value<int>? priorityCode,
      Value<String>? statusString,
      Value<double>? progressValue,
      Value<DateTime?>? scheduledTime,
      Value<String?>? taskType,
      Value<String?>? payload,
      Value<String?>? result}) {
    return QueueJobsCompanion(
      id: id ?? this.id,
      taskTitle: taskTitle ?? this.taskTitle,
      priorityCode: priorityCode ?? this.priorityCode,
      statusString: statusString ?? this.statusString,
      progressValue: progressValue ?? this.progressValue,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      taskType: taskType ?? this.taskType,
      payload: payload ?? this.payload,
      result: result ?? this.result,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taskTitle.present) {
      map['task_title'] = Variable<String>(taskTitle.value);
    }
    if (priorityCode.present) {
      map['priority_code'] = Variable<int>(priorityCode.value);
    }
    if (statusString.present) {
      map['status_string'] = Variable<String>(statusString.value);
    }
    if (progressValue.present) {
      map['progress_value'] = Variable<double>(progressValue.value);
    }
    if (scheduledTime.present) {
      map['scheduled_time'] = Variable<DateTime>(scheduledTime.value);
    }
    if (taskType.present) {
      map['task_type'] = Variable<String>(taskType.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueueJobsCompanion(')
          ..write('id: $id, ')
          ..write('taskTitle: $taskTitle, ')
          ..write('priorityCode: $priorityCode, ')
          ..write('statusString: $statusString, ')
          ..write('progressValue: $progressValue, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('taskType: $taskType, ')
          ..write('payload: $payload, ')
          ..write('result: $result')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChatsTable chats = $ChatsTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $ResumesTable resumes = $ResumesTable(this);
  late final $QueueJobsTable queueJobs = $QueueJobsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [chats, chatMessages, resumes, queueJobs];
}

typedef $$ChatsTableCreateCompanionBuilder = ChatsCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<DateTime> createdAt,
  Value<String?> activeModel,
  Value<String?> provider,
});
typedef $$ChatsTableUpdateCompanionBuilder = ChatsCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<DateTime> createdAt,
  Value<String?> activeModel,
  Value<String?> provider,
});

class $$ChatsTableFilterComposer extends Composer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activeModel => $composableBuilder(
      column: $table.activeModel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnFilters(column));
}

class $$ChatsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activeModel => $composableBuilder(
      column: $table.activeModel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnOrderings(column));
}

class $$ChatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatsTable> {
  $$ChatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get activeModel => $composableBuilder(
      column: $table.activeModel, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);
}

class $$ChatsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatsTable,
    Chat,
    $$ChatsTableFilterComposer,
    $$ChatsTableOrderingComposer,
    $$ChatsTableAnnotationComposer,
    $$ChatsTableCreateCompanionBuilder,
    $$ChatsTableUpdateCompanionBuilder,
    (Chat, BaseReferences<_$AppDatabase, $ChatsTable, Chat>),
    Chat,
    PrefetchHooks Function()> {
  $$ChatsTableTableManager(_$AppDatabase db, $ChatsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> activeModel = const Value.absent(),
            Value<String?> provider = const Value.absent(),
          }) =>
              ChatsCompanion(
            id: id,
            title: title,
            createdAt: createdAt,
            activeModel: activeModel,
            provider: provider,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> activeModel = const Value.absent(),
            Value<String?> provider = const Value.absent(),
          }) =>
              ChatsCompanion.insert(
            id: id,
            title: title,
            createdAt: createdAt,
            activeModel: activeModel,
            provider: provider,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChatsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChatsTable,
    Chat,
    $$ChatsTableFilterComposer,
    $$ChatsTableOrderingComposer,
    $$ChatsTableAnnotationComposer,
    $$ChatsTableCreateCompanionBuilder,
    $$ChatsTableUpdateCompanionBuilder,
    (Chat, BaseReferences<_$AppDatabase, $ChatsTable, Chat>),
    Chat,
    PrefetchHooks Function()>;
typedef $$ChatMessagesTableCreateCompanionBuilder = ChatMessagesCompanion
    Function({
  Value<int> id,
  required int chatId,
  required String content,
  Value<bool> isUser,
  Value<DateTime> createdAt,
  Value<int> promptTokens,
  Value<int> completionTokens,
});
typedef $$ChatMessagesTableUpdateCompanionBuilder = ChatMessagesCompanion
    Function({
  Value<int> id,
  Value<int> chatId,
  Value<String> content,
  Value<bool> isUser,
  Value<DateTime> createdAt,
  Value<int> promptTokens,
  Value<int> completionTokens,
});

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get chatId => $composableBuilder(
      column: $table.chatId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isUser => $composableBuilder(
      column: $table.isUser, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get promptTokens => $composableBuilder(
      column: $table.promptTokens, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completionTokens => $composableBuilder(
      column: $table.completionTokens,
      builder: (column) => ColumnFilters(column));
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get chatId => $composableBuilder(
      column: $table.chatId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isUser => $composableBuilder(
      column: $table.isUser, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get promptTokens => $composableBuilder(
      column: $table.promptTokens,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completionTokens => $composableBuilder(
      column: $table.completionTokens,
      builder: (column) => ColumnOrderings(column));
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<bool> get isUser =>
      $composableBuilder(column: $table.isUser, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get promptTokens => $composableBuilder(
      column: $table.promptTokens, builder: (column) => column);

  GeneratedColumn<int> get completionTokens => $composableBuilder(
      column: $table.completionTokens, builder: (column) => column);
}

class $$ChatMessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatMessagesTable,
    ChatMessageEntry,
    $$ChatMessagesTableFilterComposer,
    $$ChatMessagesTableOrderingComposer,
    $$ChatMessagesTableAnnotationComposer,
    $$ChatMessagesTableCreateCompanionBuilder,
    $$ChatMessagesTableUpdateCompanionBuilder,
    (
      ChatMessageEntry,
      BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessageEntry>
    ),
    ChatMessageEntry,
    PrefetchHooks Function()> {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> chatId = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<bool> isUser = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> promptTokens = const Value.absent(),
            Value<int> completionTokens = const Value.absent(),
          }) =>
              ChatMessagesCompanion(
            id: id,
            chatId: chatId,
            content: content,
            isUser: isUser,
            createdAt: createdAt,
            promptTokens: promptTokens,
            completionTokens: completionTokens,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int chatId,
            required String content,
            Value<bool> isUser = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> promptTokens = const Value.absent(),
            Value<int> completionTokens = const Value.absent(),
          }) =>
              ChatMessagesCompanion.insert(
            id: id,
            chatId: chatId,
            content: content,
            isUser: isUser,
            createdAt: createdAt,
            promptTokens: promptTokens,
            completionTokens: completionTokens,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChatMessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChatMessagesTable,
    ChatMessageEntry,
    $$ChatMessagesTableFilterComposer,
    $$ChatMessagesTableOrderingComposer,
    $$ChatMessagesTableAnnotationComposer,
    $$ChatMessagesTableCreateCompanionBuilder,
    $$ChatMessagesTableUpdateCompanionBuilder,
    (
      ChatMessageEntry,
      BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessageEntry>
    ),
    ChatMessageEntry,
    PrefetchHooks Function()>;
typedef $$ResumesTableCreateCompanionBuilder = ResumesCompanion Function({
  Value<int> id,
  required String fullName,
  Value<String?> title,
  required String email,
  required String phone,
  Value<String?> website,
  Value<String?> linkedin,
  Value<String?> github,
  Value<String?> objective,
  Value<String?> aiObjective,
  Value<String?> jdText,
  required String education,
  required String skills,
  required String projects,
  Value<String?> experience,
  Value<String?> certifications,
  Value<String?> achievements,
  Value<DateTime> lastModified,
});
typedef $$ResumesTableUpdateCompanionBuilder = ResumesCompanion Function({
  Value<int> id,
  Value<String> fullName,
  Value<String?> title,
  Value<String> email,
  Value<String> phone,
  Value<String?> website,
  Value<String?> linkedin,
  Value<String?> github,
  Value<String?> objective,
  Value<String?> aiObjective,
  Value<String?> jdText,
  Value<String> education,
  Value<String> skills,
  Value<String> projects,
  Value<String?> experience,
  Value<String?> certifications,
  Value<String?> achievements,
  Value<DateTime> lastModified,
});

class $$ResumesTableFilterComposer
    extends Composer<_$AppDatabase, $ResumesTable> {
  $$ResumesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get website => $composableBuilder(
      column: $table.website, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get linkedin => $composableBuilder(
      column: $table.linkedin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get github => $composableBuilder(
      column: $table.github, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get objective => $composableBuilder(
      column: $table.objective, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aiObjective => $composableBuilder(
      column: $table.aiObjective, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get jdText => $composableBuilder(
      column: $table.jdText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get education => $composableBuilder(
      column: $table.education, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get skills => $composableBuilder(
      column: $table.skills, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get projects => $composableBuilder(
      column: $table.projects, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get experience => $composableBuilder(
      column: $table.experience, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get certifications => $composableBuilder(
      column: $table.certifications,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get achievements => $composableBuilder(
      column: $table.achievements, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => ColumnFilters(column));
}

class $$ResumesTableOrderingComposer
    extends Composer<_$AppDatabase, $ResumesTable> {
  $$ResumesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get website => $composableBuilder(
      column: $table.website, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linkedin => $composableBuilder(
      column: $table.linkedin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get github => $composableBuilder(
      column: $table.github, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get objective => $composableBuilder(
      column: $table.objective, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aiObjective => $composableBuilder(
      column: $table.aiObjective, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get jdText => $composableBuilder(
      column: $table.jdText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get education => $composableBuilder(
      column: $table.education, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get skills => $composableBuilder(
      column: $table.skills, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get projects => $composableBuilder(
      column: $table.projects, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get experience => $composableBuilder(
      column: $table.experience, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get certifications => $composableBuilder(
      column: $table.certifications,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get achievements => $composableBuilder(
      column: $table.achievements,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified,
      builder: (column) => ColumnOrderings(column));
}

class $$ResumesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResumesTable> {
  $$ResumesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get website =>
      $composableBuilder(column: $table.website, builder: (column) => column);

  GeneratedColumn<String> get linkedin =>
      $composableBuilder(column: $table.linkedin, builder: (column) => column);

  GeneratedColumn<String> get github =>
      $composableBuilder(column: $table.github, builder: (column) => column);

  GeneratedColumn<String> get objective =>
      $composableBuilder(column: $table.objective, builder: (column) => column);

  GeneratedColumn<String> get aiObjective => $composableBuilder(
      column: $table.aiObjective, builder: (column) => column);

  GeneratedColumn<String> get jdText =>
      $composableBuilder(column: $table.jdText, builder: (column) => column);

  GeneratedColumn<String> get education =>
      $composableBuilder(column: $table.education, builder: (column) => column);

  GeneratedColumn<String> get skills =>
      $composableBuilder(column: $table.skills, builder: (column) => column);

  GeneratedColumn<String> get projects =>
      $composableBuilder(column: $table.projects, builder: (column) => column);

  GeneratedColumn<String> get experience => $composableBuilder(
      column: $table.experience, builder: (column) => column);

  GeneratedColumn<String> get certifications => $composableBuilder(
      column: $table.certifications, builder: (column) => column);

  GeneratedColumn<String> get achievements => $composableBuilder(
      column: $table.achievements, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => column);
}

class $$ResumesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ResumesTable,
    ResumeEntry,
    $$ResumesTableFilterComposer,
    $$ResumesTableOrderingComposer,
    $$ResumesTableAnnotationComposer,
    $$ResumesTableCreateCompanionBuilder,
    $$ResumesTableUpdateCompanionBuilder,
    (ResumeEntry, BaseReferences<_$AppDatabase, $ResumesTable, ResumeEntry>),
    ResumeEntry,
    PrefetchHooks Function()> {
  $$ResumesTableTableManager(_$AppDatabase db, $ResumesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResumesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResumesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResumesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> fullName = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String?> website = const Value.absent(),
            Value<String?> linkedin = const Value.absent(),
            Value<String?> github = const Value.absent(),
            Value<String?> objective = const Value.absent(),
            Value<String?> aiObjective = const Value.absent(),
            Value<String?> jdText = const Value.absent(),
            Value<String> education = const Value.absent(),
            Value<String> skills = const Value.absent(),
            Value<String> projects = const Value.absent(),
            Value<String?> experience = const Value.absent(),
            Value<String?> certifications = const Value.absent(),
            Value<String?> achievements = const Value.absent(),
            Value<DateTime> lastModified = const Value.absent(),
          }) =>
              ResumesCompanion(
            id: id,
            fullName: fullName,
            title: title,
            email: email,
            phone: phone,
            website: website,
            linkedin: linkedin,
            github: github,
            objective: objective,
            aiObjective: aiObjective,
            jdText: jdText,
            education: education,
            skills: skills,
            projects: projects,
            experience: experience,
            certifications: certifications,
            achievements: achievements,
            lastModified: lastModified,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String fullName,
            Value<String?> title = const Value.absent(),
            required String email,
            required String phone,
            Value<String?> website = const Value.absent(),
            Value<String?> linkedin = const Value.absent(),
            Value<String?> github = const Value.absent(),
            Value<String?> objective = const Value.absent(),
            Value<String?> aiObjective = const Value.absent(),
            Value<String?> jdText = const Value.absent(),
            required String education,
            required String skills,
            required String projects,
            Value<String?> experience = const Value.absent(),
            Value<String?> certifications = const Value.absent(),
            Value<String?> achievements = const Value.absent(),
            Value<DateTime> lastModified = const Value.absent(),
          }) =>
              ResumesCompanion.insert(
            id: id,
            fullName: fullName,
            title: title,
            email: email,
            phone: phone,
            website: website,
            linkedin: linkedin,
            github: github,
            objective: objective,
            aiObjective: aiObjective,
            jdText: jdText,
            education: education,
            skills: skills,
            projects: projects,
            experience: experience,
            certifications: certifications,
            achievements: achievements,
            lastModified: lastModified,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ResumesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ResumesTable,
    ResumeEntry,
    $$ResumesTableFilterComposer,
    $$ResumesTableOrderingComposer,
    $$ResumesTableAnnotationComposer,
    $$ResumesTableCreateCompanionBuilder,
    $$ResumesTableUpdateCompanionBuilder,
    (ResumeEntry, BaseReferences<_$AppDatabase, $ResumesTable, ResumeEntry>),
    ResumeEntry,
    PrefetchHooks Function()>;
typedef $$QueueJobsTableCreateCompanionBuilder = QueueJobsCompanion Function({
  Value<int> id,
  required String taskTitle,
  Value<int> priorityCode,
  Value<String> statusString,
  Value<double> progressValue,
  Value<DateTime?> scheduledTime,
  Value<String?> taskType,
  Value<String?> payload,
  Value<String?> result,
});
typedef $$QueueJobsTableUpdateCompanionBuilder = QueueJobsCompanion Function({
  Value<int> id,
  Value<String> taskTitle,
  Value<int> priorityCode,
  Value<String> statusString,
  Value<double> progressValue,
  Value<DateTime?> scheduledTime,
  Value<String?> taskType,
  Value<String?> payload,
  Value<String?> result,
});

class $$QueueJobsTableFilterComposer
    extends Composer<_$AppDatabase, $QueueJobsTable> {
  $$QueueJobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taskTitle => $composableBuilder(
      column: $table.taskTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priorityCode => $composableBuilder(
      column: $table.priorityCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statusString => $composableBuilder(
      column: $table.statusString, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get progressValue => $composableBuilder(
      column: $table.progressValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledTime => $composableBuilder(
      column: $table.scheduledTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taskType => $composableBuilder(
      column: $table.taskType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get result => $composableBuilder(
      column: $table.result, builder: (column) => ColumnFilters(column));
}

class $$QueueJobsTableOrderingComposer
    extends Composer<_$AppDatabase, $QueueJobsTable> {
  $$QueueJobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taskTitle => $composableBuilder(
      column: $table.taskTitle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priorityCode => $composableBuilder(
      column: $table.priorityCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statusString => $composableBuilder(
      column: $table.statusString,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get progressValue => $composableBuilder(
      column: $table.progressValue,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledTime => $composableBuilder(
      column: $table.scheduledTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taskType => $composableBuilder(
      column: $table.taskType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get result => $composableBuilder(
      column: $table.result, builder: (column) => ColumnOrderings(column));
}

class $$QueueJobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueueJobsTable> {
  $$QueueJobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskTitle =>
      $composableBuilder(column: $table.taskTitle, builder: (column) => column);

  GeneratedColumn<int> get priorityCode => $composableBuilder(
      column: $table.priorityCode, builder: (column) => column);

  GeneratedColumn<String> get statusString => $composableBuilder(
      column: $table.statusString, builder: (column) => column);

  GeneratedColumn<double> get progressValue => $composableBuilder(
      column: $table.progressValue, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledTime => $composableBuilder(
      column: $table.scheduledTime, builder: (column) => column);

  GeneratedColumn<String> get taskType =>
      $composableBuilder(column: $table.taskType, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);
}

class $$QueueJobsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QueueJobsTable,
    QueueJob,
    $$QueueJobsTableFilterComposer,
    $$QueueJobsTableOrderingComposer,
    $$QueueJobsTableAnnotationComposer,
    $$QueueJobsTableCreateCompanionBuilder,
    $$QueueJobsTableUpdateCompanionBuilder,
    (QueueJob, BaseReferences<_$AppDatabase, $QueueJobsTable, QueueJob>),
    QueueJob,
    PrefetchHooks Function()> {
  $$QueueJobsTableTableManager(_$AppDatabase db, $QueueJobsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueueJobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueueJobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueueJobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> taskTitle = const Value.absent(),
            Value<int> priorityCode = const Value.absent(),
            Value<String> statusString = const Value.absent(),
            Value<double> progressValue = const Value.absent(),
            Value<DateTime?> scheduledTime = const Value.absent(),
            Value<String?> taskType = const Value.absent(),
            Value<String?> payload = const Value.absent(),
            Value<String?> result = const Value.absent(),
          }) =>
              QueueJobsCompanion(
            id: id,
            taskTitle: taskTitle,
            priorityCode: priorityCode,
            statusString: statusString,
            progressValue: progressValue,
            scheduledTime: scheduledTime,
            taskType: taskType,
            payload: payload,
            result: result,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String taskTitle,
            Value<int> priorityCode = const Value.absent(),
            Value<String> statusString = const Value.absent(),
            Value<double> progressValue = const Value.absent(),
            Value<DateTime?> scheduledTime = const Value.absent(),
            Value<String?> taskType = const Value.absent(),
            Value<String?> payload = const Value.absent(),
            Value<String?> result = const Value.absent(),
          }) =>
              QueueJobsCompanion.insert(
            id: id,
            taskTitle: taskTitle,
            priorityCode: priorityCode,
            statusString: statusString,
            progressValue: progressValue,
            scheduledTime: scheduledTime,
            taskType: taskType,
            payload: payload,
            result: result,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$QueueJobsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QueueJobsTable,
    QueueJob,
    $$QueueJobsTableFilterComposer,
    $$QueueJobsTableOrderingComposer,
    $$QueueJobsTableAnnotationComposer,
    $$QueueJobsTableCreateCompanionBuilder,
    $$QueueJobsTableUpdateCompanionBuilder,
    (QueueJob, BaseReferences<_$AppDatabase, $QueueJobsTable, QueueJob>),
    QueueJob,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChatsTableTableManager get chats =>
      $$ChatsTableTableManager(_db, _db.chats);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$ResumesTableTableManager get resumes =>
      $$ResumesTableTableManager(_db, _db.resumes);
  $$QueueJobsTableTableManager get queueJobs =>
      $$QueueJobsTableTableManager(_db, _db.queueJobs);
}
