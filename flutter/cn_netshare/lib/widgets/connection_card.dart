import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/connection.dart';

class ConnectionCard extends StatelessWidget {
  final Connection connection;
  final VoidCallback? onTap;

  const ConnectionCard({
    super.key,
    required this.connection,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(),
          child: Icon(
            _getStatusIcon(),
            color: Colors.white,
          ),
        ),
        title: Text(
          connection.receiverEmail ?? connection.hostEmail ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Status: ${connection.status}\nCreated: ${_formatDate(connection.createdAt)}',
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Theme.of(context).colorScheme.primary,
        ),
        isThreeLine: true,
      ),
    );
  }

  Color _getStatusColor() {
    if (connection.isActive) return Colors.green;
    if (connection.isPending) return Colors.orange;
    return Colors.red;
  }

  IconData _getStatusIcon() {
    if (connection.isActive) return Icons.link;
    if (connection.isPending) return Icons.pending;
    return Icons.link_off;
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }
}
