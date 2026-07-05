import 'package:firebase_auth/firebase_auth.dart';

/// Garante um usuário autenticado (anônimo) para uso do Firestore,
/// sem exigir nenhuma tela de login da paciente.
abstract final class AuthService {
  static Future<String> ensureSignedIn() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser ?? (await auth.signInAnonymously()).user!;
    return user.uid;
  }
}
