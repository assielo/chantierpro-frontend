import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'api_service.dart';

class JournalSocketService {
  WebSocketChannel? _channel;

  void connect(int projectId, Function(dynamic data) onMessageReceived) {
    // Remplacez l'URL HTTP par ws:// ou wss:// selon votre configuration backend
    final wsUrl = ApiService.baseUrl.replaceFirst('http', 'ws');
    final uri = Uri.parse('$wsUrl/ws/projects/$projectId/journal');

    try {
      _channel = WebSocketChannel.connect(uri);
      _channel!.stream.listen(
        (message) {
          final data = message; // ou jsonDecode(message) si envoyé en JSON brut
          onMessageReceived(data);
        },
        onError: (error) {
          debugPrint('Erreur WebSocket : $error');
        },
        onDone: () {
          debugPrint('Connexion WebSocket fermée.');
        },
      );
    } catch (e) {
      debugPrint('Impossible de se connecter au WebSocket : $e');
    }
  }

  void sendMessage(Map<String, dynamic> data) {
    if (_channel != null) {
      _channel!.sink.add(data.toString());
    }
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
