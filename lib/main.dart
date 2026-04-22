import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'pages/splash_screen.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';
import 'pages/main_screen.dart';

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

return MaterialApp(
  debugShowCheckedModeBanner: false,

  home: const SplashScreen(),

  routes: {
    '/login': (context) => const LoginScreen(),
    '/register': (context) => const RegisterScreen(),
    '/home_screen': (context) => const MainScreen(),
  },
);

}
}