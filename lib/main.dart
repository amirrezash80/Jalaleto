import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:persian_fonts/persian_fonts.dart';
import 'package:roozdan/features/home/data/events.dart';
import 'package:roozdan/features/home/presentation/screens/profile_screen.dart';
import 'features/chat/presentation/chat_screen.dart';
import 'features/groups/create_event.dart';
import 'features/home/presentation/screens/create_reminder_screen.dart';
import 'features/groups/create_group_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/groups/public_group_screen.dart';
import 'features/register/forget_pass/presentation/forget_pass_screen.dart';
import 'features/register/forget_pass/presentation/reset_pass_screen.dart';
import 'features/register/forget_pass/presentation/verification_code_screen.dart';
import 'features/register/login/presentation/login_screen.dart';
import 'features/register/signup/presentation/signup_screen.dart';
import 'features/splashscreen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jalaleto',
      theme: ThemeData(
        textTheme: PersianFonts.yekanTextTheme,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff495867)),
        useMaterial3: true,
      ),
      initialRoute: SplashScreen.routeName,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },

      getPages: [
        GetPage(name: SplashScreen.routeName, page: () => SplashScreen()),
        GetPage(name: HomeScreen.routeName,   page: () => HomeScreen()),
        GetPage(name: LoginScreen.routeName,  page: () => LoginScreen()),
        GetPage(name: SignupScreen.routeName, page: () => SignupScreen()),
        GetPage(name: ForgetPassScreen.routeName, page: () => ForgetPassScreen()),
        GetPage(name: ResetPassScreen.routeName, page: () => ResetPassScreen()),
        GetPage(name: VerificationCodeScreen.routeName, page: () => VerificationCodeScreen()),
        GetPage(name: CreateReminderForm.routeName, page: () => CreateReminderForm(myEvent: null,)),
        GetPage(name: ProfileScreen.routeName, page: () => ProfileScreen()),
        GetPage(name: GroupScreen.routeName, page: () => GroupScreen()),
        GetPage(name: CreateEventForm.routeName, page: () => CreateEventForm(groupId: 0,)),
        // GetPage(name: ChatScreen.routeName, page: () => ChatScreen(groupId: 0,)),

      ],
    );
  }
}
