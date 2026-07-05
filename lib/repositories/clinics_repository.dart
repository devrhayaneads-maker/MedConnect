import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/clinics_seed.dart';
import '../models/clinic.dart';

/// Acesso ao Firestore para a coleção pública `clinics` (curada
/// manualmente, ver `lib/data/clinics_seed.dart`).
class ClinicsRepository {
  ClinicsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, Object?>> get _clinicsRef =>
      _firestore.collection('clinics');

  Stream<List<Clinic>> watchClinics() => _clinicsRef
      .snapshots()
      .map((snapshot) => snapshot.docs.map(Clinic.fromFirestore).toList());

  /// Sincroniza a coleção `clinics` com a lista curada em
  /// `ClinicsSeed.clinics` (upsert por `set()` — idempotente, sem
  /// duplicar). Roda a cada início do app para que atualizações na
  /// lista curada (novas clínicas, correções) cheguem ao Firestore
  /// sem precisar de um script separado.
  Future<void> syncSeedData() async {
    final WriteBatch batch = _firestore.batch();
    for (final Clinic clinic in ClinicsSeed.clinics) {
      batch.set(_clinicsRef.doc(clinic.id), clinic.toFirestore());
    }
    await batch.commit();
  }
}
