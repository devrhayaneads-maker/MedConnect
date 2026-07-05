import 'package:flutter/material.dart';

import '../../controllers/app_scope.dart';
import '../appointments/appointments_screen.dart';
import '../clinics/clinics_screen.dart';
import '../home/home_screen.dart';
import '../messages/messages_screen.dart';
import '../profile/profile_screen.dart';

/// Estrutura principal do app: navegação inferior com 5 abas
/// (Início, Consultas, Mensagens, Clínicas e Perfil), preservando o
/// estado de cada tela com [IndexedStack].
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final AppScope scope = AppScope.of(context);

    return ValueListenableBuilder<int>(
      valueListenable: scope.tabIndex,
      builder: (context, index, _) {
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: IndexedStack(
              index: index,
              children: const [
                HomeScreen(),
                AppointmentsScreen(),
                MessagesScreen(),
                ClinicsScreen(),
                ProfileScreen(),
              ],
            ),
          ),
          bottomNavigationBar: ListenableBuilder(
            listenable: scope.conversations,
            builder: (context, _) {
              final int unread = scope.conversations.totalUnread;
              return NavigationBar(
                selectedIndex: index,
                onDestinationSelected: scope.goToTab,
                destinations: [
                  const NavigationDestination(
                    icon: _NavIcon('assets/icons/inicio.png'),
                    label: 'Início',
                  ),
                  const NavigationDestination(
                    icon: _NavIcon('assets/icons/consultas.png'),
                    label: 'Consultas',
                  ),
                  NavigationDestination(
                    icon: Badge.count(
                      count: unread,
                      isLabelVisible: unread > 0,
                      child: const _NavIcon('assets/icons/mensagen.png'),
                    ),
                    label: 'Mensagens',
                  ),
                  const NavigationDestination(
                    icon: _NavIcon('assets/icons/clinicas.png'),
                    label: 'Clínicas',
                  ),
                  const NavigationDestination(
                    icon: _NavIcon('assets/icons/perfil.png'),
                    label: 'Perfil',
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

/// Ícone da navegação inferior: usa os MESMOS PNGs coloridos do
/// protótipo original (`assets/icons/inicio.png` etc.), em 24px,
/// como o `.nav-item img` do CSS.
class _NavIcon extends StatelessWidget {
  const _NavIcon(this.asset);

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: 24,
      height: 24,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.circle_outlined, size: 24),
    );
  }
}
