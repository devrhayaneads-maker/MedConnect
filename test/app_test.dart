import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medconnect/app.dart';

void main() {
  testWidgets('MedConnect abre na home e navega entre as abas',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MedConnectApp(
        navigatorKey: GlobalKey<NavigatorState>(),
        uid: 'test-uid',
        firestore: FakeFirebaseFirestore(),
      ),
    );
    await tester.pumpAndSettle();

    // Home: banner de boas-vindas e ações rápidas.
    expect(find.textContaining('Maria Silva'), findsWidgets);
    expect(find.text('Ações rápidas'), findsOneWidget);

    // Conteúdo das demais telas (IndexedStack mantém todas construídas).
    expect(find.text('Minhas Consultas'), findsOneWidget);
    expect(find.text('Dr. Rafael Mendes'), findsWidgets);
    expect(find.text('Encontrar clínica'), findsOneWidget);
    expect(find.text('Clínica São Lucas'), findsWidgets);

    // Navegação inferior alterna as abas sem erros.
    await tester.tap(find.text('Consultas'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clínicas'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
