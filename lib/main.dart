import 'package:chat_app/models/theme.dart';
import 'package:chat_app/screens/auth_ui.dart';
import 'package:chat_app/screens/home.dart';
import 'package:chat_app/screens/splashUi.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  //firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_API_KEY']!,
  );
  runApp(App());
}

class App extends StatelessWidget {
  App({super.key});
  final session = Supabase.instance.client.auth.currentSession;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterChat',
      theme: chatTheme,
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Splashui();
          }

          if (snapshot.hasData) {
            final event = snapshot.data!.event;

            if (event == AuthChangeEvent.signedIn) {
              return Home();
            } else if (event == AuthChangeEvent.signedOut) {
              return AuthUi();
            }
          }

          return session != null ? Home() : AuthUi();
        },
      ),
    );
  }
}
