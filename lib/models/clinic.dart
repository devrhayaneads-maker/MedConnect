import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Uma clínica parceira exibida na tela "Encontrar clínica" — dados
/// reais de Viçosa, MG (ver `lib/data/clinics_seed.dart`), carregados
/// do Firestore.
@immutable
class Clinic {
  const Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.rating,
    required this.specialties,
  });

  final String id;
  final String name;
  final String address;
  final String phone;
  final double rating;
  final List<String> specialties;

  /// Texto usado pela busca (equivalente ao `data-busca` do HTML original).
  String get searchIndex =>
      '${name.toLowerCase()} ${specialties.join(' ').toLowerCase()} '
      '${address.toLowerCase()}';

  bool matches(String query) {
    final String term = query.trim().toLowerCase();
    if (term.isEmpty) return true;
    return searchIndex.contains(term);
  }

  Map<String, Object?> toFirestore() => <String, Object?>{
        'name': name,
        'address': address,
        'phone': phone,
        'rating': rating,
        'specialties': specialties,
      };

  factory Clinic.fromFirestore(
    QueryDocumentSnapshot<Map<String, Object?>> doc,
  ) {
    final Map<String, Object?> data = doc.data();
    return Clinic(
      id: doc.id,
      name: data['name'] as String? ?? '',
      address: data['address'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      specialties: List<String>.from(data['specialties'] as List? ?? const []),
    );
  }
}
