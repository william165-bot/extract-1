import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/receiver_provider.dart';
import '../../models/wireguard_config.dart';
import '../../services/wireguard_integration_service.dart';

class ActiveConnectionScreen extends StatefulWidget {
  const ActiveConnectionScreen({super.key});

  @override
  State<ActiveConnectionScreen> createState() => _ActiveConnectionScreenState();
}

class _ActiveConnectionScreenState extends State<ActiveConnectionScreen> {
  bool _showConfig = false;

  Future<void> _copyConfig(String config) async {
    await Clipboard.setData(ClipboardData(text: config));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuration copied to clipboard'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _handleDisconnect() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect'),
        content: const Text('Are you sure you want to disconnect from this host?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final receiverProvider = Provider.of<ReceiverProvider>(context, listen: false);
      final success = await receiverProvider.disconnectConnection();

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Disconnected successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                receiverProvider.errorMessage ?? 'Failed to disconnect',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final receiverProvider = Provider.of<ReceiverProvider>(context);
    final connection = receiverProvider.activeConnection;

    if (connection == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Active Connection'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.link_off,
                size: 64,
                color: Colors.white38,
              ),
              const SizedBox(height: 16),
              const Text('No active connection'),
            ],
          ),
        ),
      );
    }

    final configString = connection.wireguardConfig ?? '';
    WireGuardConfig? config;
    
    if (configString.isNotEmpty) {
      try {
        config = WireGuardConfig.fromString(configString);
      } catch (e) {
        print('Failed to parse WireGuard config: $e');
      }
    }

    final localUsage = receiverProvider.localDataUsage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Connection'),
        actions: [
          IconButton(
            icon: const Icon(Icons.link_off),
            onPressed: _handleDisconnect,
            tooltip: 'Disconnect',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.green,
                      child: const Icon(
                        Icons.link,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Connected to',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      connection.hostEmail ?? 'Unknown Host',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        connection.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Usage',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _buildDataRow('Sent', _formatBytes(localUsage['bytes_sent'] as int)),
                    const Divider(),
                    _buildDataRow('Received', _formatBytes(localUsage['bytes_received'] as int)),
                    const Divider(),
                    _buildDataRow('Total', _formatBytes(localUsage['total_bytes'] as int)),
                  ],
                ),
              ),
            ),
            if (config != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'WireGuard Configuration',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: QrImageView(
                          data: config.toConfigString(),
                          version: QrVersions.auto,
                          size: 200.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _copyConfig(config!.toConfigString()),
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy Configuration'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showConfig = !_showConfig;
                          });
                        },
                        icon: Icon(_showConfig ? Icons.visibility_off : Icons.visibility),
                        label: Text(_showConfig ? 'Hide Config' : 'Show Config'),
                      ),
                      if (_showConfig) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            config.toConfigString(),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Card(
              color: Colors.red.withOpacity(0.1),
              child: InkWell(
                onTap: _handleDisconnect,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.link_off, color: Colors.red),
                      const SizedBox(width: 12),
                      const Text(
                        'Disconnect from Host',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
