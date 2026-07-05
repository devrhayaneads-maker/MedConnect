import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Status possíveis de uma consulta (badges do protótipo original).
enum AppointmentStatus {
  confirmed('Confirmado'),
  pending('Pendente'),
  done('Realizado'),
  canceled('Cancelado');

  const AppointmentStatus(this.label);

  final String label;

  Color get color => switch (this) {
        AppointmentStatus.confirmed => AppColors.statusConfirmed,
        AppointmentStatus.pending => AppColors.statusPending,
        AppointmentStatus.done => AppColors.statusDone,
        AppointmentStatus.canceled => AppColors.statusCanceled,
      };

  Color get backgroundColor => switch (this) {
        AppointmentStatus.confirmed => AppColors.statusConfirmedBg,
        AppointmentStatus.pending => AppColors.statusPendingBg,
        AppointmentStatus.done => AppColors.statusDoneBg,
        AppointmentStatus.canceled => AppColors.statusCanceledBg,
      };
}

/// Filtros da tela "Minhas Consultas"
/// (Todas / Futuras / Realizadas / Canceladas).
enum AppointmentFilter {
  all('Todas'),
  upcoming('Futuras'),
  done('Realizadas'),
  canceled('Canceladas');

  const AppointmentFilter(this.label);

  final String label;

  bool matches(Appointment appointment) => switch (this) {
        AppointmentFilter.all => true,
        AppointmentFilter.upcoming =>
          appointment.status == AppointmentStatus.confirmed ||
              appointment.status == AppointmentStatus.pending,
        AppointmentFilter.done =>
          appointment.status == AppointmentStatus.done,
        AppointmentFilter.canceled =>
          appointment.status == AppointmentStatus.canceled,
      };
}

/// Uma consulta médica agendada pelo paciente.
@immutable
class Appointment {
  const Appointment({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.clinicName,
    required this.dateTime,
    required this.status,
    required this.avatarColor,
    this.calendarAsset,
  });

  final String id;
  final String doctorName;
  final String specialty;
  final String clinicName;
  final DateTime dateTime;
  final AppointmentStatus status;
  final Color avatarColor;

  /// Mini-calendário em PNG usado no protótipo original para esta data
  /// (ex.: assets/icons/calendario-15-abr.png). Quando nulo, o card usa
  /// um ícone padrão.
  final String? calendarAsset;

  bool get isCancelable =>
      status == AppointmentStatus.confirmed ||
      status == AppointmentStatus.pending;

  Appointment copyWith({AppointmentStatus? status}) => Appointment(
        id: id,
        doctorName: doctorName,
        specialty: specialty,
        clinicName: clinicName,
        dateTime: dateTime,
        status: status ?? this.status,
        avatarColor: avatarColor,
        calendarAsset: calendarAsset,
      );
}
