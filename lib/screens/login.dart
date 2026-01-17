import 'dart:io';
import 'dart:ui';

import 'package:appwrite/appwrite.dart';
import 'package:event_planning_app/appwrite.dart';
import 'package:event_planning_app/container/build_textfromfield.dart';
import 'package:event_planning_app/container/navbar.dart';
import 'package:event_planning_app/container/user_image_picker.dart';
import 'package:event_planning_app/model/database.dart';
import 'package:event_planning_app/saved_data.dart';
import 'package:flutter/material.dart';

final Account account = Account(client);
final storage = Storage(client);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final storage = Storage(client);
  String? _uploadedImageId;
  File? _selectedImage;
  final _passwordController = TextEditingController();
  bool isUploading = false;
  final _usernameController = TextEditingController();
  bool _isSignIn = true;
  bool _obscurePassword = true;
  String? _selectedRole;
  //  final List<String> _roles = ["Caterer", "Facility Provider", "Event Planner"];
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isSignIn = !_isSignIn;
      _formKey.currentState?.reset();
      _emailController.clear();
      _passwordController.clear();
      _usernameController.clear();
    });
  }

  Future<void> _submitForm() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid || (!_isSignIn && _selectedRole == null)) {
      return;
    }

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final username = _usernameController.text.trim();

      if (_isSignIn) {
        try {
          final session = await account.createEmailPasswordSession(
              email: email, password: password);

          // Get the current user
          final currentUser = await account.get();

          // Save userId first to fetch associated data
          await SavedData.saveUserId(currentUser.$id);

          // Get the user info from database and save locally (email, name)
          await getUserData(); // Make sure getUserData() calls saveUserEmail + saveUsername

          print("User authenticated: ${currentUser.$id}");

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const BottomNav()),
          );
        } on AppwriteException catch (e) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? 'Authentication failed.'),
              backgroundColor: Colors.red,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Something went wrong. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        final user = await account.create(
          userId: ID.unique(),
          email: email,
          password: password,
          name: username,
        );

        // Save user data to database
        await saveUserData(
          username,
          email,
          user.$id,
          _selectedRole!,
          _uploadedImageId ?? '',
        );

        // 🔐 Then save it locally too
        await SavedData.clearSavedData(); // Optional but safe
        await SavedData.saveUserId(user.$id);
        await SavedData.saveUsername(username);
        await SavedData.saveUserEmail(email);

        print("User created: ${user.email}");

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BottomNav()),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication successful!'),
          backgroundColor: Colors.green,
        ),
      );
    } on AppwriteException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Authentication failed.'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 7),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/image/event_image.jpeg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                width: 350,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (!_isSignIn)
                          UserImagePicker(
                            onPickImage: (pickedImage) {
                              _selectedImage = pickedImage;
                            },
                            storage: storage,
                            onImageUploaded: (String imageId) {
                              _uploadedImageId = imageId;
                            },
                          ),
                        if (!_isSignIn)
                          CustomTextFormField(
                            controller: _usernameController,
                            keyboardType: TextInputType.multiline,
                            labelText: 'Username',
                            prefixIcon: Icons.account_circle_outlined,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().length < 4) {
                                return 'Please enter at least 4 characters';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _usernameController.text = value!;
                            },
                          ),
                        const SizedBox(height: 15),
                        CustomTextFormField(
                          controller: _emailController,
                          labelText: 'Email',
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (value) {
                            _emailController.text = value!;
                          },
                        ),
                        const SizedBox(height: 15),
                        CustomTextFormField(
                          controller: _passwordController,
                          labelText: "Password",
                          prefixIcon: Icons.lock,
                          onSaved: (value) {
                            _passwordController.text = value!;
                          },
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? "Enter your password"
                              : null,
                        ),
                        const SizedBox(height: 20),
                        if (_isLoading)
                          const CircularProgressIndicator()
                        else
                          ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 12,
                              ),
                            ),
                            child: Text(_isSignIn ? "Login" : "Sign Up"),
                          ),
                        TextButton(
                          onPressed: _toggleAuthMode,
                          child: Text(
                            _isSignIn
                                ? "Create an Account"
                                : "Already have an account?",
                          ),
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
    );
  }
}
