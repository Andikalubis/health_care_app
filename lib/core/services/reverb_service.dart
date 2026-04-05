import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:health_care_app/core/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ReverbService {
  static final ReverbService _instance = ReverbService._internal();
  factory ReverbService() => _instance;
  ReverbService._internal();

  PusherChannelsClient? _client;
  final Map<String, dynamic> _subscriptions = {};
  bool _isConnecting = false;
  String _currentStatus = 'disconnected';

  Future<void> init() async {
    if (_client != null) return;
    if (_isConnecting) {
      // Wait for existing connection attempt
      while (_isConnecting) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
      if (_client != null) return;
    }

    _isConnecting = true;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      if (kDebugMode) {
        print('ReverbService: No access token found, skipping init');
      }
      _isConnecting = false;
      return;
    }

    final host = dotenv.env['REVERB_HOST'] ?? 'localhost';
    final port = int.tryParse(dotenv.env['REVERB_PORT'] ?? '8080') ?? 8080;
    final key = dotenv.env['REVERB_APP_KEY'] ?? '';
    final scheme = dotenv.env['REVERB_SCHEME'] ?? 'http';

    if (kDebugMode) {
      print(
        'ReverbService: Initializing with host: $host, port: $port, key: $key, scheme: $scheme',
      );
    }

    try {
      final options = PusherChannelsOptions.fromHost(
        scheme: scheme,
        host: host,
        port: port,
        key: key,
      );

      _client = PusherChannelsClient.websocket(
        options: options,
        connectionErrorHandler: (error, trace, client) {
          if (kDebugMode) print('ReverbService: Connection Error: $error');
        },
      );

      _client?.lifecycleStream.listen((status) {
        _currentStatus = status.toString();
        if (kDebugMode) {
          print('ReverbService: Connection status changed: $status');
        }
        if (_currentStatus.toLowerCase().contains('disconnected')) {
          _reconnect();
        }
      });

      _client?.eventStream.listen((event) {
        if (kDebugMode) {
          print(
            'ReverbService: Incoming Event - Channel: ${event.channelName}, Name: ${event.name}',
          );
        }
      });

      await _client?.connect();
      if (kDebugMode) print('ReverbService: Connected successfully');

      // Subscribe to global user notifications after successful connection
      final userId = prefs.getInt('user_id');
      if (userId != null) {
        _subscribeToGlobalNotifications(userId);
      }
    } catch (e) {
      if (kDebugMode) print('ReverbService: Initialization failed: $e');
      _client = null;
    } finally {
      _isConnecting = false;
    }
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      if (_client != null &&
          !_currentStatus.toLowerCase().contains('connected')) {
        if (kDebugMode) print('ReverbService: Attempting to reconnect...');
        _client?.connect();
      }
    });
  }

  void _subscribeToGlobalNotifications(int userId) {
    if (kDebugMode) print('ReverbService: Subscribing for user $userId');

    // Laravel broadcasts the event as 'notification.created'
    // The payload typically contains a 'notification' object
    subscribePrivate('patient.$userId', 'notification.created', (data) {
      if (kDebugMode) {
        print('ReverbService: Global notification received: $data');
      }

      // Extract notification data. Laravel usually wraps it in the property name.
      final dynamic notificationData =
          data is Map && data.containsKey('notification')
          ? data['notification']
          : data;

      if (notificationData is! Map) {
        if (kDebugMode) {
          print('ReverbService: Invalid notification data format');
        }
        return;
      }

      final String title = notificationData['title'] ?? 'Notifikasi Baru';
      final String message = notificationData['message'] ?? '';
      final String? type = notificationData['notification_type']?.toString();
      final String? relatedId = notificationData['related_id']?.toString();

      if (kDebugMode) {
        print(
          'ReverbService: Processing notification - Type: $type, Title: $title',
        );
      }

      // Customize behavior based on type
      String finalTitle = title;
      if (type == 'medicine_reminder') {
        finalTitle = '💊 $title';
      } else if (type == 'meal_reminder') {
        finalTitle = '🍽️ $title';
      }

      // Trigger local popup
      LocalNotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: finalTitle,
        body: message,
        payload: relatedId,
      );
    });

    // Fallback or legacy support for specific medicine reminder event
    subscribePrivate('patient.$userId', 'medicine.reminder', (data) {
      if (kDebugMode) {
        print('ReverbService: Specific medicine reminder received: $data');
      }

      final dynamic payload = data is Map && data.containsKey('notification')
          ? data['notification']
          : data;

      LocalNotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: '💊 ${payload['title'] ?? 'Waktunya Minum Obat!'}',
        body: payload['message'] ?? '',
        payload:
            payload['schedule_id']?.toString() ??
            payload['related_id']?.toString(),
      );
    });
  }

  void subscribePrivate(
    String channelName,
    String eventName,
    Function(dynamic) callback,
  ) async {
    if (_client == null ||
        _currentStatus.toLowerCase().contains('disconnected')) {
      await init();
      if (_client == null) {
        if (kDebugMode) {
          print('ReverbService: Cannot subscribe, client is null');
        }
        return;
      }
    }

    final channelKey = "private-$channelName";
    if (!_subscriptions.containsKey(channelKey)) {
      if (kDebugMode) {
        print('ReverbService: Subscribing to private channel: $channelKey');
      }

      final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? '';
      // Try to determine the auth endpoint. Some Laravel setups use /broadcasting/auth, others /api/broadcasting/auth
      final baseUrl = apiBaseUrl.replaceAll('/api', '');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      _subscriptions[channelKey] = _client!.privateChannel(
        channelKey,
        authorizationDelegate:
            EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
              authorizationEndpoint: Uri.parse('$baseUrl/broadcasting/auth'),
              headers: {
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
              },
            ),
      );
      _subscriptions[channelKey].subscribe();
    }

    if (kDebugMode) {
      print('ReverbService: Binding event $eventName to channel $channelKey');
    }
    _subscriptions[channelKey].bind(eventName).listen((event) {
      if (kDebugMode) {
        print(
          'ReverbService: Event $eventName received on $channelKey - Data: ${event.data}',
        );
      }
      if (event.data != null) {
        callback(event.data);
      }
    });
  }

  void subscribePublic(
    String channelName,
    String eventName,
    Function(dynamic) callback,
  ) {
    if (_client == null) return;

    if (!_subscriptions.containsKey(channelName)) {
      if (kDebugMode) {
        print('ReverbService: Subscribing to public channel: $channelName');
      }
      _subscriptions[channelName] = _client!.publicChannel(channelName);
      _subscriptions[channelName].subscribe();
    }

    if (kDebugMode) {
      print('ReverbService: Binding event $eventName to channel $channelName');
    }
    _subscriptions[channelName].bind(eventName).listen((event) {
      if (kDebugMode) {
        print(
          'ReverbService: Event $eventName received on $channelName - Data: ${event.data}',
        );
      }
      if (event.data != null) {
        callback(event.data);
      }
    });
  }

  void disconnect() {
    if (kDebugMode) print('ReverbService: Disconnecting');
    _client?.disconnect();
    _subscriptions.clear();
    _client = null;
  }
}
