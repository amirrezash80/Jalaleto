import 'package:flutter/material.dart';

// import 'package:share_plus/share_plus.dart';

import '../../presentation/screens/profile_screen.dart';

Text DrawerTextStyle(String text, context) {
  return Text(
    text,
    style:  TextStyle(
        color: Colors.blueGrey.shade700, fontSize: 20, fontWeight: FontWeight.bold),
  );
}

Container myDivider() {
  return Container(
    color: Colors.teal.withOpacity(0.3),
    height: 1,
  );
}

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          SizedBox(
            height: 400,
            width: MediaQuery.of(context).size.width,
            child: DrawerHeader(
              margin: const EdgeInsets.all(0),
              child: Image.asset(
                'assets/DrawerLogo.jpg',
                fit: BoxFit.fill,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(0),
              children: [
                ListTile(
                  title: DrawerTextStyle("پروفایل", context),
                  leading: const Icon(Icons.person),
                  onTap: () =>
                      Navigator.pushNamed(context, ProfileScreen.routeName),
                ),
                myDivider(),
                ExpansionTile(
                  title: DrawerTextStyle(
                    "درباره ما",
                    context,
                  ),
                  leading: const Icon(Icons.info),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "سلام خیلی خوش اومدید به جلالتو! ",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "امیدوارم از این برنامه لذت ببرید.",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "اگر پیشنهاد، نظر یا انتقادی دارید،",
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "از طریق راه‌های ارتباطی با من در میون بذارید.",
                            style: TextStyle(fontSize: 16),
                          ),
                          // Add more about me information here
                        ],
                      ),
                    ),
                  ],
                ),
                myDivider(),
                ExpansionTile(
                  title: DrawerTextStyle(
                    "راه ارتباطی",
                    context,
                  ),
                  leading: const Icon(Icons.contact_mail),
                  children: const [
                    ListTile(
                      leading: Icon(
                        Icons.email,
                        color: Colors.teal,
                      ),
                      title: Text(
                        "ایمیل:\nsharifzadeamir80@gmail.com",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.telegram,
                        color: Colors.teal,
                      ),
                      title: Text(
                        "تلگرام:\n AmirSharif80@",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.computer,
                        color: Colors.teal,
                      ),
                      title: Text(
                        "لینکدین:\n www.linkedin.com/in/amirreza-sharifzade",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    // Add more contact information here
                  ],
                ),
                myDivider(),
                ExpansionTile(
                  title: DrawerTextStyle(
                    "حمایت",
                    context,
                  ),
                  leading: const Icon(Icons.assistant),
                  children: const [
                    ListTile(
                      leading: Icon(
                        Icons.favorite,
                        color: Colors.teal,
                      ),
                      title: Text(
                        "از طریق رسانه‌های اجتماعی ما را دنبال کنید!",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    // Add more ways to support here
                  ],
                ),
                myDivider(),
                ExpansionTile(
                  title: DrawerTextStyle(
                    "اشتراک ‌گذاری اپلیکیشن",
                    context,
                  ),
                  leading: const Icon(Icons.share),
                  children: [
                    ListTile(
                      title: const Text(
                        "این برنامه را با دوستان و آشنایانتون به اشتراک بگذارید",
                        style: TextStyle(fontSize: 16),
                      ),
                      leading: const Icon(
                        Icons.share,
                        color: Colors.teal,
                      ),
                      onTap: () {
                        // Share.share(
                        //   "سلام! اپلیکیشن فوق‌العاده‌ای رو پیدا کردم به نام Jalalito که واقعاً دوستش دارم. می‌توانید از کافه بازار و اپ استور دانلودش کنید.",
                        // );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
