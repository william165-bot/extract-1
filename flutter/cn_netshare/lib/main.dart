import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_config.dart';
import 'constants/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/host_provider.dart';
import 'providers/receiver_provider.dart';
import 'providers/connection_provider.dart';
import 'services/api_service.dart';
import 'services/local_storage_service.dart';
import 'services/data_tracking_service.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/shared/home_screen.dart';
import 'screens/host/host_config_screen.dart';
import 'screens/receiver/active_connection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storage = await LocalStorageService.getInstance();
  final apiService = ApiService(
    baseUrl: AppConfig.apiBaseUrl,
    storage: storage,
  );
  final dataTrackingService = DataTrackingService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            apiService: apiService,
            storage: storage,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HostProvider(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => ReceiverProvider(
            apiService: apiService,
            dataTrackingService: dataTrackingService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ConnectionProvider(apiService: apiService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/host/configure': (context) => const HostConfigScreen(),
        '/receiver/connection': (context) => const ActiveConnectionScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.vpn_lock,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              AppConfig.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'WireGuard Exit Node Sharing',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
