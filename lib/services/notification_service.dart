import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../screens/messages/chat_screen.dart';

/// Notificação local disparada pelo próprio app quando chega uma nova
/// mensagem da clínica (sem servidor/push real — ver decisão de
/// projeto em torno do plano gratuito do Firebase). Funciona enquanto
/// o app está aberto ou em segundo plano.
abstract final class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'chat_messages',
    'Mensagens do chat',
    description: 'Notificações de novas mensagens das clínicas.',
    importance: Importance.high,
  );

  static GlobalKey<NavigatorState>? navigatorKey;

  static Future<void> init(GlobalKey<NavigatorState> key) async {
    navigatorKey = key;

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        windows: WindowsInitializationSettings(
          appName: 'MedConnect',
          appUserModelId: 'UNIVICOSA.MedConnect.App',
          guid: 'be2a6b9c-1849-4d9f-b40c-530343b5a523',
        ),
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static void _onNotificationTap(NotificationResponse response) {
    final String? conversationId = response.payload;
    final BuildContext? context = navigatorKey?.currentContext;
    if (conversationId == null || context == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatScreen(conversationId: conversationId),
      ),
    );
  }

  static Future<void> showClinicMessage({
    required String conversationId,
    required String clinicName,
    required String body,
  }) {
    return _plugin.show(
      id: conversationId.hashCode,
      title: clinicName,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: conversationId,
    );
  }
}
