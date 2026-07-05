import 'dart:io';
import 'dart:typed_data';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';

import '../../controllers/app_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/conversation.dart';
import '../../services/attachment_storage.dart';
import '../../widgets/initials_avatar.dart';

/// Tela de chat com uma clínica: histórico em bolhas e campo de envio.
/// (Evolução natural da tela de mensagens do protótipo original.)
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send(AppScope scope) {
    final String text = _inputController.text;
    if (text.trim().isEmpty) return;
    scope.conversations.sendMessage(widget.conversationId, text);
    _inputController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final AppScope scope = AppScope.of(context);

    return ListenableBuilder(
      listenable: scope.conversations,
      builder: (context, _) {
        final Conversation? conversation =
            scope.conversations.byId(widget.conversationId);
        if (conversation == null) {
          return const Scaffold(
            body: Center(child: Text('Conversa não encontrada.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Row(
              children: [
                InitialsAvatar(
                  name: conversation.clinicName,
                  size: 36,
                  outlined: true,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    conversation.clinicName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: conversation.messages.length,
                    itemBuilder: (context, index) => _MessageBubble(
                      message: conversation.messages[index],
                    ),
                  ),
                ),
                _InputBar(
                  controller: _inputController,
                  onSend: () => _send(scope),
                  conversationId: widget.conversationId,
                  onAttachmentSent: _scrollToBottom,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final bool mine = message.sentByUser;
    final Color textColor = mine ? Colors.white : AppColors.textDark;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        decoration: BoxDecoration(
          color: mine ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(mine ? 16 : 4),
            bottomRight: Radius.circular(mine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.type == MessageType.image && message.attachment != null)
              _ImageBubble(attachment: message.attachment!)
            else if (message.type == MessageType.audio &&
                message.attachment != null)
              _AudioBubble(attachment: message.attachment!, mine: mine)
            else
              Text(
                message.text,
                style: TextStyle(fontSize: 14, height: 1.35, color: textColor),
              ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Formatters.time(message.sentAt),
                  style: TextStyle(
                    fontSize: 10.5,
                    color: mine ? Colors.white70 : AppColors.textGray,
                  ),
                ),
                if (mine) ...[
                  const SizedBox(width: 4),
                  _StatusTicks(status: message.status),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Ticks estilo WhatsApp: ✓ enviado, ✓✓ entregue (cinza), ✓✓ visto (azul).
/// Só aparece nas mensagens enviadas pela própria paciente.
class _StatusTicks extends StatelessWidget {
  const _StatusTicks({required this.status});

  final MessageStatus status;

  @override
  Widget build(BuildContext context) {
    final IconData icon =
        status == MessageStatus.sent ? Icons.done : Icons.done_all;
    final Color color = status == MessageStatus.seen
        ? const Color(0xFF4FC3F7)
        : Colors.white70;
    return Icon(icon, size: 14, color: color);
  }
}

/// Miniatura de uma imagem anexada (guardada localmente no aparelho).
/// Toque abre a imagem em tela cheia.
class _ImageBubble extends StatelessWidget {
  const _ImageBubble({required this.attachment});

  final MessageAttachment attachment;

  @override
  Widget build(BuildContext context) {
    // Escala com a tela (telas muito estreitas não estouram a bolha do
    // chat, que já limita a largura máxima em 75% da tela).
    final double size = (MediaQuery.sizeOf(context).width * 0.55).clamp(120.0, 200.0);

    return GestureDetector(
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.black,
          child: InteractiveViewer(
            child: Image.file(File(attachment.localPath)),
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(attachment.localPath),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: size,
            height: size * 0.6,
            color: Colors.black12,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image_outlined),
          ),
        ),
      ),
    );
  }
}

/// Bolha de áudio: botão de play/pause e duração (guardado localmente
/// no aparelho, sem Firebase Storage).
class _AudioBubble extends StatefulWidget {
  const _AudioBubble({required this.attachment, required this.mine});

  final MessageAttachment attachment;
  final bool mine;

  @override
  State<_AudioBubble> createState() => _AudioBubbleState();
}

class _AudioBubbleState extends State<_AudioBubble> {
  final AudioPlayer _player = AudioPlayer();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _player.setFilePath(widget.attachment.localPath).then((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _format(Duration duration) {
    final String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final Color color = widget.mine ? Colors.white : AppColors.textDark;
    final Duration duration = widget.attachment.durationMs != null
        ? Duration(milliseconds: widget.attachment.durationMs!)
        : Duration.zero;

    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final bool playing = snapshot.data?.playing ?? false;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: !_ready
                  ? null
                  : () => playing ? _player.pause() : _player.play(),
              icon: Icon(
                playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: color,
                size: 30,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.graphic_eq, size: 16, color: color),
            const SizedBox(width: 8),
            Text(_format(duration), style: TextStyle(fontSize: 12, color: color)),
          ],
        );
      },
    );
  }
}

class _InputBar extends StatefulWidget {
  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.conversationId,
    required this.onAttachmentSent,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final String conversationId;
  final VoidCallback onAttachmentSent;

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  DateTime? _recordingStartedAt;
  bool _showEmojiPicker = false;

  void _toggleEmojiPicker() {
    if (!_showEmojiPicker) FocusScope.of(context).unfocus();
    setState(() => _showEmojiPicker = !_showEmojiPicker);
  }

  void _insertEmoji(Emoji emoji) {
    final TextEditingValue value = widget.controller.value;
    final int start =
        value.selection.start < 0 ? value.text.length : value.selection.start;
    final int end =
        value.selection.end < 0 ? value.text.length : value.selection.end;
    final String newText = value.text.replaceRange(start, end, emoji.emoji);
    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + emoji.emoji.length),
    );
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;

    final Uint8List bytes = await picked.readAsBytes();
    final String extension =
        picked.name.contains('.') ? picked.name.split('.').last : 'jpg';
    final String localPath = await AttachmentStorage.saveBytes(bytes, extension);
    if (!mounted) return;

    AppScope.of(context).conversations.sendAttachment(
          widget.conversationId,
          type: MessageType.image,
          attachment: MessageAttachment(
            localPath: localPath,
            mimeType: 'image/$extension',
            sizeBytes: bytes.length,
            fileName: picked.name,
          ),
        );
    widget.onAttachmentSent();
  }

  Future<void> _showAttachmentOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: AppColors.primary),
              title: const Text('Tirar foto'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: const Text('Escolher da galeria'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final String? path = await _recorder.stop();
      final DateTime? startedAt = _recordingStartedAt;
      if (mounted) setState(() => _isRecording = false);
      if (path == null || startedAt == null) return;

      final File file = File(path);
      final int sizeBytes = await file.length();
      final int durationMs =
          DateTime.now().difference(startedAt).inMilliseconds;
      if (!mounted) return;

      AppScope.of(context).conversations.sendAttachment(
            widget.conversationId,
            type: MessageType.audio,
            attachment: MessageAttachment(
              localPath: path,
              mimeType: 'audio/m4a',
              sizeBytes: sizeBytes,
              fileName: path.split(Platform.pathSeparator).last,
              durationMs: durationMs,
            ),
          );
      widget.onAttachmentSent();
      return;
    }

    if (!await _recorder.hasPermission()) return;
    final String path = await AttachmentStorage.allocatePath('m4a');
    await _recorder.start(const RecordConfig(), path: path);
    if (!mounted) return;
    setState(() {
      _isRecording = true;
      _recordingStartedAt = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(8, 10, 12, 12),
          color: AppColors.surface,
          child: Row(
            children: [
              IconButton(
                onPressed: _isRecording ? null : _toggleEmojiPicker,
                icon: Icon(
                  _showEmojiPicker
                      ? Icons.keyboard
                      : Icons.emoji_emotions_outlined,
                  color: AppColors.primary,
                ),
                tooltip: 'Emojis',
              ),
              IconButton(
                onPressed: _isRecording ? null : _showAttachmentOptions,
                icon: const Icon(Icons.attach_file, color: AppColors.primary),
                tooltip: 'Anexar imagem',
              ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  enabled: !_isRecording,
                  textInputAction: TextInputAction.send,
                  onTap: () {
                    if (_showEmojiPicker) setState(() => _showEmojiPicker = false);
                  },
                  onSubmitted: (_) => widget.onSend(),
                  decoration: InputDecoration(
                    hintText: _isRecording
                        ? 'Gravando áudio...'
                        : 'Digite uma mensagem...',
                    isDense: true,
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
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
              const SizedBox(width: 4),
              IconButton(
                onPressed: _toggleRecording,
                icon: Icon(
                  _isRecording ? Icons.stop_circle : Icons.mic_none,
                  color:
                      _isRecording ? AppColors.statusCanceled : AppColors.primary,
                ),
                tooltip: _isRecording ? 'Parar gravação' : 'Gravar áudio',
              ),
              const SizedBox(width: 4),
              IconButton.filled(
                onPressed: widget.onSend,
                style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                tooltip: 'Enviar',
              ),
            ],
          ),
        ),
        if (_showEmojiPicker)
          SizedBox(
            height: 250,
            child: EmojiPicker(
              onEmojiSelected: (category, emoji) => _insertEmoji(emoji),
            ),
          ),
      ],
    );
  }
}
