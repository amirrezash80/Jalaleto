import 'package:flutter/material.dart';
import 'package:roozdan/features/register/forget_pass/presentation/verification_code_screen.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../getx/user_info_getx.dart';

class UserDataStorage {
  static Map<String, dynamic>? _userData;

  static void saveUserData(Map<String, dynamic> data) {
    _userData = data;
  }

  static Map<String, dynamic>? get userData => _userData;
}

class SignupScreen extends StatefulWidget {
  static const routeName = "/SignupScreen";

  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupState();
}

class _SignupState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final uuid = Uuid();
  final FocusNode _focusNodeEmail = FocusNode();
  final FocusNode _focusNodePassword = FocusNode();
  final FocusNode _focusNodeConfirmPassword = FocusNode();
  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword =
  TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> signUp() async {
    String url = 'https://dev.jalaleto.ir/api/User/SignUp';
    _isLoading = true;
    Map<String, dynamic> signupData = {
      "userName": _controllerUsername.text,
      "password": _controllerPassword.text,
      "mail": _controllerEmail.text,
      "firstName": "string",
      "lastName": "string",
      "birthday": "2023-11-30",
    };

    userDataStorage.saveUserData(signupData);

    try {
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(signupData),
        headers: {
          'Content-Type': 'application/json',
        },
      );


      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        bool success = jsonResponse['success'];
        String message = jsonResponse['message'];
        print("success => $success");

        _formKey.currentState?.reset();
        Navigator.pop(context);
      } else {
        print('Request failed with status: ${response.statusCode}');
        print(response.body);
      }
    } catch (error) {
      print('Error: $error');
    }
    finally {
      setState(() {
        _isLoading = false;
      });
    }

  }

  Future<void> VerifyEmail() async {
    _isLoading = true;
    String url = 'https://dev.jalaleto.ir/api/User/SendVerifyEmail';

    try {
      print(_controllerUsername.text);
      print(_controllerPassword.text);
      print(_controllerEmail.text);
      Map<String, dynamic> userData = {
        "userName": _controllerUsername.text,
        "password": _controllerPassword.text,
        "mail": _controllerEmail.text,
        "firstName": "firstName",
        "lastName": "lastName",
        "birthday": "2023-11-30",
      };
      userDataStorage.saveUserData(userData);
      print(userDataStorage.userData["mail"]);

      Map<String, dynamic> userEmail = {
        "email": _controllerEmail.text, // Use email here
      };

      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(userEmail),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {

        Map<String, dynamic> jsonResponse = json.decode(response.body);
        String token = jsonResponse['hashString'];
        String message = jsonResponse['message'];

        userData['hashString'] = token;
        userDataStorage.saveUserData(userData);
        print("username => ${userData['userName']}");
        print("password => ${userData['password']}");
        print("mail => ${userData['mail']}");
        print("firstname => ${userData['firstName']}");
        print("lastname => ${userData['lastName']}");
        print("birthday => ${userData['birthday']}");
        print("token => ${userData['hashString']}");
        _formKey.currentState?.reset();
        // Navigator.pop(context);
        Navigator.pushReplacementNamed(context, VerificationCodeScreen.routeName);
      } else {
        print('Request failed with status: ${response.statusCode}');
        print(response.body);
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  void dispose() {
    if (context.mounted) {
      _focusNodeEmail.dispose();
      _focusNodePassword.dispose();
      _focusNodeConfirmPassword.dispose();
      _controllerUsername.clear();
      _controllerEmail.clear();
      _controllerPassword.clear();
      _controllerConfirmPassword.clear();
    }

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    const SizedBox(height: 100),
                    Text(
                      "ثبت نام",
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "حساب کاربری خود را ایجاد کنید",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 35),
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
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "لطفا نام کاربری را وارد کنید.";
                        }
                        return null;
                      },
                      onEditingComplete: () => _focusNodeEmail.requestFocus(),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _controllerEmail,
                      focusNode: _focusNodeEmail,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "ایمیل",
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return "لطفا ایمیل خود را وارد نمایید.";
                        } else if (!(value.contains('@') &&
                            value.contains('.'))) {
                          return "ایمیل نامعتبر.";
                        }
                        return null;
                      },
                      onEditingComplete: () => _focusNodePassword.requestFocus(),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _controllerPassword,
                      obscureText: _obscurePassword,
                      focusNode: _focusNodePassword,
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
                          return "لطفا رمز عبور خود را وارد نمایید. ";
                        } else if (value.length < 8) {
                          return "رمز عبور باید حداقل ۸ حرف باشد.";
                        }
                        return null;
                      },
                      onEditingComplete: () =>
                          _focusNodeConfirmPassword.requestFocus(),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _controllerConfirmPassword,
                      obscureText: _obscurePassword,
                      focusNode: _focusNodeConfirmPassword,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        labelText: "تایید رمز عبور",
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
                        } else if (value != _controllerPassword.text) {
                          return "رمز عبور وارد شده متفاوت است.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 50),
                    Column(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xffF7F7FF),
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),

                          onPressed: () async {
                            String uniqueId = uuid.v4();
                            BigInt uuidBigInt = BigInt.parse(uniqueId.replaceAll('-', ''), radix: 16);
                            String uuidString = uuidBigInt.toString();

                            if (_formKey.currentState?.validate() ?? false) {
                                VerifyEmail();
                              _formKey.currentState?.reset();
                                Navigator.pushReplacementNamed(context, VerificationCodeScreen.routeName);
                            }
                          },
                          // onPressed: VerifyEmail,
                          child: _isLoading
                              ? CircularProgressIndicator()
                              : const Text("ثبت نام"),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("حساب کاربری دارید؟"),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("ورود با حساب کاربری"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
