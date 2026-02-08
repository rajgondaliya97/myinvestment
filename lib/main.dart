  import 'package:flutter/material.dart';
  import 'package:flutter_screenutil/flutter_screenutil.dart';
  import 'package:myinvestment/res/services/MetaMaskConnectScreen.dart';
  import 'package:myinvestment/res/services/ReownWalletService.dart';
  import 'package:myinvestment/res/services/WalletDashboardScreen.dart';
  import 'package:myinvestment/utils/app_config.dart';
  import 'package:myinvestment/res/database/local_database.dart';
  import 'package:myinvestment/res/dependency_locator.dart';
  import 'package:myinvestment/utils/app_color.dart';
  import 'package:myinvestment/view/auth/screen/auth_wrapper.dart';
  import 'package:myinvestment/view/informetiv_screens/InformetiveHome_screen.dart';
  import 'package:myinvestment/view/informetiv_screens/app_info.dart';
  import 'package:myinvestment/view_model/deposit_provider.dart';
  import 'package:myinvestment/view_model/investment_controller.dart';
  import 'package:myinvestment/view_model/pan_provider.dart';
  import 'package:myinvestment/view_model/referral_provider.dart';
  import 'package:myinvestment/view_model/transaction_controller.dart';
  import 'package:myinvestment/view_model/user_plan_provoder.dart';
  import 'package:myinvestment/view_model/wallet_controller.dart';
  import 'package:provider/provider.dart';
  import 'view_model/auth_provider.dart';
  import 'view_model/home_provider.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      // Initialize AppConfig FIRST
      debugPrint('🔧 Initializing AppConfig...');
      await AppConfig.init();
      debugPrint('✅ AppConfig initialized');

      // Initialize Local Database
      debugPrint('🔧 Initializing Local Database...');
      await AppLocalData.init();
      debugPrint('✅ Local Database initialized');

      // Initialize Dependencies
      debugPrint('🔧 Initializing Dependencies...');
      await DependencyLocator().init();
      debugPrint('✅ Dependencies initialized');

      // Create ReownWalletService instance
      debugPrint('🔧 Creating ReownWalletService...');
      final reownWalletService = ReownWalletService();
      debugPrint('✅ ReownWalletService created');

      debugPrint('✅ All services initialized successfully');

      runApp(MyApp(reownWalletService: reownWalletService));
    } catch (e, stackTrace) {
      debugPrint('❌ FATAL ERROR during initialization: $e');
      debugPrint('Stack trace: $stackTrace');

      runApp(MyApp(initializationError: e.toString()));
    }
  }

  class MyApp extends StatelessWidget {
    final ReownWalletService? reownWalletService;
    final String? initializationError;

    const MyApp({
      Key? key,
      this.reownWalletService,
      this.initializationError,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthController(
              authRepository: DependencyLocator().authRepository,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => HomeProvider(
              homeRepository: DependencyLocator().homeRepository,
            ),
          ),
          ChangeNotifierProvider(create: (_) => InvestmentProvider()),
          ChangeNotifierProvider(
            create: (_) => DepositProvider(
              planRepository: DependencyLocator().planRepository,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) =>
                PlanProvider(planRepository: DependencyLocator().planRepository),
          ),
          ChangeNotifierProvider(
            create: (_) => UserPlanController(
              planRepository: DependencyLocator().planRepository,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => WalletController(
              walletRepository: DependencyLocator().walletRepository,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => TransactionController(
              transactionRepository: DependencyLocator().transactionRepository,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => ReferralController(
              referralRepository: DependencyLocator().referralRepository,
            ),
          ),
          // ✅ Provide ReownWalletService
          ChangeNotifierProvider.value(
            value: reownWalletService ?? ReownWalletService(),
          ),
        ],
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              // ✅ CRITICAL: Set navigator key for ReownWalletService
              navigatorKey: NavigatorKey.navKey,
              title: 'Investment App',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primaryColor: AppColor.primaryColor,
                scaffoldBackgroundColor: Colors.black,
                brightness: Brightness.dark,
                fontFamily: 'Inter',
              ),
              // ✅ Show error screen if initialization failed
              home: /*initializationError != null
                  ? InitializationErrorScreen(error: initializationError!)
                  : const ReownWalletInitializer()*/AppInfoScreen(),
              // ✅ Define routes for wallet screens
              routes: {
                '/connect': (context) => const MetaMaskConnectScreen(),
                '/dashboard': (context) => const WalletDashboardScreen(),
              },
            );
          },
        ),
      );
    }
  }

  // ✅ Initialize Reown Wallet and check connection status
  class ReownWalletInitializer extends StatefulWidget {
    const ReownWalletInitializer({Key? key}) : super(key: key);

    @override
    State<ReownWalletInitializer> createState() => _ReownWalletInitializerState();
  }

  class _ReownWalletInitializerState extends State<ReownWalletInitializer> {
    bool _isInitializing = true;
    String? _error;

    @override
    void initState() {
      super.initState();
      _initializeWallet();
    }

    Future<void> _initializeWallet() async {
      try {
        final walletService = Provider.of<ReownWalletService>(context, listen: false);

        debugPrint('🔧 Initializing Reown Wallet service...');
        await walletService.initialize();
        debugPrint('✅ Reown Wallet service initialized');

        // Small delay to ensure everything is ready
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        // Check if wallet is already connected (from saved session)
        if (walletService.isConnected) {
          debugPrint('✅ Found saved wallet session');
          debugPrint('📍 Address: ${walletService.address}');
          debugPrint('🌐 Network: ${walletService.currentNetwork}');

          // Navigate to AuthWrapper (which will show home screen)
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => AuthWrapper(),
            ),
          );
        } else {
          debugPrint('ℹ️ No saved wallet session found');

          // Navigate to AuthWrapper (wallet connection will be prompted from home)
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => AuthWrapper(),
            ),
          );
        }
      } catch (e, stackTrace) {
        debugPrint('❌ Wallet initialization failed: $e');
        debugPrint('Stack trace: $stackTrace');

        if (mounted) {
          setState(() {
            _error = e.toString();
            _isInitializing = false;
          });
        }
      }
    }

    @override
    Widget build(BuildContext context) {
      if (_isInitializing) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColor.primaryColor),
                SizedBox(height: 24.h),
                Text(
                  'Initializing Wallet Service...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Please wait',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      if (_error != null) {
        return InitializationErrorScreen(error: _error!);
      }

      // This should not be reached as we navigate away
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: AppColor.primaryColor),
        ),
      );
    }
  }

  class InitializationErrorScreen extends StatelessWidget {
    final String error;

    const InitializationErrorScreen({Key? key, required this.error})
        : super(key: key);

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 80.sp,
                ),
                SizedBox(height: 24.h),
                Text(
                  'Initialization Failed',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 32.h),
                ElevatedButton.icon(
                  onPressed: () {
                    // Restart app by navigating to initializer
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const ReownWalletInitializer(),
                      ),
                    );
                  },
                  icon: Icon(Icons.refresh, size: 20.sp),
                  label: Text(
                    'Retry',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.w,
                      vertical: 16.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }