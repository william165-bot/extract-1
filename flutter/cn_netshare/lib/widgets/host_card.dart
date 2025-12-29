import 'package:flutter/material.dart';
import '../models/host.dart';

class HostCard extends StatelessWidget {
  final Host host;
  final VoidCallback? onConnect;
  final bool isConnecting;

  const HostCard({
    super.key,
    required this.host,
    this.onConnect,
    this.isConnecting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: host.isOnline ? Colors.green : Colors.grey,
                  child: Icon(
                    host.isOnline ? Icons.dns : Icons.dns_outlined,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        host.email,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: host.isOnline ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            host.isOnline ? 'Online' : 'Offline',
                            style: TextStyle(
                              color: host.isOnline ? Colors.green : Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: host.isOnline && !isConnecting ? onConnect : null,
                icon: isConnecting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.link),
                label: Text(isConnecting ? 'Connecting...' : 'Request Connection'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
