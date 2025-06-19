// NOVO ARQUIVO: lib/api/firebase_api.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gestao_familiar_app/main.dart';

// Esta função precisa ser de alto nível (fora de qualquer classe) para funcionar em background
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  print('--- Notificação em Background ---');
  print('Título: ${message.notification?.title}');
  print('Corpo: ${message.notification?.body}');
  print('Dados: ${message.data}');
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    // Pede permissão ao usuário
    await _firebaseMessaging.requestPermission();

    // Pega o token FCM do dispositivo
    final fcmToken = await _firebaseMessaging.getToken();
    print('=================================');
    print('FCM Token: $fcmToken');
    print('=================================');

    // Salva o token no Supabase
    _saveTokenToSupabase(fcmToken);

    // Salva o token novamente toda vez que ele for atualizado pelo Firebase
    _firebaseMessaging.onTokenRefresh.listen(_saveTokenToSupabase);

    // Configura os listeners para quando o app está aberto ou em background
    initPushNotifications();
  }

  Future<void> _saveTokenToSupabase(String? token) async {
    if (token == null) return;

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Upsert: insere o token se não existir para o usuário, ou atualiza se já existir.
      await supabase.from('fcm_tokens').upsert({
        'user_id': userId,
        'token': token,
      });
    } catch (e) {
      print('Erro ao salvar token FCM: $e');
    }
  }

  void initPushNotifications() {
    // Quando o app está em primeiro plano (aberto e na tela)
    FirebaseMessaging.onMessage.listen((message) {
      print('--- Notificação em Primeiro Plano ---');
      print('Título: ${message.notification?.title}');
      print('Corpo: ${message.notification?.body}');
      print('Dados: ${message.data}');
      // Aqui você poderia mostrar um diálogo ou um SnackBar
    });

    // Quando o usuário toca na notificação e o app abre (estava em background)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('--- App aberto pela notificação ---');
      print('Dados: ${message.data}');
      // Aqui você poderia navegar para uma tela específica baseada nos dados
    });

    // Para notificações recebidas com o app em background ou terminado
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  }
}
