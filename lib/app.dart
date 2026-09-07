import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash/splash_screen.dart';
import 'viewmodels/billing_viewmodel.dart';
import 'viewmodels/budget_viewmodel.dart';

/// Root widget: wires up the two ViewModels via [MultiProvider] so any
/// screen further down the tree can read/watch them, and applies the
/// single dark neon [AppTheme] app-wide.
///
/// There's deliberately no auth/login screen of any kind — per the app's
/// requirements this is a fully offline, login-free tool. [SplashScreen]
/// is shown first purely for the branded launch animation (all storage
/// is already initialized in main.dart before this widget ever builds),
/// then hands off to [HomeScreen].
class MasarefyApp extends StatelessWidget {
  const MasarefyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BillingViewModel()),
        ChangeNotifierProvider(create: (_) => BudgetViewModel()),
      ],
      child: MaterialApp(
        title: 'Masarefy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: const SplashScreen(),
      ),
    );
  }
}
