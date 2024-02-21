import 'package:flutter/material.dart';
import 'package:lab3/main.dart';
import 'package:provider/provider.dart';

import 'authentication.dart';

class AuthenticationHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to MIS2023'),
        backgroundColor: Colors.orange, // Updated app bar color
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSignInButton(context),
          const SizedBox(height: 16.0),
          _buildSignUpButton(context),
        ],
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignInPage(),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.deepPurple, // Set the button background color
        onPrimary: Colors.white, // Set the text color
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(20.0), // Set the button border radius
        ),
      ),
      child: const Text('Sign In'),
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpPage(),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.deepOrange, // Set the button background color
        onPrimary: Colors.white, // Set the text color
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(20.0), // Set the button border radius
        ),
      ),
      child: const Text('Sign Up'),
    );
  }
}

class SignInPage extends StatelessWidget {
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController userPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildEmailField(),
          const SizedBox(height: 16.0),
          _buildPasswordField(),
          const SizedBox(height: 16.0),
          _buildSignInButton(context),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: userEmailController,
      decoration: InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: userPasswordController,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      obscureText: true,
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final email = userEmailController.text.trim();
        final password = userPasswordController.text.trim();
        final authService = Provider.of<AuthService>(context, listen: false);
        final signInResult =
            await authService.signInWithEmailAndPassword(email, password);

        if (signInResult == AuthResultStatus.successful) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ExamHomePage(),
            ),
          );
        } else {
          // Show an error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(signInResult.toString()),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.blue, // Set the button color
      ),
      child: const Text(
        'Sign In',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}

class SignUpPage extends StatelessWidget {
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController userPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildEmailField(),
          SizedBox(height: 16.0),
          _buildPasswordField(),
          SizedBox(height: 16.0),
          _buildSignUpButton(context),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: userEmailController,
      decoration: InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      style: TextStyle(
        fontSize: 16.0,
        color: Colors.black,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: userPasswordController,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      obscureText: true,
      style: TextStyle(
        fontSize: 16.0,
        color: Colors.black,
      ),
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final email = userEmailController.text.trim();
        final password = userPasswordController.text.trim();
        final authService = Provider.of<AuthService>(context, listen: false);
        final signUpResult =
            await authService.signUpWithEmailAndPassword(email, password);

        if (signUpResult == AuthResultStatus.successful) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ExamHomePage(),
            ),
          );
        } else {
          // Show an error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(signUpResult.toString()),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.blue,
        onPrimary: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Text(
        'Sign Up',
        style: TextStyle(
          fontSize: 16.0,
        ),
      ),
    );
  }
}
