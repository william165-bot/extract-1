import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/receiver_provider.dart';
import '../../widgets/host_card.dart';
import '../../widgets/loading_indicator.dart';

class ReceiverDashboardScreen extends StatefulWidget {
  const ReceiverDashboardScreen({super.key});

  @override
  State<ReceiverDashboardScreen> createState() => _ReceiverDashboardScreenState();
}

class _ReceiverDashboardScreenState extends State<ReceiverDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final receiverProvider = Provider.of<ReceiverProvider>(context, listen: false);
      receiverProvider.loadAvailableHosts();
      receiverProvider.loadActiveConnection();
    });
  }

  Future<void> _handleConnect(int hostUserId) async {
    final receiverProvider = Provider.of<ReceiverProvider>(context, listen: false);
    final success = await receiverProvider.requestConnection(hostUserId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection request sent successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushNamed('/receiver/connection');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              receiverProvider.errorMessage ?? 'Failed to connect',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final receiverProvider = Provider.of<ReceiverProvider>(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => receiverProvider.loadAvailableHosts(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (receiverProvider.isConnected)
                Card(
                  color: Colors.green.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Connected',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                'Host: ${receiverProvider.activeConnection?.hostEmail ?? "Unknown"}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/receiver/connection');
                          },
                          child: const Text('View'),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Hosts',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => receiverProvider.loadAvailableHosts(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (receiverProvider.isLoading && receiverProvider.availableHosts.isEmpty)
                const LoadingIndicator(message: 'Loading hosts...')
              else if (receiverProvider.availableHosts.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.dns_outlined,
                          size: 48,
                          color: Colors.white38,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hosts available',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white70,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pull down to refresh',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white54,
                              ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: receiverProvider.availableHosts.length,
                  itemBuilder: (context, index) {
                    final host = receiverProvider.availableHosts[index];
                    return HostCard(
                      host: host,
                      onConnect: () => _handleConnect(host.userId),
                      isConnecting: receiverProvider.isLoading,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
