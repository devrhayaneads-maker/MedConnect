import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Guarda anexos (imagens/áudio) no armazenamento local do aparelho —
/// sem Firebase Storage (ver decisão de projeto em torno do plano
/// gratuito do Firebase). O Firestore só guarda a referência ao
/// caminho local (`MessageAttachment.localPath`).
abstract final class AttachmentStorage {
  static Future<String> saveBytes(List<int> bytes, String extension) async {
    final String path = await allocatePath(extension);
    await File(path).writeAsBytes(bytes);
    return path;
  }

  /// Reserva um caminho local novo (usado pelo gravador de áudio, que
  /// escreve diretamente nesse caminho em vez de receber bytes prontos).
  static Future<String> allocatePath(String extension) async {
    final Directory documentsDir = await getApplicationDocumentsDirectory();
    final Directory attachmentsDir =
        Directory('${documentsDir.path}/attachments');
    if (!attachmentsDir.existsSync()) {
      attachmentsDir.createSync(recursive: true);
    }
    final String fileName =
        '${DateTime.now().microsecondsSinceEpoch}.$extension';
    return '${attachmentsDir.path}/$fileName';
  }
}
