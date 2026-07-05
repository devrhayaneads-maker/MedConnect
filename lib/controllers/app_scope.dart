import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

import '../repositories/clinics_repository.dart';
import '../repositories/conversations_repository.dart';
import 'appointments_controller.dart';
import 'clinics_controller.dart';
import 'conversations_controller.dart';
import 'profile_controller.dart';

/// Escopo de dependências do aplicativo.
///
/// Disponibiliza os controllers para toda a árvore de widgets sem
/// dependências externas (padrão InheritedWidget + ChangeNotifier).
class AppScope extends InheritedWidget {
  AppScope({
    super.key,
    required super.child,
    required String uid,
    FirebaseFirestore? firestore,
  })  : conversations = ConversationsController(
          ConversationsRepository(uid, firestore: firestore),
        ),
        clinics = ClinicsController(ClinicsRepository(firestore: firestore));

  final AppointmentsController appointments = AppointmentsController();
  final ConversationsController conversations;
  final ClinicsController clinics;
  final ProfileController profile = ProfileController();

  /// Índice da aba ativa na navegação inferior. Permite que a home
  /// ("Ações rápidas") e o fluxo de agendamento troquem de aba.
  final ValueNotifier<int> tabIndex = ValueNotifier<int>(0);

  static AppScope of(BuildContext context) {
    final AppScope? scope =
        context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope não encontrado na árvore de widgets.');
    return scope!;
  }

  void goToTab(int index) => tabIndex.value = index;

  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}
