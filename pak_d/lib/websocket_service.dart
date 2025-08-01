import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  IOWebSocketChannel? _channel;
  final String url;
  Timer? _reconnectTimer;
  bool _manuallyDisconnected = false;
  bool _isConnected = false;
  late Stream _channelStream;

  WebSocketService({required this.url});

  bool get isConnected => _isConnected;

  /// เริ่มเชื่อมต่อ WebSocket พร้อมกำหนด callback รับข้อมูล
  void connect(Function(Map<String, dynamic>) onMessage) {
    _manuallyDisconnected = false;

    try {
      _channel = IOWebSocketChannel.connect(Uri.parse(url));
      _isConnected = true;
      debugPrint('✅ WebSocket connected to $url');

      // แปลง stream ให้เป็น broadcast เพื่อให้สามารถ listen ได้หลายที่
      _channelStream = _channel!.stream.asBroadcastStream();

      _channelStream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            onMessage(data);
          } catch (e) {
            debugPrint('❌ Error decoding JSON message: $e');
          }
        },
        onError: (error) {
          debugPrint("❌ WebSocket error: $error");
          _isConnected = false;
          _tryReconnect(onMessage);
        },
        onDone: () {
          debugPrint("🛑 WebSocket connection closed");
          _isConnected = false;
          if (!_manuallyDisconnected) {
            _tryReconnect(onMessage);
          }
        },
      );
    } catch (e) {
      debugPrint("❌ Error connecting WebSocket: $e");
      _isConnected = false;
      _tryReconnect(onMessage);
    }
  }

  void _tryReconnect(Function(Map<String, dynamic>) onMessage) {
    if (_reconnectTimer != null && _reconnectTimer!.isActive) return;

    debugPrint("🔄 Trying to reconnect WebSocket in 3 seconds...");
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (!_manuallyDisconnected) {
        connect(onMessage);
      }
    });
  }

  /// ส่งรูปภาพ (File) ผ่าน WebSocket และรอผลลัพธ์ตอบกลับ (JSON)
  Future<Map<String, dynamic>?> sendImageAndWait(File imageFile) async {
    if (_channel == null || !_isConnected) {
      debugPrint("❌ WebSocket is not connected");
      return {
        "status": "error",
        "message": "WebSocket is not connected",
      };
    }

    try {
      final completer = Completer<Map<String, dynamic>?>();
      late StreamSubscription sub;

      // ใช้ broadcast stream ที่ตั้งไว้ตอน connect
      sub = _channelStream.listen((message) {
        try {
          final data = jsonDecode(message);
          if (!completer.isCompleted) {
            completer.complete(data);
          }
          sub.cancel();
        } catch (e) {
          debugPrint("❌ Error decoding response JSON: $e");
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
          sub.cancel();
        }
      });

      // อ่านไฟล์ภาพเป็นไบต์
      final bytes = await imageFile.readAsBytes();

      // ส่งไบต์รูปภาพผ่าน WebSocket
      _channel!.sink.add(bytes);
      debugPrint("📤 Sent image with ${bytes.length} bytes");

      // รอผลลัพธ์ตอบกลับ
      return await completer.future;
    } catch (e) {
      debugPrint("❌ Error in sendImageAndWait: $e");
      return {
        "status": "error",
        "message": e.toString(),
      };
    }
  }

  /// ตัดการเชื่อมต่อ WebSocket
  void disconnect() {
    _manuallyDisconnected = true;
    _reconnectTimer?.cancel();
    _channel?.sink.close(status.goingAway);
    _channel = null;
    _isConnected = false;
    debugPrint('🛑 WebSocket manually disconnected');
  }
}
