import 'package:flutter/material.dart';
import 'package:pl2_kasir/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'customer.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://ciwziofhszkfjbtzkjob.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNpd3ppb2Zoc3prZmpidHpram9iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYxMzAzNzMsImV4cCI6MjA1MTcwNjM3M30.ULUaFzsVojz-eu8FVdIFV8KqQZuZYPRcIPkp_XrBYtk',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
