/// Utilitários de formatação em pt-BR, sem dependências externas.
abstract final class Formatters {
  static const List<String> _shortMonths = <String>[
    'jan.', 'fev.', 'mar.', 'abr.', 'mai.', 'jun.',
    'jul.', 'ago.', 'set.', 'out.', 'nov.', 'dez.',
  ];

  /// Ex.: `15 de abr. de 2026` (mesmo formato do protótipo original).
  static String longDate(DateTime date) =>
      '${date.day} de ${_shortMonths[date.month - 1]} de ${date.year}';

  /// Ex.: `09:30`.
  static String time(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')}';

  /// Ex.: `10/05/2026`.
  static String shortDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  /// Rótulo relativo usado na lista de conversas:
  /// hora para hoje, "Ontem" para o dia anterior, data curta para o resto.
  static String conversationTimestamp(DateTime date, {DateTime? now}) {
    final DateTime reference = now ?? DateTime.now();
    final DateTime today =
        DateTime(reference.year, reference.month, reference.day);
    final DateTime day = DateTime(date.year, date.month, date.day);
    final int diff = today.difference(day).inDays;

    if (diff <= 0) return time(date);
    if (diff == 1) return 'Ontem';
    return shortDate(date);
  }

  /// Saudação conforme o horário (a home original exibia "Bom dia" fixo).
  static String greeting({DateTime? now}) {
    final int hour = (now ?? DateTime.now()).hour;
    if (hour < 12) return 'Bom dia,';
    if (hour < 18) return 'Boa tarde,';
    return 'Boa noite,';
  }

  /// Iniciais para avatares: "Dr. Rafael Mendes" -> "RM".
  static String initials(String name) {
    final List<String> parts = name
        .replaceAll(RegExp(r'\b(Dr|Dra|Sr|Sra)\.?\s', caseSensitive: false), '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
