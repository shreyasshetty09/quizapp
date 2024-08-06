import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'admin_login_page.dart';
import 'admin_register_page.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'admin_dashboard_page.dart';
import 'add_quiz_page.dart';
import 'view_quiz_page.dart';
import 'quiz_join_page.dart';
import 'quiz_participation_page.dart';
import 'quiz_detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quizzy Apti',
      theme: ThemeData(
        primaryColor: Colors.teal,
        textTheme: TextTheme(
          displayLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16.0),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.teal,
          textTheme: ButtonTextTheme.primary,
        ), colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(secondary: Colors.tealAccent),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/admin_login': (context) => AdminLoginPage(),
        '/admin_register': (context) => AdminRegisterPage(),
        '/admin_dashboard': (context) => AdminDashboardPage(),
        '/add_quiz': (context) => AddQuizPage(),
        '/view_quiz': (context) => ViewQuizPage(),
        '/quiz_join': (context) => QuizJoinPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/quiz_participation') {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (context) {
              return QuizParticipationPage(
                  quizId: args['quizId']!, quizLink: args['quizLink']!);
            },
          );
        } else if (settings.name == '/quiz_detail') {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (context) {
              return QuizDetailPage(quizId: args['quizId']!);
            },
          );
        }
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(Duration(seconds: 3), () {});
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Quizzy Apti',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
