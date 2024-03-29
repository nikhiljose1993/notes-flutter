// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();

  bool _isLogin = true, _isPasswordHidden = true, _isAuthenticating = false;
  String _enteredEmail = '', _enteredPassword = '';

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      // err
      return;
    }

    _form.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
      }
    } on FirebaseAuthException catch (err) {
      setState(() {
        _isAuthenticating = false;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.message ?? 'Authentication failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final inputBorder = OutlineInputBorder(
      borderRadius: const BorderRadius.all(
        Radius.circular(10),
      ),
      borderSide: BorderSide(
        width: 1,
        color: Theme.of(context).colorScheme.onBackground,
      ),
    );

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(
                    left: 90, right: 50, bottom: 20, top: 30),
                padding: const EdgeInsets.all(50),
                child: Image.asset('assets/logo.png'),
              ),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: theme.colorScheme.inverseSurface.withOpacity(0.8),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  // Form
                  child: Form(
                    key: _form,
                    child: Column(
                      children: [
                        // Email Input
                        TextFormField(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            labelText: 'Email',
                            labelStyle: TextStyle(
                                color: theme.colorScheme.secondaryContainer),
                            border: inputBorder,
                            isDense: true,
                          ),
                          style: TextStyle(color: theme.colorScheme.background),
                          keyboardType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.none,
                          autocorrect: false,
                          validator: (value) {
                            const pattern =
                                r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$";
                            final regex = RegExp(pattern);

                            return value == null ||
                                    value.trim().isEmpty ||
                                    !regex.hasMatch(value)
                                ? 'Enter a valid email address'
                                : null;
                          },
                          onSaved: (newValue) {
                            _enteredEmail = newValue!;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password Input
                        TextFormField(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            labelText: 'Password',
                            labelStyle: TextStyle(
                                color: theme.colorScheme.secondaryContainer),
                            border: inputBorder,
                            isDense: true,
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordHidden
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _isPasswordHidden = !_isPasswordHidden;
                                });
                              },
                              iconSize: 20,
                              padding: const EdgeInsets.only(right: 10),
                              color: theme.colorScheme.secondaryContainer,
                            ),
                            suffixIconConstraints: const BoxConstraints(
                                maxHeight: 30, maxWidth: 40),
                          ),
                          style: TextStyle(color: theme.colorScheme.background),
                          enableSuggestions: false,
                          autocorrect: false,
                          obscureText: _isPasswordHidden,
                          validator: (value) {
                            const pattern =
                                r"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$";
                            final regex = RegExp(pattern);

                            return value == null ||
                                    value.trim().length < 6 ||
                                    !regex.hasMatch(value)
                                ? 'Minimum eight characters, at least one uppercase letter, one lowercase letter, one number and one special character required'
                                : null;
                          },
                          onSaved: (newValue) {
                            _enteredPassword = newValue!;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Buttons
                        if (_isAuthenticating)
                          const CircularProgressIndicator(),
                        if (!_isAuthenticating)
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  theme.colorScheme.onSecondaryContainer,
                              foregroundColor:
                                  theme.colorScheme.secondaryContainer,
                            ),
                            child: Text(_isLogin ? 'Login' : 'Signup'),
                          ),
                        if (!_isAuthenticating)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                              _form.currentState!.reset();
                              FocusScope.of(context).unfocus();
                            },
                            // style: TextButton.styleFrom(
                            //   foregroundColor:
                            //       theme.colorScheme.secondaryContainer,
                            // ),
                            child: Text(_isLogin
                                ? 'Create an account'
                                : 'I already have an account'),
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
