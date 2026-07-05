import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Cartão de ação rápida da home.
///
/// Fiel ao protótipo original: cada cartão é a própria IMAGEM do tile
/// (`assets/icons/agendar-consulta.png` etc.), com cantos arredondados
/// de 14px, exatamente como o `.action-link img` do CSS.
class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.imageAsset,
    required this.label,
    required this.onTap,
    required this.aspectRatio,
  });

  final String imageAsset;
  final String label;
  final VoidCallback onTap;

  /// Proporção (largura / altura) real do PNG do tile. A célula precisa
  /// respeitar essa proporção para o `BoxFit.cover` preencher o cartão
  /// inteiro sem cortar nem sobrar borda (cada imagem tem dimensões
  /// ligeiramente diferentes: ex. mensagens.png é 356x168, documentos.png
  /// é 348x168).
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imageAsset,
              fit: BoxFit.cover,
              // Se a imagem faltar, mostra um cartão simples equivalente.
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.greenLight,
                alignment: Alignment.center,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                splashColor: Colors.white24,
                highlightColor: Colors.white10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
