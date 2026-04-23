import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('tr_TR', null);
  await AppRouter.initialize();
  
  runApp(const ProviderScope(child: FinbudApp()));
}

class FinbudApp extends StatefulWidget {
  const FinbudApp({super.key});

  @override
  State<FinbudApp> createState() => _FinbudAppState();
}

class _FinbudAppState extends State<FinbudApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkTokenOnResume();
    }
  }

  Future<void> _checkTokenOnResume() async {
    final hasToken = await AppRouter.hasValidToken();
    if (!hasToken) {
      await AppRouter.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Finbud',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}