import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'controllers/app_scope.dart';
import 'core/theme/app_theme.dart';
import 'screens/shell/app_shell.dart';
import 'widgets/phone_frame.dart';

/// Widget raiz do MedConnect: injeta o [AppScope] (controllers) e
/// aplica o tema global.
///
/// No navegador (Flutter Web), o app é apresentado dentro de uma
/// moldura de celular centralizada — como no protótipo original.
/// Instalado no aparelho, ocupa a tela inteira normalmente.
class MedConnectApp extends StatelessWidget {
  const MedConnectApp({
    super.key,
    required this.navigatorKey,
    required this.uid,
    this.firestore,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final String uid;
  final FirebaseFirestore? firestore;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      uid: uid,
      firestore: firestore,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'MedConnect',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        builder: (context, child) =>
            PhoneFrame(child: child ?? const SizedBox.shrink()),
        home: const AppShell(),
      ),
    );
  }
}
