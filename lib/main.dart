import 'package:flutter/material.dart';
import 'package:Likegram/features/home/data/user.dart';
import 'package:Likegram/features/home/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/home/screens/home_screen.dart';
import 'features/home/screens/lookup_friend_screen.dart';
import 'features/home/screens/post_screen.dart';
import 'features/home/screens/profile_screen.dart';
import 'features/home/screens/register_screen.dart';
import 'utils/theme/theme_state.dart';
import 'utils/theme/themes.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  AuthService au = AuthService();
  au.getUserInfo();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    return isLoggedIn;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, value, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          themeMode: value.themeMode ? ThemeMode.dark : ThemeMode.light,
          darkTheme: darkTheme,
          home: FutureBuilder<bool>(
              future: checkLoginStatus(),
              builder: (context, snapshot){
                if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData && snapshot.data == true) {
                return const HomeScreen();
                } else {
                  return const LoginScreen();
                }
              }),
          routes: {
            'login': (context) => LoginScreen(),
            'register': (context) => RegisterScreen(),
            'home': (context) => HomeScreen(),
            'profile': (context) => ProfileScreen(),
            'post': (context) => PostScreen(),
            'contact': (context) => ContactsScreen(),
          },
        );
      },
    );
  }
}
