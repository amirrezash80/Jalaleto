import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:roozdan/features/register/forget_pass/presentation/forget_pass_screen.dart';
import 'package:roozdan/features/register/getx/user_info_getx.dart';

import '../../../home/presentation/screens/home_screen.dart';
import '../../signup/presentation/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = "/LoginScreen";

  const LoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  final FocusNode _focusNodePassword = FocusNode();
  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> Login() async {
    String url = 'https://dev.jalaleto.ir/api/User/Login';
    setState(() {
      _isLoading = true;
    });
    String? username = _controllerUsername.text;
    String? password = _controllerPassword.text;
    if (username != null && password != null) {
      Map<String, dynamic> LoginData = {
        "userName": username,
        "password": password,
      };
      print(LoginData['userName']);
      try {
        final response = await http.post(
          Uri.parse(url),
          body: jsonEncode(LoginData),
          headers: {
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          Map<String, dynamic> jsonResponse = json.decode(response.body);
          bool success = jsonResponse['success'];
          String message = jsonResponse['message'];
          String token = jsonResponse['token'];
          Map<String, dynamic> userData = userDataStorage.userData;
          userData['token'] = token;
          userDataStorage.saveUserData(userData);
          print("token => $token");
          print(userDataStorage.userData["token"]);
          _formKey.currentState?.reset();
          if (success)
            Navigator.pushReplacementNamed(context, HomeScreen.routeName);
          else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Theme
                    .of(context)
                    .colorScheme
                    .secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                behavior: SnackBarBehavior.floating,
                content: Container(
                  alignment: Alignment.center,
                  child: Text("نام کاربری یا رمز عبور اشتباه است ! "),
                ),
              ),
            );
          }
        } else {
          print('Request failed with status: ${response.statusCode}');
          print(response.body);
        }
      }
      // catch (error) {
      //   print('Error: $error');
      // }
      finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 150),
                Text(
                  "خوش آمدید",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  "وارد حساب کاربری خود شوید",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 60),
                TextFormField(
                  controller: _controllerUsername,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    labelText: "نام کاربری",
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onEditingComplete: () => _focusNodePassword.requestFocus(),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "لطفا نام کاربری را وارد کنید.";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _controllerPassword,
                  focusNode: _focusNodePassword,
                  obscureText: _obscurePassword,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelText: "رمز عبور",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: _obscurePassword
                            ? const Icon(Icons.visibility_outlined)
                            : const Icon(Icons.visibility_off_outlined)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "لطفا رمز عبور را وارد نمایید .";
                    }
                    return null;
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        _formKey.currentState?.reset();
                        Navigator.pushNamed(
                            context, ForgetPassScreen.routeName);
                      },
                      child: const Text("فراموشی رمز عبور"),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          // final AuthResponse res = await supabase.auth.signInWithPassword(
                          //     email: _controllerUsername.text,
                          //     password: _controllerPassword.text
                          // );
                          Login();
                          // _formKey.currentState?.reset();
                        }
                      },
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : const Text("ورود"),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("حساب کاربری ندارید؟"),
                        TextButton(
                          onPressed: () {
                            _formKey.currentState?.reset();
                            Navigator.pushNamed(
                                context, SignupScreen.routeName);
                          },
                          child: const Text("ثبت نام"),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNodePassword.dispose();
    _controllerUsername.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }
}
