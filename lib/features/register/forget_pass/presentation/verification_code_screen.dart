import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:roozdan/core/theme/gradient.dart';
import 'package:roozdan/features/register/forget_pass/presentation/reset_pass_screen.dart';

import '../../getx/user_info_getx.dart';
import '../../login/presentation/login_screen.dart';

class VerificationCodeScreen extends StatefulWidget {
  static const routeName = "/VerificationCodeScreen";

  @override
  _VerificationCodeScreenState createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  bool _isLoading = false; // Add loading indicator

  // Function to handle signup after verification
  Future<void> signUp() async {
    setState(() {
      _isLoading = true; // Set loading state while signing up
    });

    // Collect verification code from text fields
    String verificationCode =
        _controllers.map((controller) => controller.text).join();

    // Append code to user data
    Map<String, dynamic> userData = userDataStorage.userData;
    userData['code'] = int.parse(verificationCode);
    // userData['firstName'] = "test";
    // userData['lastName'] = "test";
    // userData['birthday'] = "2023-11-30";
    userDataStorage.saveUserData(userData);

    print(userData['hashString']);
    // Call signup API with updated user data
    try {
      String url = 'https://dev.jalaleto.ir/api/User/SignUp';
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode(userData),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.body.contains('true') == true) {
        // If signup is successful, navigate to login screen
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor:
                    Theme.of(context).colorScheme.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                behavior: SnackBarBehavior.floating,
                content: Container(
                  alignment: Alignment.center,
                  child: Text("! با موفقیت ثبت نام شدید "),
                ),
              ),
            );

        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      } else {
        SnackBar(
          backgroundColor:
          Theme.of(context).colorScheme.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
          content: Container(
            alignment: Alignment.center,
            child: Text("کد تایید نامعتبر است . "),
          ),
        );

    print('Request failed with status: ${response.statusCode}');
        print(response.body);
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(userDataStorage.userData["FirstName"]);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        body: Stack(
          children: [
            MyGradient(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                Text(
                  "لطفا کد تایید 6 رقمی را وارد کنید",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Container(
                      padding: EdgeInsets.all(2),
                      width: 50,
                      height: 50,
                      child: TextFormField(
                        controller: _controllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: "_",
                          hintStyle: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2.0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.blueGrey, width: 1.0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (code) {
                          if (code.isNotEmpty) {
                            if (index < 5) {
                              _controllers[index + 1].clear();
                              FocusScope.of(context)
                                  .requestFocus(_focusNodes[index + 1]);
                            }
                          }
                        },
                        focusNode: _focusNodes[index],
                      ),
                    );
                  }),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: signUp,
                  // onPressed: () {
                  //   String verificationCode =
                  //       _controllers.map((controller) => controller.text).join();
                  //   if (verificationCode == "1234") {
                  //     Navigator.pushReplacementNamed(
                  //         context, ResetPassScreen.routeName);
                  //   } else {
                  //     ScaffoldMessenger.of(context).showSnackBar(
                  //       SnackBar(
                  //         backgroundColor:
                  //             Theme.of(context).colorScheme.secondary,
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(10),
                  //         ),
                  //         behavior: SnackBarBehavior.floating,
                  //         content: Container(
                  //           alignment: Alignment.center,
                  //           child: Text("! کد وارد شده صحیح نمی‌باشد "),
                  //         ),
                  //       ),
                  //     );
                  //     // print("Invalid code. Please try again.");
                  //   }
                  // },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white, // Set your desired button color
                    minimumSize: Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : const Text("تایید"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
