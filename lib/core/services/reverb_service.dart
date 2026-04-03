import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ReverbService {
  static final ReverbService _instance = ReverbService._internal();
  factory ReverbService() => _instance;
  ReverbService._internal();

  PusherChannelsClient? _client;
  final Map<String, dynamic> _subscriptions = {};

  Future<void> init() async {
    if (_client != null) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      if (kDebugMode)
        print('ReverbService: No access token found, skipping init');
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
        if (kDebugMode)
          print('ReverbService: Connection status changed: $status');
      });

      _client?.eventStream.listen((event) {
        if (kDebugMode)
          print(
            'ReverbService: Incoming Event - Channel: ${event.channelName}, Name: ${event.name}',
          );
      });

      await _client?.connect();
      if (kDebugMode) print('ReverbService: Connected successfully');
    } catch (e) {
      if (kDebugMode) print('ReverbService: Initialization failed: $e');
    }
  }

  void subscribePrivate(
    String channelName,
    String eventName,
    Function(dynamic) callback,
  ) async {
    if (_client == null) {
      if (kDebugMode)
        print(
          'ReverbService: Client not initialized, cannot subscribe to $channelName',
        );
      return;
    }

    final channelKey = "private-$channelName";
    if (!_subscriptions.containsKey(channelKey)) {
      if (kDebugMode)
        print('ReverbService: Subscribing to private channel: $channelKey');
      final baseUrl = dotenv.env['API_BASE_URL']?.replaceAll('/api', '') ?? '';
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

    if (kDebugMode)
      print('ReverbService: Binding event $eventName to channel $channelKey');
    _subscriptions[channelKey].bind(eventName).listen((event) {
      if (kDebugMode)
        print(
          'ReverbService: Event $eventName received on $channelKey - Data: ${event.data}',
        );
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
      if (kDebugMode)
        print('ReverbService: Subscribing to public channel: $channelName');
      _subscriptions[channelName] = _client!.publicChannel(channelName);
      _subscriptions[channelName].subscribe();
    }

    if (kDebugMode)
      print('ReverbService: Binding event $eventName to channel $channelName');
    _subscriptions[channelName].bind(eventName).listen((event) {
      if (kDebugMode)
        print(
          'ReverbService: Event $eventName received on $channelName - Data: ${event.data}',
        );
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
