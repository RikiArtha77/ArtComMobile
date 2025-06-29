import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './services/auth_service.dart';
import './screens/home_screen.dart';
import './screens/login_screen.dart';
import './screens/message_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthService())],
      child: Consumer<AuthService>(
        builder: (ctx, auth, _) {
          return MaterialApp(
            title: 'Art Gallery',
            theme: ThemeData(
              primarySwatch: Colors.blueGrey,
              useMaterial3: true,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            debugShowCheckedModeBanner: false,
            routes: {
              '/home': (ctx) => const HomeScreen(),
              '/messages': (context) => const MessageListScreen(),
              '/login': (context) => const LoginScreen(),
            },
            home: const AuthGate(),
            onUnknownRoute: (settings) => MaterialPageRoute(
              builder: (ctx) =>
                  const Scaffold(body: Center(child: Text('Page not found'))),
            ),
          );
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    if (auth.isAuthenticated) {
      return const HomeScreen();
    }

    return FutureBuilder(
      future: auth.tryAutoLogin(),
      builder: (ctx, authResultSnapshot) {
        if (authResultSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
