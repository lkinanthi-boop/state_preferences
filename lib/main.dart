import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/user_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider()..loadUser(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          title: 'State & Preferences',
          debugShowCheckedModeBanner: false,

          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.deepPurple,
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.deepPurple,
          ),

          themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

          home: const HomeScreen(),
        );
      },
    );
  }
}
