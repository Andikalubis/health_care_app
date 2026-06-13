import 'dart:convert';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:health_care_app/core/services/notification_service.dart';
import 'package:health_care_app/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReverbService {
  static final ReverbService _instance = ReverbService._internal();
  factory ReverbService() => _instance;
  ReverbService._internal();

  PusherChannelsClient? _client;
  final Map<String, dynamic> _subscriptions = {};
  bool _isConnecting = false;
  String _currentStatus = 'disconnected';
  int? _currentUserId;
  final Map<String, Set<String>> _boundEvents = {};

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final userId = prefs.getInt('user_id');
    final userRole = prefs.getString('user_role') ?? 'user';

    if (_client != null) {
      if (!_currentStatus.toLowerCase().contains('established')) {
        _client?.connect();
      }
      if (userId != null && userRole != 'admin' && _currentUserId != userId) {
        _subscribeToGlobalNotifications(userId);
      }
      return;
    }

    if (_isConnecting) {
      while (_isConnecting) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
      if (_client != null) {
        if (userId != null && userRole != 'admin' && _currentUserId != userId) {
          _subscribeToGlobalNotifications(userId);
        }
        return;
      }
    }

    _isConnecting = true;

    if (token == null) {
      Log.info('Reverb', 'No access token found, skipping init');
      _isConnecting = false;
      return;
    }

    final host = dotenv.env['REVERB_HOST'] ?? '202.74.74.126';
    final port = int.tryParse(dotenv.env['REVERB_PORT'] ?? '8080') ?? 8080;
    final key = dotenv.env['REVERB_APP_KEY'] ?? 'p9uoyixp6y1f1m67fsk1';
    final scheme = dotenv.env['REVERB_SCHEME'] ?? 'http';

    Log.info('Reverb', 'host=$host | port=$port | key=$key | scheme=$scheme');

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
          Log.warn('Reverb', 'Connection Error: $error');
          _scheduleReconnect();
        },
      );

      _client?.lifecycleStream.listen((status) {
        _currentStatus = status.toString();
        Log.info('Reverb', 'Status: $_currentStatus');

        if (_currentStatus.toLowerCase().contains('established')) {
          _isReconnecting = false;
        }

        if (_currentStatus.toLowerCase().contains('disconnected') ||
            _currentStatus.toLowerCase().contains('connectionerror')) {
          _scheduleReconnect();
        }
      });

      _client?.eventStream.listen((event) {
        Log.info('Reverb', 'Event - Channel: ${event.channelName}, Name: ${event.name}');
      });

      await _client?.connect();
      Log.info('Reverb', 'Connected successfully');

      if (userId != null && userRole != 'admin' && _currentUserId != userId) {
        _subscribeToGlobalNotifications(userId);
      }
    } catch (e) {
      Log.error('Reverb', 'Initialization failed: $e');
      _client = null;
      _scheduleReconnect();
    } finally {
      _isConnecting = false;
    }
  }

  bool _isReconnecting = false;

  void _scheduleReconnect() {
    if (_isReconnecting) return;
    _isReconnecting = true;
    Future.delayed(const Duration(seconds: 5), () async {
      Log.warn('Reverb', 'Attempting to reconnect...');
      try {
        _client?.disconnect();
        _client = null;
        _subscriptions.clear();
        _boundEvents.clear();
        _currentUserId = null;
        await init();
      } catch (e) {
        Log.error('Reverb', 'Reconnect failed: $e');
      } finally {
        _isReconnecting = false;
      }
    });
  }

  void _subscribeToGlobalNotifications(int userId) {
    Log.info('Reverb', 'Subscribing for user $userId');
    _currentUserId = userId;

    subscribePrivate('patient.$userId', 'notification.created', (data) {
      Log.info('Reverb', 'notification.created raw: $data');

      final dynamic parsedData = _parseData(data);
      final dynamic notificationData =
          parsedData is Map && parsedData.containsKey('notification')
          ? parsedData['notification']
          : parsedData;

      if (notificationData is! Map) {
        Log.warn('Reverb', 'Invalid notification data format');
        return;
      }

      final String title = notificationData['title'] ?? 'Notifikasi Baru';
      final String message = notificationData['message'] ?? '';
      final String? type = notificationData['notification_type']?.toString();
      final String? related = notificationData['related_id']?.toString();

      String finalTitle = title;
      if (type == 'medicine_reminder') {
        finalTitle = '\u{1f48a} $title';
      } else if (type == 'meal_reminder') {
        finalTitle = '\u{1f37d}\ufe0f $title';
      }

      LocalNotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: finalTitle,
        body: message,
        payload: related,
      );
    });

    subscribePrivate('patient.$userId', 'medicine.reminder', (data) {
      Log.info('Reverb', 'medicine.reminder raw: $data');

      final dynamic payload = _parseData(data);
      final dynamic notificationData =
          payload is Map && payload.containsKey('notification')
          ? payload['notification']
          : payload;

      LocalNotificationService().showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: '\u{1f48a} ${notificationData['title'] ?? 'Waktunya Minum Obat!'}',
        body: notificationData['message'] ?? '',
        payload:
            notificationData['schedule_id']?.toString() ??
            notificationData['related_id']?.toString(),
      );
    });
  }

  dynamic _parseData(dynamic data) {
    if (data is Map) return data;
    if (data is String) {
      try {
        return jsonDecode(data);
      } catch (e) {
        Log.warn('Reverb', 'Error parsing JSON: $e');
      }
    }
    return data;
  }

  void subscribePrivate(
    String channelName,
    String eventName,
    Function(dynamic) callback,
  ) async {
    if (_client == null ||
        !_currentStatus.toLowerCase().contains('established')) {
      await init();
      if (_client == null) {
        Log.warn('Reverb', 'Cannot subscribe, client is null');
        return;
      }
    }

    // Library ternyata TIDAK otomatis menambah prefix 'private-',
    // Jadi saat memanggil privateChannel(), string-nya HARUS diawali dengan 'private-'
    String fullChannelName = channelName.startsWith('private-')
        ? channelName
        : 'private-$channelName';

    // Untuk key map _subscriptions, kita bisa gunakan nama tanpa prefix
    // agar mudah direferensikan di tempat lain
    final channelKey = channelName.startsWith('private-')
        ? channelName.replaceFirst('private-', '')
        : channelName;

    if (!_subscriptions.containsKey(channelKey)) {
      Log.info('Reverb', 'Subscribing to $fullChannelName');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';

      final apiBaseUrl =
          dotenv.env['API_BASE_URL'] ?? 'http://202.74.74.126/api';
      final authEndpoint = '$apiBaseUrl/broadcasting/auth';

      Log.info('Reverb', 'Auth endpoint: $authEndpoint');

      _subscriptions[channelKey] = _client!.privateChannel(
        fullChannelName,
        authorizationDelegate:
            EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
              authorizationEndpoint: Uri.parse(authEndpoint),
              headers: {
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
                'Content-Type': 'application/x-www-form-urlencoded',
              },
            ),
      );
      _subscriptions[channelKey].subscribe();
    }

    Log.info('Reverb', 'Binding $eventName on private-$channelKey');

    _boundEvents.putIfAbsent(channelKey, () => <String>{});
    if (_boundEvents[channelKey]!.contains(eventName)) {
      Log.info('Reverb', 'Event $eventName already bound on private-$channelKey');
      return;
    }

    _boundEvents[channelKey]!.add(eventName);

    _subscriptions[channelKey].bind(eventName).listen((event) {
      Log.info('Reverb', '[$eventName] on [private-$channelKey] \u2192 ${event.data}');
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
      Log.info('Reverb', 'Subscribing to public: $channelName');
      _subscriptions[channelName] = _client!.publicChannel(channelName);
      _subscriptions[channelName].subscribe();
    }

    Log.info('Reverb', 'Binding $eventName on $channelName');

    _boundEvents.putIfAbsent(channelName, () => <String>{});
    if (_boundEvents[channelName]!.contains(eventName)) {
      Log.info('Reverb', 'Event $eventName already bound on public-$channelName');
      return;
    }
    _boundEvents[channelName]!.add(eventName);

    _subscriptions[channelName].bind(eventName).listen((event) {
      Log.info('Reverb', '[$eventName] on [$channelName] \u2192 ${event.data}');
      if (event.data != null) {
        callback(event.data);
      }
    });
  }

  void disconnect() {
    Log.info('Reverb', 'Disconnecting');
    _client?.disconnect();
    _subscriptions.clear();
    _boundEvents.clear();
    _client = null;
    _currentUserId = null;
  }
}