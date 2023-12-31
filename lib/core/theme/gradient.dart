import 'package:flutter/material.dart';

class MyGradient extends StatelessWidget {
  const MyGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return  Container(
      // Add box decoration
      decoration:  BoxDecoration(
        // Box decoration takes a gradient
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            // Colors.orangeAccent.shade400,
            // Colors.orangeAccent.shade400,
            // Colors.orangeAccent.shade200,
            // Colors.orangeAccent.shade200,
            // Colors.orangeAccent.shade200,
            // Colors.orangeAccent.shade200,
            // Colors.orangeAccent.shade100,
            // Color(0xff577399).withOpacity(.8),
            Color(0xff577399).withOpacity(0.7),
            Color(0xff577399).withOpacity(0.6),
            Color(0xff577399).withOpacity(0.5),
            Color(0xff577399).withOpacity(0.4),
            Color(0xff577399).withOpacity(0.3),
          ],
        ),
      ),

    );

  }
}
