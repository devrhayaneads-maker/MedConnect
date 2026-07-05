import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Banner de "ação desfeita" totalmente independente do
/// `ScaffoldMessenger`/`SnackBar` do Flutter — usado porque o
/// auto-fechamento do `SnackBar` nativo não estava disparando de forma
/// confiável em alguns aparelhos. Controla sozinho, com um `Timer`
/// próprio, quando aparece e quando some.
abstract final class UndoBanner {
  static void show(
    BuildContext context, {
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    final OverlayState overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    Timer? timer;
    bool removed = false;

    void remove() {
      if (removed) return;
      removed = true;
      timer?.cancel();
      entry.remove();
    }

    entry = OverlayEntry(
      builder: (context) => _UndoBannerWidget(
        message: message,
        actionLabel: actionLabel,
        onAction: () {
          onAction();
          remove();
        },
      ),
    );

    overlay.insert(entry);
    timer = Timer(duration, remove);
  }
}

class _UndoBannerWidget extends StatelessWidget {
  const _UndoBannerWidget({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData media = MediaQuery.of(context);
    return Positioned(
      left: 16,
      right: 16,
      bottom: media.padding.bottom + media.viewInsets.bottom + 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.textDark,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: onAction,
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    color: AppColors.greenSoft,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
