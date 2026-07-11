import 'package:e_healty/presentation/providers/aktivitas_sehat_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/constants/app_routes.dart';
import 'core/constants/app_route_generator.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/tips_kesehatan_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => TipsKesehatanProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => AktivitasSehatProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'E-Healty',

        initialRoute: AppRoutes.login,
        onGenerateRoute: AppRouteGenerator.generate,

        theme: AppTheme.lightTheme,
      ),
    );
  }
}
