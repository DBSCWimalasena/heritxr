import 'package:flutter/material.dart';

// AUTH
import 'sign_in_page.dart';
import 'sign_up_page.dart';

// VISITOR FLOW
import 'visitor_list_page.dart';
import 'add_visitor_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tourism Admin',

      home: const SignInPage(),

      routes: {
        '/sign-in': (context) => const SignInPage(),
        '/sign-up': (context) => const SignUpPage(),

        '/visitor-list': (context) => const VisitorListPage(),
        '/add-visitor': (context) => const AddVisitorPage(),
      },
    );
  }
}
