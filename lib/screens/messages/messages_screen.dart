import 'package:flutter/material.dart';

import '../../controllers/app_scope.dart';
import '../../controllers/conversations_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/conversation.dart';
import '../../widgets/conversation_tile.dart';
import '../../widgets/filter_pill_row.dart';
import 'chat_screen.dart';

/// Tela Minhas Conversas (mensagens.html): filtros Todas / Não lidas,
/// busca por nome da clínica e lista de conversas com contador de
/// não lidas. Tocar em uma conversa abre o chat e a marca como lida.
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppScope scope = AppScope.of(context);
    final ConversationsController controller = scope.conversations;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final List<Conversation> conversations = controller.filtered;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Text(
                'Minhas Conversas',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  FilterPillRow<ConversationFilter>(
                    options: ConversationFilter.values,
                    selected: controller.filter,
                    labelOf: (f) => f.label,
                    onSelected: controller.setFilter,
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: controller.setQuery,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Pesquisar',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        suffixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: Color(0xFF3C3F61),
                        ),
                        filled: true,
                        fillColor: AppColors.chipLavender,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: conversations.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: conversations.length,
                      separatorBuilder: (_, __) => const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(),
                      ),
                      itemBuilder: (context, index) {
                        final Conversation conversation =
                            conversations[index];
                        return ConversationTile(
                          conversation: conversation,
                          onTap: () {
                            controller.markAsRead(conversation.id);
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ChatScreen(
                                  conversationId: conversation.id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: AppColors.textGray,
          ),
          SizedBox(height: 12),
          Text(
            'Nenhuma conversa encontrada',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textGray,
            ),
          ),
        ],
      ),
    );
  }
}
