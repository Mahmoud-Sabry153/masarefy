import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'viewmodels/billing_viewmodel.dart';
import 'viewmodels/budget_viewmodel.dart';

/// Root widget: wires up the two ViewModels via [MultiProvider] so any
/// screen further down the tree can read/watch them, and applies the
/// single dark neon [AppTheme] app-wide.
///
/// Deliberately has no routes/auth/splash-screen-with-login of any kind —
/// per the app's requirements this is a fully offline, login-free tool,
/// so [HomeScreen] is the one and only entry point.
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
        home: const HomeScreen(),
      ),
    );
  }
}
