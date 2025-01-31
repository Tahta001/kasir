import 'package:flutter/material.dart';
import 'package:pl2_kasir/pages/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Inisialisasi Supabase dengan URL proyek dan kunci anon (anonKey).
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
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      title: 'Login',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Tema menggunakan palet warna biru.
      ),
      home: const LoginPage(), //halaman pertama saat dijalankn
    );
  }
}
