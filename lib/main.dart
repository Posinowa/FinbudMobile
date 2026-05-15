import 'package:finbud_app/core/constants/app_color.dart';
import 'package:finbud_app/core/network/connectivity_provider.dart';
import 'package:finbud_app/core/network/maintenance_service.dart';
import 'package:finbud_app/core/shared/widgets/maintenance_screen.dart';
import 'package:finbud_app/core/shared/widgets/no_internet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('tr_TR', null);

  // AppRouter.initialize() burada beklenmeden runApp hemen çağrılıyor.
  // Başlatma işlemi Flutter içinde arka planda tamamlanıyor.
  runApp(const ProviderScope(child: FinbudApp()));
}

class FinbudApp extends ConsumerStatefulWidget {
  const FinbudApp({super.key});

  @override
  ConsumerState<FinbudApp> createState() => _FinbudAppState();
}

class _FinbudAppState extends ConsumerState<FinbudApp> with WidgetsBindingObserver {
  late final Future<_InitResult> _initFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initFuture = _initialize();
  }

  Future<_InitResult> _initialize() async {
    final maintenance = await MaintenanceService.isMaintenance();
    if (!maintenance) {
      await AppRouter.initialize();
    }
    return _InitResult(isMaintenance: maintenance);
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
    final isConnected = ref.watch(connectivityProvider);

    return FutureBuilder<_InitResult>(
      future: _initFuture,
      builder: (context, snapshot) {
        // Başlatma tamamlanmadıysa boş ekran göster
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: AppColors.background,
              body: SizedBox.shrink(),
            ),
          );
        }

        // Bakım modu aktifse bakım ekranı göster
        if (snapshot.data?.isMaintenance == true) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MaintenanceScreen(),
          );
        }

        // İnternet yoksa no internet ekranı göster
        if (!isConnected) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: NoInternetScreen(),
          );
        }

        // Router hazır ve internet var — normal uygulama
        return MaterialApp.router(
          title: 'Finbud',
          debugShowCheckedModeBanner: false,
          locale: const Locale('tr', 'TR'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('tr', 'TR'),
            Locale('en', 'US'),
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}

class _InitResult {
  final bool isMaintenance;
  const _InitResult({required this.isMaintenance});
}
