import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:nia_project/database.dart';
import 'package:nia_project/screens/main_screen.dart';

class LoginScreen extends StatefulWidget {
  final Function(String, List<dynamic>) onLoginSuccess;
  LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _empIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final database = AppDatabase();
  final api_url = "http://192.168.68.134:8000";
  bool isObscured = true;
  String? errorMessage;

  void doLogin() async {
    setState(() {
      errorMessage = null;
    });

    final result = await callLoginApi(
      _empIdController.text,
      _passwordController.text,
    );

    if (result != null) {
      final response = await http.get(
        Uri.parse('${api_url}/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${result['access_token']}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final int empId = data['employee_id'];
        await database.delete(database.users).go();

        await database
            .into(database.users)
            .insert(
              UsersCompanion.insert(
                employeeId: empId.toString(),
                password: _passwordController.text,
              ),
            );
        widget.onLoginSuccess(result['access_token'], result['history']);
      }
    }
  }

  Future<Map<String, dynamic>?> callLoginApi(
    String empId,
    String password,
  ) async {
    try {
      // 1. Point to your Python server (Use your computer's local IP if testing)
      final url = Uri.parse('${api_url}/login');

      // 2. Send the POST request
      final response = await http.post(
        url,
        body: {'employee_id': empId, 'password': password},
      );

      // 3. Handle the response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // If Python returns {"access_token": "..."}
        setState(() {
          errorMessage = data['error'];
        });
        return data;
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

                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 30),
                          child: Center(
                            child: Text(
                              errorMessage!,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      TextFormField(
                        controller: _empIdController,
                        decoration: inputDecor("Employee ID No."),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length != 6) {
                            return 'Password must be 6 characters';
                          }
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                            return 'ID must contain only numbers';
                          }
                          return null;
                        },
                      ),
                      Gap(16),
                      TextFormField(
                        obscureText: isObscured,
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
      suffixIcon:
          isPassword
              ? TextButton(
                onPressed: () {
                  setState(() {
                    isObscured = !isObscured;
                  });
                },
                child:
                    isObscured
                        ? Text("Show", style: TextStyle(color: Colors.green))
                        : Text("Hide", style: TextStyle(color: Colors.green)),
              )
              : null,
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
        borderSide: BorderSide(color: Colors.redAccent.shade200, width: 1.0),
      ),
    );
  }

  OutlineInputBorder borderDesign() {
    return OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 0),
    );
  }
}
