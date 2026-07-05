import '../core/theme/app_colors.dart';
import '../models/appointment.dart';
import '../models/conversation.dart';

/// Dados de demonstração, fiéis ao conteúdo do protótipo original
/// (html/index.html, consultas.html, clinicas.html e mensagens.html).
abstract final class MockData {
  static const String userName = 'Maria Silva';
  static const String userEmail = 'maria.silva@gmail.com';

  static List<Appointment> appointments() => <Appointment>[
        Appointment(
          id: 'rafael-2026-04-15-0930',
          doctorName: 'Dr. Rafael Mendes',
          specialty: 'Cardiologia',
          clinicName: 'Clínica São Lucas',
          dateTime: DateTime(2026, 4, 15, 9, 30),
          status: AppointmentStatus.confirmed,
          avatarColor: AppColors.avatarGreen,
          calendarAsset: 'assets/icons/calendario-15-abr.png',
        ),
        Appointment(
          id: 'carlos-2026-04-22-1400',
          doctorName: 'Dr. Carlos Souza',
          specialty: 'Ortopedia',
          clinicName: 'Centro Médico Norte',
          dateTime: DateTime(2026, 4, 22, 14, 0),
          status: AppointmentStatus.pending,
          avatarColor: AppColors.avatarOrange,
          calendarAsset: 'assets/icons/calendario_22.png',
        ),
        Appointment(
          id: 'ana-2026-03-28-1100',
          doctorName: 'Dra. Ana Lima',
          specialty: 'Dermatologia',
          clinicName: 'Instituto Vida',
          dateTime: DateTime(2026, 3, 28, 11, 0),
          status: AppointmentStatus.done,
          avatarColor: AppColors.avatarPurple,
          calendarAsset: 'assets/icons/calendario_28.png',
        ),
      ];


  static List<Conversation> conversations() {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    return <Conversation>[
      Conversation(
        id: 'instituto-vida',
        clinicName: 'Instituto Vida',
        lastMessageAt: today.add(const Duration(hours: 15, minutes: 30)),
        unreadCount: 0,
        messages: <ChatMessage>[
          ChatMessage(
            id: '',
            text: 'Olá! Vocês atendem pelo plano Unimed?',
            sentByUser: true,
            sentAt: today.add(const Duration(hours: 15, minutes: 12)),
          ),
          ChatMessage(
            id: '',
            text: 'Sim, nós atendemos pelo seu plano. Deseja agendar?',
            sentByUser: false,
            sentAt: today.add(const Duration(hours: 15, minutes: 30)),
          ),
        ],
      ),
      Conversation(
        id: 'sao-lucas',
        clinicName: 'Clínica São Lucas',
        lastMessageAt: today.subtract(const Duration(hours: 8)),
        unreadCount: 5,
        messages: <ChatMessage>[
          ChatMessage(
            id: '',
            text: 'A sua consulta é amanhã às 09:30 com o Dr. Rafael Mendes.',
            sentByUser: false,
            sentAt: today.subtract(const Duration(hours: 8, minutes: 20)),
          ),
          ChatMessage(
            id: '',
            text: 'Por favor, chegue com 15 minutos de antecedência.',
            sentByUser: false,
            sentAt: today.subtract(const Duration(hours: 8, minutes: 15)),
          ),
          ChatMessage(
            id: '',
            text: 'Não esqueça de trazer um documento com foto.',
            sentByUser: false,
            sentAt: today.subtract(const Duration(hours: 8, minutes: 10)),
          ),
          ChatMessage(
            id: '',
            text: 'Se precisar remarcar, nos avise com 24h de antecedência.',
            sentByUser: false,
            sentAt: today.subtract(const Duration(hours: 8, minutes: 5)),
          ),
          ChatMessage(
            id: '',
            text: 'Qualquer dúvida, estamos à disposição por aqui!',
            sentByUser: false,
            sentAt: today.subtract(const Duration(hours: 8)),
          ),
        ],
      ),
      Conversation(
        id: 'centro-norte',
        clinicName: 'Centro Médico Norte',
        lastMessageAt: DateTime(2026, 5, 10, 11, 20),
        unreadCount: 0,
        messages: <ChatMessage>[
          ChatMessage(
            id: '',
            text: 'O resultado do seu exame ficou pronto!',
            sentByUser: false,
            sentAt: DateTime(2026, 5, 10, 11, 20),
          ),
        ],
      ),
      Conversation(
        id: 'santa-casa',
        clinicName: 'Santa Casa',
        lastMessageAt: DateTime(2026, 5, 9, 9, 5),
        unreadCount: 1,
        messages: <ChatMessage>[
          ChatMessage(
            id: '',
            text: 'Em que posso ajudar?',
            sentByUser: false,
            sentAt: DateTime(2026, 5, 9, 9, 5),
          ),
        ],
      ),
      Conversation(
        id: 'centro-imagem',
        clinicName: 'Centro de Imagem Avançada',
        lastMessageAt: DateTime(2026, 5, 10, 10, 0),
        unreadCount: 0,
        messages: <ChatMessage>[
          ChatMessage(
            id: '',
            text: 'Em que podemos ajudar?',
            sentByUser: false,
            sentAt: DateTime(2026, 5, 10, 10, 0),
          ),
        ],
      ),
      Conversation(
        id: 'oftalmocenter',
        clinicName: 'OftalmoCenter',
        lastMessageAt: DateTime(2026, 5, 10, 8, 40),
        unreadCount: 0,
        messages: <ChatMessage>[
          ChatMessage(
            id: '',
            text: 'Oi, gostaria de marcar uma consulta.',
            sentByUser: true,
            sentAt: DateTime(2026, 5, 10, 8, 40),
          ),
        ],
      ),
      Conversation(
        id: 'oftalmoclinic',
        clinicName: 'OftalmoClinic',
        lastMessageAt: DateTime(2026, 5, 10, 8, 35),
        unreadCount: 0,
        messages: <ChatMessage>[
          ChatMessage(
            id: '',
            text: 'Oi, gostaria de marcar uma consulta.',
            sentByUser: true,
            sentAt: DateTime(2026, 5, 10, 8, 35),
          ),
        ],
      ),
    ];
  }
}
