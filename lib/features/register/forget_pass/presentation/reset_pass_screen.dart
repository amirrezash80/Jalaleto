
import 'package:flutter/material.dart';
import 'package:roozdan/core/theme/gradient.dart';
import 'package:roozdan/features/register/login/presentation/login_screen.dart';


class ResetPassScreen extends StatefulWidget {
  static const routeName = "/ResetPassScreen";
  const ResetPassScreen({super.key});

  @override
  State<ResetPassScreen> createState() => _ResetPassScreen();
}

class _ResetPassScreen extends State<ResetPassScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  // final supabase = Supabase.instance.client;
  final FocusNode _focusNodePassword = FocusNode();
  final FocusNode _focusNodeConfirmPassword = FocusNode();
  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConFirmPassword =
  TextEditingController();

  bool _obscurePassword = true;

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
                    const SizedBox(height: 150),
                    Text(
                      "تغییر رمز عبور",
                      style: Theme
                          .of(context)
                          .textTheme
                          .headlineLarge,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "لطفا رمز عبور جدید خود را وارد کنید",
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyMedium,
                    ),
                    const SizedBox(height: 60),
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
                      controller: _controllerConFirmPassword,
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
                                    child: Text("رمزعبور شما با موفقیت تغییر داده شد! "),
                                  ),
                                ),
                              );
                              _formKey.currentState?.reset();
                              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
                            }

                          },
                          child: const Text("تایید"),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("حساب کاربری دارید؟"),
                            TextButton(
                              onPressed: () => Navigator.pushReplacementNamed(context,LoginScreen.routeName),
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

  @override
  void dispose() {
    _focusNodePassword.dispose();
    _controllerUsername.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }
}