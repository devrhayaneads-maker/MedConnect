import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';

/// Avatar circular com as iniciais do nome
/// (equivalente aos `.avatar` / `.avatar-clinic` do CSS original).
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    this.color = AppColors.primary,
    this.size = 46,
    this.outlined = false,
  });

  final String name;
  final Color color;
  final double size;

  /// Estilo com borda e fundo claro (padrão das clínicas/conversas).
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final Color background =
        outlined ? AppColors.greenSoft : color.withValues(alpha: 0.15);
    final Color foreground = outlined ? AppColors.primaryDark : color;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background,
        border: outlined
            ? Border.all(color: AppColors.primaryDark, width: 2)
            : null,
      ),
      child: Text(
        Formatters.initials(name),
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.32,
        ),
      ),
    );
  }
}
