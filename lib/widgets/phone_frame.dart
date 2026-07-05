import 'dart:async';

import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';

/// Moldura de celular para o Flutter Web e para desktop (Windows/macOS/
/// Linux).
///
/// Reproduz a apresentação do protótipo original em HTML: na janela, o
/// app aparece dentro de um "celular" centralizado (borda preta, cantos
/// arredondados, sombra e barra de status com hora real),
/// redimensionando-se para caber inteiro na janela — nunca corta. Isso
/// também evita esticar os PNGs (desenhados para a largura de um
/// celular) além da resolução original quando a janela é muito maior
/// que um telefone.
///
/// Quando o app roda instalado (Android/iOS), a moldura não existe e
/// o app ocupa a tela inteira, como um aplicativo de verdade.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child});

  final Widget child;

  /// Dimensões da tela interna do "celular" (iguais ao protótipo).
  static const double screenWidth = 390;
  static const double screenHeight = 844;
  static const double _bezel = 12;
  static const double _statusBarHeight = 34;

  static bool get _isNativeMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Widget build(BuildContext context) {
    // Em app instalado (Android/iOS), sem moldura: tela cheia de verdade.
    if (_isNativeMobile) return child;

    final MediaQueryData media = MediaQuery.of(context);

    return ColoredBox(
      color: const Color(0xFFD8D8D8),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          // FittedBox reduz a moldura para caber SEMPRE inteira na
          // janela (qualquer tamanho de navegador), sem cortar.
          child: FittedBox(
            fit: BoxFit.contain,
            child: Container(
              width: screenWidth + _bezel * 2,
              height: screenHeight + _bezel * 2,
              padding: const EdgeInsets.all(_bezel),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(45),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x59000000),
                    blurRadius: 50,
                    offset: Offset(0, 20),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(33),
                child: ColoredBox(
                  color: const Color(0xFFF2F2F4),
                  child: SizedBox(
                    width: screenWidth,
                    height: screenHeight,
                    child: Column(
                      children: [
                        const _FakeStatusBar(height: _statusBarHeight),
                        Expanded(
                          // O app enxerga o tamanho da "tela do celular",
                          // não o da janela do navegador.
                          child: MediaQuery(
                            data: media.copyWith(
                              size: const Size(
                                screenWidth,
                                screenHeight - _statusBarHeight,
                              ),
                              padding: EdgeInsets.zero,
                              viewPadding: EdgeInsets.zero,
                              devicePixelRatio: 1,
                            ),
                            child: child,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Barra de status do "celular": hora real (atualiza sozinha) e ícones
/// de sinal, Wi-Fi e bateria — como no protótipo original.
class _FakeStatusBar extends StatefulWidget {
  const _FakeStatusBar({required this.height});

  final double height;

  @override
  State<_FakeStatusBar> createState() => _FakeStatusBarState();
}

class _FakeStatusBarState extends State<_FakeStatusBar> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Atualiza no virar de cada minuto.
    _timer = Timer.periodic(const Duration(seconds: 20), (_) {
      final DateTime now = DateTime.now();
      if (now.minute != _now.minute && mounted) {
        setState(() => _now = now);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _hora =>
      '${_now.hour.toString().padLeft(2, '0')}:'
      '${_now.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    const Color cor = Color(0xFF1A1A1A);

    // Material aqui é essencial: sem ele, o Flutter desenha o texto da
    // hora com o sublinhado amarelo de "texto órfão". A cor é a MESMA do
    // fundo do app (#F2F2F4), então o cinza vai até o topo, sem faixa branca.
    return Material(
      color: const Color(0xFFF2F2F4),
      child: SizedBox(
        height: widget.height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: [
              Text(
                _hora,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: cor,
                  decoration: TextDecoration.none,
                ),
              ),
              const Spacer(),
              const Icon(Icons.signal_cellular_alt, size: 15, color: cor),
              const SizedBox(width: 6),
              const Icon(Icons.wifi, size: 15, color: cor),
              const SizedBox(width: 6),
              const Icon(Icons.battery_full, size: 16, color: cor),
            ],
          ),
        ),
      ),
    );
  }
}
