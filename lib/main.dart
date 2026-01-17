import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/constants/app_routes.dart';
import 'core/constants/app_route_generator.dart';

// 👉 IMPORT AUTH PROVIDER KAMU
import 'presentation/providers/auth_provider.dart';

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
        // 🔥 DAFTARKAN AUTH PROVIDER
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'E-Healty',

        // 🔥 PUSAT NAVIGASI KAMU (SUDAH BENAR)
        initialRoute: AppRoutes.login,
        onGenerateRoute: AppRouteGenerator.generate,

        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
      ),
    );
  }
}
