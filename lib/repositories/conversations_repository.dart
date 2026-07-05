import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/mock_data.dart';
import '../models/conversation.dart';

/// Acesso ao Firestore para as conversas da paciente autenticada
/// (`users/{uid}/conversations/{conversationId}/messages/{messageId}`).
class ConversationsRepository {
  ConversationsRepository(this._uid, {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final String _uid;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, Object?>> get _conversationsRef =>
      _firestore.collection('users').doc(_uid).collection('conversations');

  CollectionReference<Map<String, Object?>> _messagesRef(String conversationId) =>
      _conversationsRef.doc(conversationId).collection('messages');

  /// Metadados das conversas (sem as mensagens) — usado para saber
  /// quais conversas existem e assinar as mensagens de cada uma.
  Stream<QuerySnapshot<Map<String, Object?>>> watchConversationDocs() =>
      _conversationsRef.snapshots();

  Stream<QuerySnapshot<Map<String, Object?>>> watchMessages(
    String conversationId,
  ) =>
      _messagesRef(conversationId).orderBy('createdAt').snapshots();

  /// Se a paciente ainda não tem nenhuma conversa (uid novo), popula
  /// o Firestore com os mesmos dados de demonstração do protótipo
  /// original (`MockData.conversations()`), para a experiência do app
  /// continuar igual, agora persistida de verdade.
  Future<void> seedDemoDataIfEmpty() async {
    final QuerySnapshot<Map<String, Object?>> existing =
        await _conversationsRef.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final WriteBatch batch = _firestore.batch();
    for (final Conversation conversation in MockData.conversations()) {
      final DocumentReference<Map<String, Object?>> conversationDoc =
          _conversationsRef.doc(conversation.id);
      batch.set(conversationDoc, <String, Object?>{
        'clinicName': conversation.clinicName,
        'lastMessageAt': Timestamp.fromDate(conversation.lastMessageAt),
        'unreadCount': conversation.unreadCount,
      });
      for (final ChatMessage message in conversation.messages) {
        final DocumentReference<Map<String, Object?>> messageDoc =
            conversationDoc.collection('messages').doc();
        batch.set(messageDoc, <String, Object?>{
          'senderType': message.sentByUser ? 'patient' : 'clinic',
          'type': message.type.name,
          'text': message.text,
          'attachment': null,
          'status': message.status.name,
          'createdAt': Timestamp.fromDate(message.sentAt),
          'statusUpdatedAt': Timestamp.fromDate(message.sentAt),
        });
      }
    }
    await batch.commit();
  }

  Future<String> addMessage(String conversationId, ChatMessage message) async {
    final DocumentReference<Map<String, Object?>> ref =
        await _messagesRef(conversationId).add(message.toFirestore());
    // `set`+merge em vez de `update`: cria o doc da conversa se ainda não
    // existir (ex.: primeira mensagem de uma conversa nova).
    await _conversationsRef.doc(conversationId).set(
      <String, Object?>{'lastMessageAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
    return ref.id;
  }

  Future<void> updateMessageStatus(
    String conversationId,
    String messageId,
    MessageStatus status,
  ) =>
      _messagesRef(conversationId).doc(messageId).update(<String, Object?>{
        'status': status.name,
        'statusUpdatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> incrementUnread(String conversationId) =>
      _conversationsRef.doc(conversationId).update(<String, Object?>{
        'unreadCount': FieldValue.increment(1),
      });

  Future<void> markConversationRead(String conversationId) =>
      _conversationsRef.doc(conversationId).update(<String, Object?>{
        'unreadCount': 0,
      });
}
