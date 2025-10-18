
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart' as provider;

import 'app_service.dart';
import 'chat_page.dart';
import 'home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mvhldwmcuhdjbkgsgyib.supabase.co', // Project URL
    anonKey:'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im12aGxkd21jdWhkamJrZ3NneWliIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY1NTc4ODIsImV4cCI6MjA3MjEzMzg4Mn0.zxqJ9CuzW3Bt8tquKBHBopgYUVYSEw-kDWqd9RdvxnI', // Anon public key
  );

  runApp(
    provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider<AppService>(
          create: (_) => AppService(),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const HomePage(),
      routes: {
        '/chat': (_) => const ChatPage(),
      },
    );
  }
}
