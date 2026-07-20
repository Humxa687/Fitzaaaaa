import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeMediaController {
  static const MethodChannel _channel = MethodChannel('com.example.fitza/media_control');

  static Future<void> playPause() async {
    try {
      await _channel.invokeMethod('play_pause');
    } on PlatformException catch (e) {
      debugPrint("Failed to send play_pause: '${e.message}'.");
    }
  }

  static Future<void> next() async {
    try {
      await _channel.invokeMethod('next');
    } on PlatformException catch (e) {
      debugPrint("Failed to send next: '${e.message}'.");
    }
  }

  static Future<void> previous() async {
    try {
      await _channel.invokeMethod('previous');
    } on PlatformException catch (e) {
      debugPrint("Failed to send previous: '${e.message}'.");
    }
  }
}
