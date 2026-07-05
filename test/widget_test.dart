// Teste básico de smoke: garante que o MedConnectApp constrói sem erros.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:medconnect/app.dart';

void main() {
  testWidgets('MedConnectApp constrói sem lançar exceções',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MedConnectApp(
        navigatorKey: GlobalKey<NavigatorState>(),
        uid: 'test-uid',
        firestore: FakeFirebaseFirestore(),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
