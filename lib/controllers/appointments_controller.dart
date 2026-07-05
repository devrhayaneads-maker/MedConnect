import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../data/mock_data.dart';
import '../models/appointment.dart';

/// Estado reativo das consultas: lista, filtro ativo, cancelamento
/// (com desfazer) e criação de novos agendamentos.
class AppointmentsController extends ChangeNotifier {
  AppointmentsController() : _appointments = MockData.appointments();

  final List<Appointment> _appointments;
  AppointmentFilter _filter = AppointmentFilter.all;

  AppointmentFilter get filter => _filter;

  List<Appointment> get all => List<Appointment>.unmodifiable(_appointments);

  /// Consultas visíveis segundo o filtro ativo, ordenadas por data.
  List<Appointment> get filtered {
    final List<Appointment> list =
        _appointments.where(_filter.matches).toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  /// Quantidade de consultas futuras (banner da home:
  /// "Você tem N consultas agendadas").
  int get upcomingCount =>
      _appointments.where(AppointmentFilter.upcoming.matches).length;

  /// Próxima consulta confirmada/pendente (card "Próxima consulta" da home).
  Appointment? get nextAppointment {
    final List<Appointment> upcoming = _appointments
        .where(AppointmentFilter.upcoming.matches)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return upcoming.isEmpty ? null : upcoming.first;
  }

  void setFilter(AppointmentFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  /// Cancela a consulta e devolve o status anterior,
  /// permitindo a ação "Desfazer" na Snackbar.
  AppointmentStatus? cancel(String id) {
    final int index = _appointments.indexWhere((a) => a.id == id);
    if (index == -1 || !_appointments[index].isCancelable) return null;

    final AppointmentStatus previous = _appointments[index].status;
    _appointments[index] =
        _appointments[index].copyWith(status: AppointmentStatus.canceled);
    notifyListeners();
    return previous;
  }

  /// Restaura o status anterior de uma consulta cancelada ("Desfazer").
  void restore(String id, AppointmentStatus previousStatus) {
    final int index = _appointments.indexWhere((a) => a.id == id);
    if (index == -1) return;
    _appointments[index] =
        _appointments[index].copyWith(status: previousStatus);
    notifyListeners();
  }

  /// Cria um novo agendamento (fluxo "Agendar Consulta" das clínicas).
  Appointment book({
    required String clinicName,
    required String specialty,
    required DateTime dateTime,
  }) {
    final Appointment appointment = Appointment(
      id: 'novo-${DateTime.now().microsecondsSinceEpoch}',
      doctorName: 'A definir pela clínica',
      specialty: specialty,
      clinicName: clinicName,
      dateTime: dateTime,
      status: AppointmentStatus.pending,
      avatarColor: AppColors.avatarGreen,
    );
    _appointments.add(appointment);
    notifyListeners();
    return appointment;
  }
}
