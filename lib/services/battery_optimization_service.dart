import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Provider for battery optimization service
final batteryOptimizationServiceProvider = Provider<BatteryOptimizationService>((ref) {
  return BatteryOptimizationService();
});

/// Service for handling battery optimization settings
class BatteryOptimizationService {

  /// Check if battery optimization is disabled for this app
  Future<bool> isBatteryOptimizationDisabled() async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('Error checking battery optimization: $e');
      return false;
    }
  }

  /// Request to disable battery optimization
  Future<bool> requestDisableBatteryOptimization() async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting battery optimization exemption: $e');
      return false;
    }
  }

  /// Open battery optimization settings
  Future<void> openBatteryOptimizationSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      debugPrint('Error opening settings: $e');
    }
  }

  /// Show educational dialog about why battery optimization exemption is needed
  Future<bool> showBatteryOptimizationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.battery_alert, color: Colors.orange),
            SizedBox(width: 8),
            Text('Battery Settings'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'For reliable GPS tracking during your tour, we need to run in the background.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Without this permission:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _BulletPoint('GPS may stop working when screen is off'),
            _BulletPoint('You might miss audio at tour stops'),
            _BulletPoint('Tour progress may not be saved'),
            SizedBox(height: 16),
            Text(
              'We only track location during active tours and stop immediately when you end the tour.',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not Now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Allow'),
          ),
        ],
      ),
    );

    if (result == true) {
      return await requestDisableBatteryOptimization();
    }
    return false;
  }

  /// Check and request battery optimization with educational dialog
  Future<bool> ensureBatteryOptimizationDisabled(BuildContext context) async {
    final isDisabled = await isBatteryOptimizationDisabled();
    if (isDisabled) return true;

    return await showBatteryOptimizationDialog(context);
  }

  /// Show dialog for devices with aggressive battery optimization (Samsung, Xiaomi, etc.)
  Future<void> showAggressiveOptimizationWarning(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.amber),
            SizedBox(width: 8),
            Text('Additional Setup'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your device may have aggressive power saving that can stop GPS tracking.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'To ensure reliable tour tracking:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _NumberedPoint(1, 'Open your device Settings'),
            _NumberedPoint(2, 'Find "Battery" or "Power"'),
            _NumberedPoint(3, 'Add this app to "Unrestricted" or "Don\'t optimize"'),
            SizedBox(height: 16),
            Text(
              'This setting varies by device manufacturer.',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK, Got It'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              openBatteryOptimizationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Detect if device is from a manufacturer with aggressive battery optimization
  /// Note: This requires device_info_plus package for actual implementation
  /// Returns false by default - implement with device_info_plus if needed
  bool isAggressiveDeviceManufacturer() {
    // Known aggressive manufacturers: samsung, xiaomi, huawei, oppo, vivo, oneplus, realme
    // This would need device_info_plus package to get actual manufacturer
    // For now, return false - can be implemented later if needed
    return false;
  }
}

/// Helper widget for bullet points
class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

/// Helper widget for numbered points
class _NumberedPoint extends StatelessWidget {
  final int number;
  final String text;

  const _NumberedPoint(this.number, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$number. ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
