import 'package:flutter/material.dart';
import '../../anim/wave_animation.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_ai_gradient.jpg'),
            fit: BoxFit.cover,
          ),
        ),

    // return Container(
    //   // Add gradient background container
    //   decoration: const BoxDecoration(
    //     gradient: LinearGradient(
    //       begin: Alignment.topCenter,
    //       end: Alignment.bottomCenter,
    //       colors: [
    //         Color(0xFF192150), // Dark purple from HomeScreen
    //         Color(0xFF390962), // Original background color
    //       ],
    //     ),
    //   ),

      child: Scaffold(
        backgroundColor: Colors.transparent,
        // Make scaffold transparent to show gradient
        appBar: null,
        body: Stack(
          children: [
            // Your content can be added here

            // Uncomment if you want to use the wave animation
            // const Center(
            //   child: WaveAnimation(
            //     height: 100,
            //     primaryColor: Color(0xFF8A3FFC),
            //     secondaryColor: Color(0xFF06CAFC),
            //     opacity: 1.0,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // You can keep this method for future use if needed
  Widget buildBackgroundColor() {
    return Container(
      decoration: const BoxDecoration(
        // Optional background image
        image: DecorationImage(
          image: AssetImage('assets/images/bg_dark_blue_grad.jpg'),
          fit: BoxFit.cover,
          opacity: 0,
        ),
      ),
    );
  }
}
