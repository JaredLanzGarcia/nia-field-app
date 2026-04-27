import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:nia_project/screens/main_screen.dart';
import 'package:nia_project/url_of_db.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final TextEditingController _empIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void doRegister() async {
    String? message = await callLoginApi(
      _empIdController.text,
      _passwordController.text,
    );
    print(message);
    print(_empIdController.text);
    print(_passwordController.text);
  }

  Future<String?> callLoginApi(String empId, String password) async {
    try {
      // 1. Point to your Python server (Use your computer's local IP if testing)
      final url = Uri.parse("${UrlOfDb.dbUrl}/register");

      // add unique id of device and learn iOS deployment
      // merge API of Andrei

      // 2. Send the POST request
      final response = await http.post(
        url,
        body: {'employee_id': empId, 'password': password},
      );

      // 3. Handle the response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // If Python returns {"access_token": "..."}
        return data['message'];
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
                    ),
                    Gap(16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: inputDecor("Password", isPassword: true),
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
                        onPressed: () => doRegister(),
                        child: Text("Register", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
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
      errorBorder: borderDesign(),
      enabledBorder: borderDesign(),
      focusedBorder: borderDesign(),
      disabledBorder: borderDesign(),
      focusedErrorBorder: borderDesign(),
    );
  }

  OutlineInputBorder borderDesign() {
    return OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 0),
    );
  }
}
