import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:dio/dio.dart';
import 'dio_client.dart';

class SyncService {
  final DioClient _dioClient;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  
  bool _isConnected = false;
  bool _shouldReconnect = false;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  
  // Maximum reconnection attempts before giving up
  static const int _maxReconnectAttempts = 5;
  
  final String _appKey = 'habit_tracker_reverb_key'; // Default app key (matches .env)
  
  // Callback when a sync notification is received
  final List<VoidCallback> _listeners = [];
  
  SyncService(this._dioClient) {
    debugPrint('🔌 SyncService: Constructor called (HashCode: $hashCode)');
  }
  
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }
  
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }
  
  void _notifyListeners() {
    for (final listener in _listeners) {
      try {
        listener();
      } catch (e) {
        debugPrint('❌ SyncService listener error: $e');
      }
    }
  }

  // Determine WebSocket URL from Dio API baseUrl
  String _getWsUrl() {
    final apiUri = Uri.parse(_dioClient.dio.options.baseUrl);
    final host = apiUri.host;
    
    // Check if local dev environment
    final isLocal = host == '127.0.0.1' || host == 'localhost' || host == '10.0.2.2' || host.startsWith('192.168.');
    
    final scheme = isLocal ? 'ws' : 'wss';
    final portStr = isLocal ? ':8080' : ':443'; // Reverb runs on 8080 locally, but proxied on port 443 in production
    
    return '$scheme://$host$portStr/app/$_appKey?protocol=7&client=js&version=4.4.0&flash=false';
  }

  void connect(String userId) {
    if (_isConnected) return;
    
    _shouldReconnect = true;
    final wsUrl = _getWsUrl();
    debugPrint('🔌 SyncService [$hashCode]: Connecting to $wsUrl');
    
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;
      
      // Catch connection/handshake upgrade failures gracefully to eliminate unhandled exceptions in logs
      _channel!.ready.then((_) {
        debugPrint('🔌 SyncService: WebSocket connection handshake completed.');
        _reconnectAttempts = 0; // Reset only after a successful connection handshake
      }).catchError((error) {
        final errorStr = error.toString();
        debugPrint('❌ SyncService: Handshake failed (server might not be running Reverb/WebSockets): $error');
        
        // If the server doesn't support WebSocket upgrade, stop retrying immediately
        if (errorStr.contains('not upgraded to websocket') || 
            errorStr.contains('WebSocketException') ||
            errorStr.contains('400') ||
            errorStr.contains('404')) {
          debugPrint('🔌 SyncService: Server does not support WebSockets. Disabling reconnection.');
          _shouldReconnect = false;
        }
      });
      
      _subscription = _channel!.stream.listen(
        (message) => _handleIncomingMessage(message, userId),
        onError: (error) {
          final errorStr = error.toString();
          // Handshake errors are already caught and logged by ready.catchError.
          // Just trigger disconnect state and reconnection here.
          
          // If the server doesn't support WebSocket upgrade, stop retrying immediately
          if (errorStr.contains('not upgraded to websocket') || 
              errorStr.contains('WebSocketException') ||
              errorStr.contains('400') ||
              errorStr.contains('404')) {
            debugPrint('🔌 SyncService: Server does not support WebSockets. Disabling reconnection.');
            _shouldReconnect = false;
          }
          _handleDisconnect(userId);
        },
        onDone: () {
          debugPrint('🔌 SyncService WebSocket connection closed.');
          _handleDisconnect(userId);
        },
      );
    } catch (e) {
      debugPrint('❌ SyncService connection failed: $e');
      _handleDisconnect(userId);
    }
  }

  void disconnect() {
    debugPrint('🔌 SyncService: Disconnecting');
    _shouldReconnect = false;
    _isConnected = false;
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  void _handleDisconnect(String userId) {
    _isConnected = false;
    _subscription?.cancel();
    _channel = null;
    
    if (_shouldReconnect && _reconnectAttempts < _maxReconnectAttempts) {
      _reconnectAttempts++;
      // Exponential backoff up to 30 seconds
      final delay = Duration(seconds: (_reconnectAttempts * 2).clamp(1, 30));
      debugPrint('🔌 SyncService [$hashCode]: Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts/$_maxReconnectAttempts)...');
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(delay, () => connect(userId));
    } else if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('🔌 SyncService [$hashCode]: Max reconnection attempts ($_maxReconnectAttempts) reached. Giving up. Server may not support WebSockets.');
      _shouldReconnect = false;
    }
  }

  Future<void> _handleIncomingMessage(dynamic message, String userId) async {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final event = data['event'] as String?;
      
      if (event == 'pusher:connection_established') {
        final socketId = (jsonDecode(data['data'] as String) as Map<String, dynamic>)['socket_id'] as String;
        debugPrint('🔌 SyncService: Connection established. Socket ID: $socketId');
        await _subscribeToChannel(userId, socketId);
      } else if (event == 'sync') {
        debugPrint('🔄 SyncService: Received sync notification: ${data['data']}');
        _notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ SyncService: Failed to parse message: $e');
    }
  }

  Future<void> _subscribeToChannel(String userId, String socketId) async {
    final channelName = 'private-user.$userId';
    debugPrint('🔌 SyncService: Authorizing subscription for $channelName');
    
    try {
      // POST to broadcasting/auth route to get token (using path absolute relative to baseUrl)
      final response = await _dioClient.dio.post<Map<String, dynamic>>(
        '/broadcasting/auth',
        data: {
          'socket_id': socketId,
          'channel_name': channelName,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        final auth = response.data!['auth'] as String;
        
        // Send subscribe message to WebSocket
        final subscribeMessage = jsonEncode({
          'event': 'pusher:subscribe',
          'data': {
            'channel': channelName,
            'auth': auth,
          }
        });
        
        _channel?.sink.add(subscribeMessage);
        debugPrint('🔌 SyncService: Subscribed to $channelName');
      } else {
        debugPrint('❌ SyncService: Failed to authorize channel: ${response.statusCode} - ${response.statusMessage}');
      }
    } catch (e) {
      debugPrint('❌ SyncService: Subscription authorization failed: $e');
    }
  }
}
