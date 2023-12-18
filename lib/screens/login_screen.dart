import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_todo/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLogin = true;
  bool _isLoading = false;

  String? _email, _password, _errorMessage;

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (validForm() && _isLoading) {
      UserCredential user;
      String userId = '';

      try {
        if (_isLogin) {
          user = await _auth.signInWithEmailAndPassword(
            email: _email!,
            password: _password!,
          );
        } else {
          user = await _auth.createUserWithEmailAndPassword(
            email: _email!,
            password: _password!,
          );
        }

        userId = user.user!.uid;

        if (userId.isNotEmpty) {
          setState(() {
            _isLoading = false;
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(userId: userId),
            ),
          );
        }
      } catch (error) {
        setState(() {
          _isLoading = false;
          _errorMessage = error.toString();
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool validForm() {
    final form = _formKey.currentState;

    if (form == null) {
      return false;
    }

    if (form.validate()) {
      form.save();
      return true;
    }

    return false;
  }

  String? _validPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Requerido';
    }

    if (value.length < 5) {
      return 'Minimo 5 caracteres';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autenticación'),
      ),
      body: Stack(
        children: [
          _showForm(),
          _showCircularProgress(),
        ],
      ),
    );
  }

  _showCircularProgress() => _isLoading
      ? const Center(child: CircularProgressIndicator())
      : Container();

  Widget _showForm() {
    const paddingForm = EdgeInsets.only(top: 16.0);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const FlutterLogo(size: 150),
            Padding(
              padding: paddingForm,
              child: TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.emailAddress,
                autofocus: false,
                decoration: const InputDecoration(
                  hintText: 'Correo',
                  icon: Icon(Icons.mail),
                ),
                validator: (value) =>
                    value != null && value.isEmpty ? 'Requerido' : null,
                onSaved: (value) => _email = value?.trim(),
              ),
            ),
            Padding(
              padding: paddingForm,
              child: TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.text,
                obscureText: true,
                autofocus: false,
                decoration: const InputDecoration(
                  hintText: 'Contraseña',
                  icon: Icon(Icons.password),
                ),
                validator: _validPassword,
                onSaved: (value) => _password = value?.trim(),
              ),
            ),
            Padding(
              padding: paddingForm,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        _submit();
                      },
                child: Text(_isLogin ? 'Login' : 'Registro'),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(_isLogin ? 'O Registrarse' : 'O Inicia Sesión'),
            ),
            (_errorMessage != null && _errorMessage!.isNotEmpty)
                ? Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontSize: 13.0,
                      color: Colors.red,
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
