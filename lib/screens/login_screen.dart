import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:nia_project/screens/main_screen.dart';

class LoginScreen extends StatelessWidget {
  final Function(String) onLoginSuccess;
  LoginScreen({super.key, required this.onLoginSuccess});

  final TextEditingController _empIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void doLogin() async {
    String? token = await callLoginApi(
      _empIdController.text,
      _passwordController.text,
    );

    if (token != null) {
      onLoginSuccess(token);
    }
  }

  Future<String?> callLoginApi(String empId, String password) async {
    try {
      // 1. Point to your Python server (Use your computer's local IP if testing)
      final url = Uri.parse('http://192.168.1.32:8000/login');

      // 2. Send the POST request
      final response = await http.post(
        url,
        body: {'employee_id': empId, 'password': password},
      );

      // 3. Handle the response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // If Python returns {"access_token": "..."}
        return data['access_token'];
      } else {
        print("Login failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Network error: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          "assets/images/building-bg2.png",
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          "assets/images/nia-logo.png",
                          width: 250,
                        ),
                      ),
                      TextFormField(
                        controller: _empIdController,
                        decoration: inputDecor("Employee ID No."),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password must be at least 6 characters';
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'ID must contain only numbers';
                          }
                          return null;
                        },
                      ),
                      Gap(16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: inputDecor("Password", isPassword: true),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      Gap(20),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            overlayColor: Colors.green,
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              doLogin();
                            }
                          },
                          child: Text("Login", style: TextStyle(fontSize: 16)),
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
    );
  }

  InputDecoration inputDecor(String field, {bool isPassword = false}) {
    return InputDecoration(
      label: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(field, style: TextStyle(color: Colors.black)),
        ),
      ),
      hintFadeDuration: Duration(seconds: 3),
      suffixIcon: isPassword ? Icon(Icons.remove_red_eye) : null,
      suffixIconColor: Colors.green.shade200,
      filled: true,
      fillColor: Colors.white,
      border: borderDesign(),
      enabledBorder: borderDesign(),
      focusedBorder: borderDesign(),
      disabledBorder: borderDesign(),
      focusedErrorBorder: borderDesign(),
      errorStyle: TextStyle(
        color: Colors.redAccent.shade200, // Change the text color
        fontSize: 14.0, // Adjust the size
        fontWeight: FontWeight.bold, // Make it pop
        fontStyle: FontStyle.italic, // Add some flair
      ),
      // You can also style the border when in an error state
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent.shade100, width: 1.0),
      ),
    );
  }

  OutlineInputBorder borderDesign() {
    return OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 0),
    );
  }
}
