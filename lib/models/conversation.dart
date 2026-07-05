import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Estado de entrega de uma mensagem (estilo WhatsApp: ✓ / ✓✓ / ✓✓ azul).
enum MessageStatus { sent, delivered, seen }

/// Tipo de conteúdo de uma mensagem do chat.
enum MessageType { text, image, file, audio }

/// Anexo de uma mensagem (imagem, arquivo ou áudio), guardado localmente
/// no aparelho — o Firestore só guarda a referência ao caminho local.
@immutable
class MessageAttachment {
  const MessageAttachment({
    required this.localPath,
    required this.mimeType,
    required this.sizeBytes,
    required this.fileName,
    this.durationMs,
  });

  final String localPath;
  final String mimeType;
  final int sizeBytes;
  final String fileName;
  final int? durationMs;

  Map<String, Object?> toMap() => <String, Object?>{
        'localPath': localPath,
        'mimeType': mimeType,
        'sizeBytes': sizeBytes,
        'fileName': fileName,
        'durationMs': durationMs,
      };

  factory MessageAttachment.fromMap(Map<String, Object?> map) =>
      MessageAttachment(
        localPath: map['localPath'] as String,
        mimeType: map['mimeType'] as String,
        sizeBytes: map['sizeBytes'] as int,
        fileName: map['fileName'] as String,
        durationMs: map['durationMs'] as int?,
      );
}

/// Uma mensagem individual dentro de uma conversa.
@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.sentByUser,
    required this.sentAt,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    this.attachment,
  });

  final String id;
  final String text;
  final bool sentByUser;
  final DateTime sentAt;
  final MessageType type;
  final MessageStatus status;
  final MessageAttachment? attachment;

  ChatMessage copyWith({MessageStatus? status}) => ChatMessage(
        id: id,
        text: text,
        sentByUser: sentByUser,
        sentAt: sentAt,
        type: type,
        status: status ?? this.status,
        attachment: attachment,
      );

  /// Payload gravado no Firestore ao criar a mensagem.
  Map<String, Object?> toFirestore() => <String, Object?>{
        'senderType': sentByUser ? 'patient' : 'clinic',
        'type': type.name,
        'text': text,
        'attachment': attachment?.toMap(),
        'status': status.name,
        'createdAt': FieldValue.serverTimestamp(),
        'statusUpdatedAt': FieldValue.serverTimestamp(),
      };

  factory ChatMessage.fromFirestore(
    QueryDocumentSnapshot<Map<String, Object?>> doc,
  ) {
    final Map<String, Object?> data = doc.data();
    final Object? rawAttachment = data['attachment'];
    return ChatMessage(
      id: doc.id,
      text: data['text'] as String? ?? '',
      sentByUser: data['senderType'] == 'patient',
      sentAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: MessageType.values.byName(data['type'] as String? ?? 'text'),
      status:
          MessageStatus.values.byName(data['status'] as String? ?? 'sent'),
      attachment: rawAttachment is Map
          ? MessageAttachment.fromMap(Map<String, Object?>.from(rawAttachment))
          : null,
    );
  }
}

/// Uma conversa entre a paciente e uma clínica
/// (tela "Minhas Conversas" do protótipo original).
@immutable
class Conversation {
  const Conversation({
    required this.id,
    required this.clinicName,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.messages,
  });

  final String id;
  final String clinicName;
  final DateTime lastMessageAt;
  final int unreadCount;
  final List<ChatMessage> messages;

  bool get hasUnread => unreadCount > 0;

  String get lastMessagePreview =>
      messages.isEmpty ? '' : messages.last.text;

  bool matches(String query) {
    final String term = query.trim().toLowerCase();
    if (term.isEmpty) return true;
    return clinicName.toLowerCase().contains(term);
  }

  Conversation copyWith({
    DateTime? lastMessageAt,
    int? unreadCount,
    List<ChatMessage>? messages,
  }) =>
      Conversation(
        id: id,
        clinicName: clinicName,
        lastMessageAt: lastMessageAt ?? this.lastMessageAt,
        unreadCount: unreadCount ?? this.unreadCount,
        messages: messages ?? this.messages,
      );
}
