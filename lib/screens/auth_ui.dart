// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:chat_app/models/size_config.dart';
import 'package:chat_app/widgets/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

final _supabase = Supabase.instance;

class AuthUi extends StatefulWidget {
  const AuthUi({super.key});

  @override
  State<AuthUi> createState() => _AuthUiState();
}

class _AuthUiState extends State<AuthUi> {
  //variabales
  bool _isHidden = true;
  bool _isLogin = true;
  final passwordController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  String _emailInput = '';
  String _passwordInput = '';
  String _usernameInput = '';
  bool _isLoading = false;
  File? _pickedImage;
  String _pickedImageMessage = '';
  //methodes
  String capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _showPassword() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  void _submit() async {
    final isValidate = _formkey.currentState!.validate();
    if (!isValidate) {
      return;
    }

    _formkey.currentState!.save();
    // ignore: avoid_print
    print("Email: $_emailInput Password: $_passwordInput");
    try {
      setState(() {
        _isLoading = true;
      });
      if (_isLogin) {
        //login logic

        final authResponse = await _supabase.client.auth.signInWithPassword(
          email: _emailInput,
          password: _passwordInput,
        );
        // ignore: avoid_print
        print(authResponse);
      } else {
        //signup logic
        if (_pickedImage == null) {
          setState(() {
            _pickedImageMessage = "Image is required";
            _isLoading = false;
          });
          return;
        }
        final newFileName = Uuid().v1();
        await _supabase.client.storage
            .from('images')
            .upload(
              'uploads/$newFileName',
              _pickedImage!,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );
        final imageUrl = _supabase.client.storage
            .from('images')
            .getPublicUrl('uploads/$newFileName');

        final authResponse = await _supabase.client.auth.signUp(
          email: _emailInput,
          password: _passwordInput,
          data: {'imageUrl': imageUrl},
        );
        final userId = authResponse.user?.id;
        await _supabase.client.from("users").insert({
          'user_id': userId,
          'email': _emailInput,
          'imageUrl': imageUrl,
          'username': capitalizeFirst(_usernameInput),
        });

        // ignore: avoid_print
        print("▶️  ${authResponse.user}");
      }
    } on AuthApiException catch (e) {
      setState(() {
        _isLoading = false;
      });
      // ignore: avoid_print
      print("❌ $e");
      String errorMessage = 'Authentication error';

      final msg = e.message.toLowerCase();

      if (msg.contains('invalid login credentials') ||
          msg.contains('password')) {
        errorMessage = 'incorrect password. Please try again.';
      } else if (msg.contains('user not found') || msg.contains('email')) {
        errorMessage = 'No account found with this email.';
      } else if (msg.contains('too many requests')) {
        errorMessage = 'too many login attempts. Please wait and try later.';
      } else if (msg.contains('user already registered')) {
        errorMessage = 'This email is alreday use';
      }
      // add more cases as needed
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $errorMessage'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final width = SizeConfig.screenWidth;
    final height = SizeConfig.screenHeight;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 10),

                width: width * 0.5,
                child: Image.asset("assets/images/message_icon.png"),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),

                    child: AnimatedSize(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      child: Form(
                        key: _formkey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_isLogin)
                              ImagePicker(
                                onPickedImage: (pikedImage) {
                                  _pickedImage = pikedImage;
                                },
                              ),
                            if (!_isLogin)
                              Container(
                                margin: EdgeInsets.all(10),
                                child: Text(
                                  _pickedImageMessage,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),

                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "Email",
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required';
                                }
                                final emailRegex = RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                );
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                              onSaved: (newValue) => _emailInput = newValue!,
                              autocorrect: false,
                            ),
                            if (!_isLogin) SizedBox(height: height * 0.015),
                            if (!_isLogin)
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: "Username",
                                  prefixIcon: Icon(Icons.person),
                                ),
                                validator: (value) {
                                  if (_isLogin) {
                                    return null;
                                  }
                                  if (value != null && value.isNotEmpty) {
                                    return null;
                                  }
                                  return 'Username is required';
                                },
                                onSaved: (newValue) {
                                  if (newValue != null) {
                                    _usernameInput = newValue;
                                    // ignore: avoid_print
                                    print("👌👌👌👌👌  $_usernameInput");
                                  }
                                },
                              ),
                            SizedBox(height: height * 0.015),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: "Password",
                                prefixIcon: Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  onPressed: _showPassword,
                                  icon: Icon(
                                    _isHidden
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                              ),
                              controller: passwordController,
                              obscureText: _isHidden,
                              validator: (value) {
                                if (value == null) {
                                  return "Password is required";
                                } else if (value.length < 8) {
                                  return "passowrd shoulde be 8 characters or more";
                                }
                                return null;
                              },
                              onSaved: (newValue) => _passwordInput = newValue!,
                            ),
                            SizedBox(height: height * 0.015),
                            if (!_isLogin)
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: "Confirme password",
                                  prefixIcon: Icon(Icons.lock),
                                  suffixIcon: IconButton(
                                    onPressed: _showPassword,
                                    icon: Icon(
                                      _isHidden
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                  ),
                                ),

                                obscureText: _isHidden,
                                validator: (value) {
                                  if (value != passwordController.text) {
                                    return "check your password input";
                                  }
                                  return null;
                                },
                              ),
                            SizedBox(height: height * 0.015),
                            if (_isLoading) const CircularProgressIndicator(),
                            if (!_isLoading)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _isLogin = !_isLogin;
                                      });
                                    },
                                    child: Text(
                                      _isLogin
                                          ? "CREATE A ACCOUNT?"
                                          : "Alreday have a account?",
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: _submit,
                                    child: Text(_isLogin ? 'Login' : "Signup"),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
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
