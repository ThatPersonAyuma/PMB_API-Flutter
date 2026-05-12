import 'package:flutter/material.dart';
import '../api_handler/login.dart';
import './home.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.fromLTRB(30, 40, 30, 80),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue, Colors.purple],
          ),
        ),
        child: const Center(child: LoginForm()),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<StatefulWidget> createState() {
    return _LoginFormState();
  }
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _authHandler = const AuthHandler();
  final usernameController = TextEditingController(text: '');
  final pwController = TextEditingController(text: '');
  final textStyle = const TextStyle(color: Colors.white, fontSize: 16);
  final errorStyle = const TextStyle(color: Colors.red, fontSize: 16);
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          const Text(
            "Halooo, Silakan Login Terlebih Dahulu",
            textAlign: TextAlign.center,
            softWrap: true,
            maxLines: 2,
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          SizedBox(height: 20),
          TextFormField(
            style: textStyle,
            decoration: InputDecoration(
              hintStyle: textStyle,
              labelStyle: textStyle,
              labelText: 'Username',
              hintText: 'Username',
              errorStyle: errorStyle,
              border: OutlineInputBorder(),
              // suffixIcon: Icon(Icons.error),
            ),
            controller: usernameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Masukkan username';
              }
              return null;
            },
          ),
          TextFormField(
            style: textStyle,
            decoration: InputDecoration(
              hintStyle: textStyle,
              hintText: 'Password',
              labelStyle: textStyle,
              labelText: 'Password',
              errorStyle: errorStyle,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2.0),
              ),
              // suffixIcon: Icon(Icons.error),
            ),
            controller: pwController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Masukkan password';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                setState(() => _isLoading = true);
                var messager = ScaffoldMessenger.of(
                  context,
                ); // Capture before await
                final navigator = Navigator.of(context);
                final String? token = await _authHandler.login(
                  usernameController.text,
                  pwController.text,
                );

                if (token != null) {
                  final String? name = await _authHandler.getName();
                  if (name == null) {
                    throw ErrorDescription('Error while getting the name from SecureStorage');
                  }
                  navigator.pushReplacement(
                    MaterialPageRoute(
                      builder: (context) =>
                          HomePage(name: name, token: token),
                    ),
                  );
                } else {
                  messager.showSnackBar(
                    const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        'Gagal Login. Periksa Username dan Password',
                      ),
                    ),
                  );
                  setState(() => _isLoading = false);
                }
              }
            },
            child: _isLoading 
              ? const CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
              : const Text(
                "Login",
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
          ),
        ],
      ),
    );
  }
}
