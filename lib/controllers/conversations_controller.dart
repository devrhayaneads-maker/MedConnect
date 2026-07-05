import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/conversation.dart';
import '../repositories/conversations_repository.dart';
import '../services/notification_service.dart';

/// Respostas automáticas simuladas da clínica (sem servidor/Cloud Functions
/// — ver decisão de projeto em torno do plano gratuito do Firebase).
const List<String> _autoReplyTexts = <String>[
  'Recebemos sua mensagem! Em breve um atendente responde por aqui.',
  'Obrigado por entrar em contato. Como podemos ajudar?',
  'Sua mensagem foi registrada. Nossa equipe já te retorna.',
  'Olá! Já estamos verificando sua solicitação.',
  'Certo, já anotei aqui. Só um instante, por favor.',
  'Entendido! Vou repassar para o setor responsável.',
  'Agradecemos o contato. Retornamos em breve com mais detalhes.',
  'Perfeito, deixa comigo que já te ajudo com isso.',
  'Sua solicitação está em análise. Aguarde só mais um pouco.',
  'Oi! Recebemos por aqui, já já um atendente te responde.',
];

/// Filtro da tela "Minhas Conversas" (Todas / Não lidas).
enum ConversationFilter {
  all('Todas'),
  unread('Não lidas');

  const ConversationFilter(this.label);

  final String label;
}

/// Estado reativo das conversas: assina o Firestore em tempo real
/// (metadados da conversa + mensagens de cada uma) e expõe filtro,
/// busca, leitura e envio — mesma API pública de antes da migração.
class ConversationsController extends ChangeNotifier {
  ConversationsController(this._repository) {
    _repository.seedDemoDataIfEmpty().then((_) => _listen());
  }

  final ConversationsRepository _repository;
  final Map<String, Conversation> _conversationsById = <String, Conversation>{};
  final Map<String, String> _lastAutoReplyByConversation = <String, String>{};
  final Map<String, StreamSubscription<QuerySnapshot<Map<String, Object?>>>>
      _messageSubs = <String, StreamSubscription<QuerySnapshot<Map<String, Object?>>>>{};
  StreamSubscription<QuerySnapshot<Map<String, Object?>>>? _conversationsSub;

  ConversationFilter _filter = ConversationFilter.all;
  String _query = '';

  ConversationFilter get filter => _filter;
  String get query => _query;

  int get totalUnread => _conversationsById.values
      .fold(0, (total, c) => total + c.unreadCount);

  List<Conversation> get filtered {
    final List<Conversation> list = _conversationsById.values
        .where(
          (c) =>
              (_filter == ConversationFilter.all || c.hasUnread) &&
              c.matches(_query),
        )
        .toList()
      ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    return list;
  }

  Conversation? byId(String id) => _conversationsById[id];

  void setFilter(ConversationFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  void setQuery(String query) {
    if (_query == query) return;
    _query = query;
    notifyListeners();
  }

  void _listen() {
    _conversationsSub = _repository.watchConversationDocs().listen((snapshot) {
      final Set<String> currentIds =
          snapshot.docs.map((doc) => doc.id).toSet();

      // Conversas removidas: cancela a assinatura de mensagens correspondente.
      for (final String id in _messageSubs.keys.toList()) {
        if (!currentIds.contains(id)) {
          _messageSubs.remove(id)?.cancel();
          _conversationsById.remove(id);
        }
      }

      for (final QueryDocumentSnapshot<Map<String, Object?>> doc
          in snapshot.docs) {
        final Map<String, Object?> data = doc.data();
        final Conversation? existing = _conversationsById[doc.id];
        _conversationsById[doc.id] = Conversation(
          id: doc.id,
          clinicName: data['clinicName'] as String? ?? '',
          lastMessageAt:
              (data['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          unreadCount: data['unreadCount'] as int? ?? 0,
          messages: existing?.messages ?? const <ChatMessage>[],
        );

        _messageSubs.putIfAbsent(doc.id, () {
          // Evita notificar sobre mensagens antigas no primeiro snapshot
          // (carga inicial da conversa, incluindo o seed de demonstração).
          bool isFirstSnapshot = true;
          return _repository.watchMessages(doc.id).listen((messageSnapshot) {
            final List<ChatMessage> messages = messageSnapshot.docs
                .map(ChatMessage.fromFirestore)
                .toList();
            final Conversation? current = _conversationsById[doc.id];
            if (current == null) return;

            if (!isFirstSnapshot) {
              final Set<String> previousIds =
                  current.messages.map((m) => m.id).toSet();
              for (final ChatMessage message in messages) {
                if (!message.sentByUser && !previousIds.contains(message.id)) {
                  NotificationService.showClinicMessage(
                    conversationId: doc.id,
                    clinicName: current.clinicName,
                    body: message.text,
                  );
                }
              }
            }
            isFirstSnapshot = false;

            _conversationsById[doc.id] = current.copyWith(messages: messages);
            notifyListeners();
          });
        });
      }

      notifyListeners();
    });
  }

  /// Marca a conversa como lida (ao abrir o chat).
  void markAsRead(String id) {
    final Conversation? conversation = _conversationsById[id];
    if (conversation == null || !conversation.hasUnread) return;
    _repository.markConversationRead(id);
  }

  /// Envia uma mensagem de texto da paciente para a conversa e, em
  /// seguida, simula a resposta da clínica (sem servidor): marca a
  /// própria mensagem como entregue/vista e depois "responde".
  void sendMessage(String id, String text) {
    final String trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _repository
        .addMessage(
          id,
          ChatMessage(
            id: '',
            text: trimmed,
            sentByUser: true,
            sentAt: DateTime.now(),
          ),
        )
        .then((messageId) => _simulateClinicReply(id, messageId));
  }

  /// Envia um anexo (imagem ou áudio, guardado localmente no aparelho)
  /// e, em seguida, simula a resposta da clínica como no texto.
  void sendAttachment(
    String conversationId, {
    required MessageType type,
    required MessageAttachment attachment,
  }) {
    _repository
        .addMessage(
          conversationId,
          ChatMessage(
            id: '',
            text: '',
            sentByUser: true,
            sentAt: DateTime.now(),
            type: type,
            attachment: attachment,
          ),
        )
        .then((messageId) => _simulateClinicReply(conversationId, messageId));
  }

  /// Sorteia uma resposta automática, evitando repetir a última usada
  /// na mesma conversa (simulação mais natural).
  String _pickAutoReply(String conversationId) {
    final String? last = _lastAutoReplyByConversation[conversationId];
    final List<String> options = last == null
        ? _autoReplyTexts
        : _autoReplyTexts.where((text) => text != last).toList();
    final String picked = options[Random().nextInt(options.length)];
    _lastAutoReplyByConversation[conversationId] = picked;
    return picked;
  }

  Future<void> _simulateClinicReply(
    String conversationId,
    String patientMessageId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 900));
    await _repository.updateMessageStatus(
      conversationId,
      patientMessageId,
      MessageStatus.delivered,
    );

    await Future.delayed(const Duration(seconds: 2));
    await _repository.updateMessageStatus(
      conversationId,
      patientMessageId,
      MessageStatus.seen,
    );

    await Future.delayed(const Duration(milliseconds: 700));
    final String replyText = _pickAutoReply(conversationId);
    await _repository.addMessage(
      conversationId,
      ChatMessage(
        id: '',
        text: replyText,
        sentByUser: false,
        sentAt: DateTime.now(),
      ),
    );
    await _repository.incrementUnread(conversationId);
  }

  @override
  void dispose() {
    _conversationsSub?.cancel();
    for (final StreamSubscription<QuerySnapshot<Map<String, Object?>>> sub
        in _messageSubs.values) {
      sub.cancel();
    }
    super.dispose();
  }
}
