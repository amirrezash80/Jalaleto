
import 'package:flutter/material.dart';
import 'package:roozdan/core/theme/gradient.dart';
import 'package:roozdan/features/register/forget_pass/presentation/reset_pass_screen.dart';
import 'package:roozdan/features/register/forget_pass/presentation/verification_code_screen.dart';

import '../../../home/presentation/screens/home_screen.dart';

class ForgetPassScreen extends StatefulWidget {
  static const routeName = "/ForgetPassScreen";
  const ForgetPassScreen({super.key});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  // final supabase = Supabase.instance.client;

  final FocusNode _focusNodePassword = FocusNode();
  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  final FocusNode _focusNodeEmail = FocusNode();
  final TextEditingController _controllerEmail = TextEditingController();


  @override
  Widget build(BuildContext context) {

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .primaryContainer,
        body: Stack(
          children: [
            MyGradient(),
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 200),
                    Text(
                      "فراموشی رمز عبور",
                      style: Theme
                          .of(context)
                          .textTheme
                          .headlineLarge,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "برای تغییر رمز لطفا ایمیل خود را وارد کنید",
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium,
                    ),
                    const SizedBox(height: 60),
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

                              Navigator.pushNamedAndRemoveUntil(context, VerificationCodeScreen.routeName,ModalRoute.withName('/'));

                            }
                          },
                          child: const Text("تایید"),
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

  @override
  void dispose() {
    _focusNodePassword.dispose();
    _controllerUsername.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }
}