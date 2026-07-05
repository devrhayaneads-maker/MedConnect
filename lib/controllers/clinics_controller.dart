import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/clinic.dart';
import '../repositories/clinics_repository.dart';

/// Estado reativo da tela "Encontrar clínica" (busca por nome/especialidade),
/// assinando a coleção `clinics` do Firestore em tempo real.
class ClinicsController extends ChangeNotifier {
  ClinicsController(this._repository) {
    _repository.syncSeedData().then((_) => _listen());
  }

  final ClinicsRepository _repository;
  StreamSubscription<List<Clinic>>? _subscription;
  List<Clinic> _clinics = <Clinic>[];
  String _query = '';

  /// Amostra exibida quando o campo de busca está vazio — o restante
  /// das clínicas cadastradas só aparece quando a paciente busca.
  static const List<String> _featuredIds = <String>[
    'medcenter',
    'clinica-center-vicosa',
    'salude-clinicas-integradas',
    'cismiv',
    'amo-oftalmologia',
  ];

  String get query => _query;

  bool get isShowingFeatured => _query.trim().isEmpty;

  List<Clinic> get filtered {
    if (_query.trim().isEmpty) {
      return _clinics.where((c) => _featuredIds.contains(c.id)).toList();
    }
    return _clinics.where((c) => c.matches(_query)).toList();
  }

  void setQuery(String query) {
    if (_query == query) return;
    _query = query;
    notifyListeners();
  }

  void _listen() {
    _subscription = _repository.watchClinics().listen((clinics) {
      _clinics = clinics;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
