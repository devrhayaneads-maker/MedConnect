// Gera um QR code em SVG (sem depender de nenhuma lib externa fora do
// pacote `qr`, já usado pelo app) apontando para a URL de download do
// APK hospedado no Firebase Hosting. Uso:
//   dart run tool/generate_qr_svg.dart <url> <arquivo_saida.svg>
import 'dart:io';

import 'package:qr/qr.dart';

void main(List<String> args) {
  if (args.length < 2) {
    stderr.writeln('Uso: dart run tool/generate_qr_svg.dart <url> <saida.svg>');
    exit(1);
  }

  final String url = args[0];
  final String outputPath = args[1];

  final QrCode qrCode = QrCode.fromData(
    data: url,
    errorCorrectLevel: QrErrorCorrectLevel.M,
  );
  final QrImage qrImage = QrImage(qrCode);

  const int moduleSize = 8;
  const int quietZone = 4;
  final int size = (qrImage.moduleCount + quietZone * 2) * moduleSize;

  final StringBuffer svg = StringBuffer()
    ..writeln(
      '<svg xmlns="http://www.w3.org/2000/svg" width="$size" height="$size" '
      'viewBox="0 0 $size $size" shape-rendering="crispEdges">',
    )
    ..writeln('<rect width="$size" height="$size" fill="#ffffff"/>');

  for (int row = 0; row < qrImage.moduleCount; row++) {
    for (int col = 0; col < qrImage.moduleCount; col++) {
      if (!qrImage.isDark(row, col)) continue;
      final int x = (col + quietZone) * moduleSize;
      final int y = (row + quietZone) * moduleSize;
      svg.writeln(
        '<rect x="$x" y="$y" width="$moduleSize" height="$moduleSize" fill="#000000"/>',
      );
    }
  }

  svg.writeln('</svg>');

  File(outputPath).writeAsStringSync(svg.toString());
  stdout.writeln('QR code gerado em $outputPath para a URL: $url');
}
