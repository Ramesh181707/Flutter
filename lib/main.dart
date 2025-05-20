import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'screens/player_list_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Parse().initialize(
    'DUY7v3Yq7ODP6gXsyTDHPFnNpzyf9HOlV3y2JZ6c',
    'https://parseapi.back4app.com/',
    clientKey: '9q86eQzifR2SqWOQBt23zAHeParWVjTDNEwrSdFx',
    autoSendSessionId: true,
    debug: true,
  );

  final user = await ParseUser.currentUser() as ParseUser?;
  final isLoggedIn = user != null;

  runApp(CricketApp(isLoggedIn: isLoggedIn));
}

class CricketApp extends StatelessWidget {
  final bool isLoggedIn;
  const CricketApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cricket Player Manager',
      theme: ThemeData(primarySwatch: Colors.green),
      home: isLoggedIn ? const PlayerListScreen() : const LoginScreen(),
    );
  }
}
