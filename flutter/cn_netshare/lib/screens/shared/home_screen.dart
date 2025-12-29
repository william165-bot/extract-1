import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../host/host_dashboard_screen.dart';
import '../receiver/receiver_dashboard_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/signin');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isHost = user.isHost;

    final List<Widget> screens = [
      isHost ? const HostDashboardScreen() : const ReceiverDashboardScreen(),
      const Center(child: Text('Connections Coming Soon')),
      const SettingsScreen(),
    ];

    final List<BottomNavigationBarItem> navItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.link),
        label: 'Connections',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_currentIndex, isHost)),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: navItems,
      ),
    );
  }

  String _getTitle(int index, bool isHost) {
    switch (index) {
      case 0:
        return isHost ? 'Host Dashboard' : 'Browse Hosts';
      case 1:
        return 'Connections';
      case 2:
        return 'Settings';
      default:
        return 'CN-NETSHARE';
    }
  }
}
