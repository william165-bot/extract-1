import 'package:flutter/services.dart';
import '../models/wireguard_config.dart';

class WireGuardIntegrationService {
  static const _platform = MethodChannel('com.cnnetshare.app/wireguard');

  Future<bool> openInWireGuardApp(String configString) async {
    try {
      final result = await _platform.invokeMethod('openWireGuard', {
        'config': configString,
      });
      return result as bool;
    } on PlatformException catch (e) {
      print('Failed to open WireGuard app: ${e.message}');
      return false;
    }
  }

  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  Future<bool> shareConfig(WireGuardConfig config, String fileName) async {
    try {
      final configString = config.toConfigString();
      final result = await _platform.invokeMethod('shareConfig', {
        'config': configString,
        'fileName': fileName,
      });
      return result as bool;
    } on PlatformException catch (e) {
      print('Failed to share config: ${e.message}');
      return false;
    }
  }

  String generateQRCodeData(WireGuardConfig config) {
    return config.toConfigString();
  }
}
