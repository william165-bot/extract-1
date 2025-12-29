import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/host_provider.dart';

class HostDashboardScreen extends StatefulWidget {
  const HostDashboardScreen({super.key});

  @override
  State<HostDashboardScreen> createState() => _HostDashboardScreenState();
}

class _HostDashboardScreenState extends State<HostDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hostProvider = Provider.of<HostProvider>(context, listen: false);
      hostProvider.loadConnections();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final hostProvider = Provider.of<HostProvider>(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => hostProvider.loadConnections(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.dns,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Exit Node Host',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        authProvider.user?.email ?? '',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/host/configure');
                          },
                          icon: const Icon(Icons.settings),
                          label: const Text('Configure as Host'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Connected Receivers',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => hostProvider.loadConnections(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (hostProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (hostProvider.connections.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.link_off,
                          size: 48,
                          color: Colors.white38,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No connected receivers yet',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white70,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: hostProvider.connections.length,
                  itemBuilder: (context, index) {
                    final connection = hostProvider.connections[index];
                    final dataUsage = hostProvider.getDataUsageForConnection(
                      connection.id,
                    );
                    final totalBytes = dataUsage.fold<int>(
                      0,
                      (sum, usage) => sum + usage.totalBytes,
                    );

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: connection.isActive
                              ? Colors.green
                              : Colors.grey,
                          child: Icon(
                            connection.isActive ? Icons.link : Icons.link_off,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          connection.receiverEmail ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Status: ${connection.status}\nData: ${_formatBytes(totalBytes)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.info),
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              '/connection/details',
                              arguments: connection,
                            );
                          },
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
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
