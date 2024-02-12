import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:lab3/screen.dart';
import 'package:lab3/list.dart';
import 'package:lab3/logging.dart';
import 'package:provider/provider.dart';
import 'foptions.dart';
import 'authentication.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  runApp(ExamApp());
}

class ExamApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthService>(
      create: (context) => AuthService(),
      child: MaterialApp(
        title: 'MIS2023/24 app',
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Arial',
        ),
        home: AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        return snapshot.connectionState == ConnectionState.active
            ? _buildAuthScreen(context, snapshot.data)
            : _buildLoadingScreen();
      },
    );
  }

  Widget _buildAuthScreen(BuildContext context, User? user) {
    return user == null ? AuthenticationHomePage() : ExamHomePage();
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class ExamHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Scaffold(
      appBar: AppAppBar(authService: authService),
      body: ExamPage(),
    );
  }
}

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AuthService authService;

  const AppAppBar({required this.authService});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('MIS2023/24 app'),
      actions: [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddExamPage()),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () async {
            await authService.signOut();
          },
        ),
      ],
    );
  }
}
