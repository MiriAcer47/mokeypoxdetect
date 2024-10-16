import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'login_form.dart';


  class LoginScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(

      appBar: AppBar(
        title: Text('User Login', style: TextStyle(color:colorScheme.onPrimary)),
        backgroundColor: colorScheme.primary,

      ),
      body: SingleChildScrollView(

        child: Center(

          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/img22_loginscreen.png',
                  height: 200.0,
                ),

                SizedBox(height: 20.0),
                 Text(
                  'Enter your login and PIN',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32.0),
                LoginForm(),
                SizedBox(height: 16.0),
                HaveAccountCheck(
                  login: true,
                  press: (){
                  Navigator.push(
                   context,
                   MaterialPageRoute(
                    builder: (context) =>SignupScreen(),
                    ),
                  );
                 },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

