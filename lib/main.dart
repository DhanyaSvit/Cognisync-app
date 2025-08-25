import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_gate.dart' as auth;
// import 'screens/home_screen.dart';
import 'screens/dashboard.dart';
import 'screens/goals_page.dart';
import 'screens/games_page.dart';
import 'screens/journal_list_page.dart';
import 'screens/add_journal_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CogniSync',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/', 
      routes: {
        '/': (context) => const SplashScreen(),
        '/auth': (context) => const auth.AuthGate(),
        '/home': (context) => const DashboardPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/goals': (context) => const GoalsPage(),
        '/games': (context) => const GamesPage(),
        '/journal': (context) => const JournalListPage(),
        '/add_journal': (context) => const AddJournalPage(),
      },
    );
  }
}
