import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk input fields
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Dummy username dan password yang benar
  final String correctUsername = 'tahta';
  final String correctPassword = '123';

  // Kunci enkripsi
  final String encryptionKey = '1234567890123456';

  // Fungsi untuk mengenkripsi password
  String encryptPassword(String password) {
    final key = encrypt.Key.fromUtf8(encryptionKey);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    return encrypter.encrypt(password, iv: iv).base64;
  }

  // Fungsi untuk mendekripsi password
  String decryptPassword(String encryptedPassword) {
    final key = encrypt.Key.fromUtf8(encryptionKey);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    return encrypter.decrypt64(encryptedPassword, iv: iv);
  }

  // Fungsi untuk validasi login
  void _validateLogin() {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username == correctUsername && password == correctPassword) {
      // Jika login berhasil, tampilkan hasil enkripsi
      String encryptedPass = encryptPassword(password);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            username: username,
            password: password,
            encryptedPassword: encryptedPass,
            decryptedPassword: decryptPassword(encryptedPass),
          ),
        ),
      );
    } else {
      // Jika login gagal, tampilkan error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username atau Password salah!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _validateLogin,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class ResultScreen extends StatelessWidget {
  final String username;
  final String password;
  final String encryptedPassword;
  final String decryptedPassword;

  const ResultScreen({
    super.key,
    required this.username,
    required this.password,
    required this.encryptedPassword,
    required this.decryptedPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Enkripsi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Username: $username',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              'Original Password: $password',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              'Encrypted Password: $encryptedPassword',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              'Decrypted Password: $decryptedPassword',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}