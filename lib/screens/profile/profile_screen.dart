import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/app_scope.dart';
import '../../controllers/conversations_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock_data.dart';

/// Tela Perfil (perfil.html): cabeçalho com avatar, nome e e-mail, e
/// menu de opções (Histórico, Medicamentos, Documentos, Notificações,
/// Privacidade e Sair). "Notificações" leva às mensagens não lidas,
/// como no protótipo original.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _avatarBytes;

  Future<void> _pickAvatar(ImageSource source) async {
    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked == null) return;
      final Uint8List bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() => _avatarBytes = bytes);
    } catch (_) {
      if (!mounted) return;
      _comingSoon(context, 'Seleção de foto');
    }
  }

  Future<void> _showAvatarOptions(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Alterar foto do perfil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined,
                  color: AppColors.primary),
              title: const Text('Tirar foto'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pickAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: const Text('Escolher da galeria'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pickAvatar(ImageSource.gallery);
              },
            ),
            if (_avatarBytes != null)
              ListTile(
                leading: const Icon(Icons.delete_outline,
                    color: AppColors.statusCanceled),
                title: const Text(
                  'Remover foto',
                  style: TextStyle(color: AppColors.statusCanceled),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  setState(() => _avatarBytes = null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _editName(BuildContext context, AppScope scope) async {
    final TextEditingController controller =
        TextEditingController(text: scope.profile.name);
    final String? newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Editar nome'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Seu nome'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (newName != null && newName.trim().isNotEmpty) {
      await scope.profile.updateName(newName);
    }
  }

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$feature: em desenvolvimento.')),
      );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text('Você precisará entrar novamente para acessar '
            'suas consultas e mensagens.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.statusCanceled,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      _comingSoon(context, 'Autenticação');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppScope scope = AppScope.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      children: [
        // ===== Cabeçalho do perfil =====
        Column(
          children: [
            GestureDetector(
              onTap: () => _showAvatarOptions(context),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFEEEEEE),
                      border: Border.fromBorderSide(
                        BorderSide(color: Colors.white, width: 3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    // Escala levemente a imagem para garantir que ela
                    // cubra o círculo por completo, sem deixar a cor de
                    // fundo aparecer nas bordas (o PNG de origem não é
                    // perfeitamente quadrado).
                    child: Transform.scale(
                      scale: 1.12,
                      child: _avatarBytes != null
                          ? Image.memory(
                              _avatarBytes!,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              'assets/icons/icone.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Text(
                                  'MS',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.photo_camera,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ListenableBuilder(
              listenable: scope.profile,
              builder: (context, _) => GestureDetector(
                onTap: () => _editName(context, scope),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      scope.profile.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppColors.textGray,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              MockData.userEmail,
              style: TextStyle(fontSize: 14, color: AppColors.textGray),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // ===== Menu =====
        Card(
          child: Column(
            children: [
              _MenuItem(
                imageAsset: 'assets/icons/icon-historico.png',
                label: 'Histórico médico',
                onTap: () => _comingSoon(context, 'Histórico médico'),
              ),
              const _MenuDivider(),
              _MenuItem(
                imageAsset: 'assets/icons/icon-medicamentos.png',
                label: 'Medicamentos',
                onTap: () => _comingSoon(context, 'Medicamentos'),
              ),
              const _MenuDivider(),
              _MenuItem(
                imageAsset: 'assets/icons/icon-documentos.png',
                label: 'Documentos',
                onTap: () => _comingSoon(context, 'Documentos'),
              ),
              const _MenuDivider(),
              ListenableBuilder(
                listenable: scope.conversations,
                builder: (context, _) => _MenuItem(
                  imageAsset: 'assets/icons/icon-notificacoes.png',
                  label: 'Notificações',
                  badgeCount: scope.conversations.totalUnread,
                  onTap: () {
                    // Como no original: abre Mensagens filtrando não lidas.
                    scope.conversations.setFilter(ConversationFilter.unread);
                    scope.goToTab(2);
                  },
                ),
              ),
              const _MenuDivider(),
              _MenuItem(
                imageAsset: 'assets/icons/icon-privacidade.png',
                label: 'Privacidade',
                onTap: () => _comingSoon(context, 'Privacidade'),
              ),
              const _MenuDivider(),
              _MenuItem(
                imageAsset: 'assets/icons/icon-sair.png',
                label: 'Sair',
                destructive: true,
                onTap: () => _confirmLogout(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.imageAsset,
    required this.label,
    required this.onTap,
    this.destructive = false,
    this.badgeCount,
  });

  /// Ícone PNG do protótipo original (24px, como o `.menu-icon` do CSS).
  final String imageAsset;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  /// Contador de não lidas mostrado como badge sobre o ícone (item
  /// "Notificações"). `null` ou 0 não mostra nada.
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final Color color =
        destructive ? AppColors.statusCanceled : AppColors.textDark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Badge.count(
              count: badgeCount ?? 0,
              isLabelVisible: (badgeCount ?? 0) > 0,
              child: Image.asset(
                imageAsset,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.circle_outlined,
                  size: 24,
                  color: destructive
                      ? AppColors.statusCanceled
                      : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 22,
              color: AppColors.textGray,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 54),
      child: Divider(),
    );
  }
}
