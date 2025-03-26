import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kenz_chat/features/auth/pending_screen.dart';
import 'dart:async';
import 'dart:math' as math;
import 'home_screen.dart';
import 'package:kenz_chat/features/auth/register_screen.dart'; // Correct

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KENVOICE Login',
      theme: ThemeData(
        fontFamily: 'Segoe UI',
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}



class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool rememberMe = false;
  late AnimationController _waveController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1829),
      body: Stack(
        children: [
          _buildBackgroundWaves(),
          _buildWaveform(),
          Center(
            child: SingleChildScrollView(
              child: _buildLoginContainer(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundWaves() {
    return Opacity(
      opacity: 1,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg_dark_blue_grad.jpg"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildWaveform() {
    return Align(
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 100),
            painter: WaveformPainter(
              animation: _waveController,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginContainer() {
    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: 400,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg_dark_blue_grad.jpg"),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF0A1829).withOpacity(0.7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 35,
              offset: const Offset(0, 15),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: const Color(0xFF8A3FFC).withOpacity(0.1),
              blurRadius: 1,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 80,),
                _buildLogo(),
                const SizedBox(height: 40),
                _buildEmailField(),
                const SizedBox(height: 24),
                _buildPasswordField(),
                const SizedBox(height: 20),
                _buildOptions(),
                const SizedBox(height: 30),
                _buildLoginButton(),
                _buildDivider(),
                _buildSocialLogin(),
                _buildSignupLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAnimatedLogoIcon(),
        const SizedBox(width: 12),
        const Text(
          'TKENNEKT',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,fontFamily: 'Mokoto',
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedLogoIcon() {
    return SizedBox(
      width: 30,
      height: 40,
      child: CustomPaint(
        painter: LogoPainter(),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email Address',
          style: TextStyle(
            color: Color(0xB3FFFFFF),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your email',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            prefixIcon: const Icon(Icons.email_outlined, color: Color(0x66FFFFFF)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFFA76CFF).withOpacity(0.5),
                width: 2, // Increased border thickness
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            color: Color(0xB3FFFFFF),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your password',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0x66FFFFFF)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:  BorderSide(
                color: const Color(0xFFA76CFF).withOpacity(0.5),
                width: 2, // Increased border thickness
              )
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: rememberMe,
                onChanged: (bool? value) {
                  setState(() {
                    rememberMe = value ?? false;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: BorderSide(color: Colors.white.withOpacity(0.2)),
                activeColor: const Color(0xFF8A3FFC),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Remember me',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Forgot Password?',
            style: TextStyle(
              color: Color(0xFF06CAFC),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF8A3FFC), Color(0xFF06CAFC)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8A3FFC).withOpacity(0.3),
            offset: const Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: MaterialButton(
        onPressed: () async {
          // Show loading indicator
          setState(() {
            isLoading = true;
          });

          try {
            // Get values from text controllers
            final email = emailController.text.trim();
            final password = passwordController.text.trim();

            // Validate inputs
            if (email.isEmpty || password.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter both email and password')),
              );
              setState(() {
                isLoading = false;
              });
              return;
            }

            // Perform authentication with Firebase
            final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email,
              password: password,
            );

            // If authentication successful, check user status in Firestore
            if (userCredential.user != null) {
              final String uid = userCredential.user!.uid;

              // Get user data from Firestore
              final DocumentSnapshot userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .get();

              if (userDoc.exists) {
                final userData = userDoc.data() as Map<String, dynamic>;
                final String? userStatus = userData['status'] as String?;
                final String? userRole = userData['role'] as String?;

                // Route based on status and role
                if (userStatus == 'active') {
                  // User is active, check role
                  if (userRole == 'admin' || userRole == 'manager') {
                    // Navigate to HomeScreen for admin/manager
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  } else {
                    // Navigate to HomeScreen for regular members too (or another screen if needed)
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  }
                } else {
                  // User is pending or has another status
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const PendingScreen()),
                  );
                }
              } else {
                // If user document doesn't exist in Firestore
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User profile not found')),
                );

                // Default to PendingScreen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const PendingScreen()),
                );
              }
            }
          } on FirebaseAuthException catch (e) {
            // Handle specific Firebase auth errors
            String errorMessage = 'An error occurred during login';

            if (e.code == 'user-not-found') {
              errorMessage = 'No user found with this email';
            } else if (e.code == 'wrong-password') {
              errorMessage = 'Incorrect password';
            } else if (e.code == 'invalid-email') {
              errorMessage = 'Invalid email format';
            } else if (e.code == 'user-disabled') {
              errorMessage = 'This account has been disabled';
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage)),
            );
          } catch (e) {
            // Handle other exceptions
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Login failed: ${e.toString()}')),
            );
          } finally {
            // Hide loading indicator
            setState(() {
              isLoading = false;
            });
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'Sign In',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'or continue with',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(Icons.facebook),
        const SizedBox(width: 16),
        _buildSocialButton(Icons.chat_bubble_outline),
        const SizedBox(width: 16),
        _buildSocialButton(Icons.g_mobiledata_rounded),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: IconButton(
        icon: Icon(icon),
        color: Colors.white,
        onPressed: () {},
      ),
    );
  }

  Widget _buildSignupLink() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account?",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          TextButton(
            onPressed: () { Navigator.push(
              context,
                  MaterialPageRoute(builder: (context) => RegisterScreen()),
            );},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.only(left: 5),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Sign up',
              style: TextStyle(
                color: Color(0xFF06CAFC),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final Animation<double> animation;

  WaveformPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final centerY = height / 2;

    // Main horizontal line
    final linePaint = Paint()
      ..color = const Color(0xFF8A3FFC).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final linearGradient = LinearGradient(
      colors: [
        const Color(0xFF8A3FFC).withOpacity(0),
        const Color(0xFF8A3FFC).withOpacity(0.5),
        const Color(0xFF8A3FFC).withOpacity(0),
      ],
      stops: const [0.0, 0.5, 1.0],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final rect = Rect.fromLTWH(0, centerY - 1, width, 2);
    linePaint.shader = linearGradient.createShader(rect);

    canvas.drawLine(
      Offset(0, centerY),
      Offset(width, centerY),
      linePaint,
    );

    // Animated wave above the line
    final wavePaint = Paint()
      ..color = const Color(0xFF06CAFC).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final waveGradient = LinearGradient(
      colors: [
        const Color(0xFF06CAFC).withOpacity(0),
        const Color(0xFF06CAFC).withOpacity(0.3),
        const Color(0xFF06CAFC).withOpacity(0),
      ],
      stops: const [0.0, 0.5, 1.0],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final waveRect = Rect.fromLTWH(0, centerY - 20, width, 40);
    wavePaint.shader = waveGradient.createShader(waveRect);

    final path = Path();
    path.moveTo(0, centerY - 10);

    for (double i = 0; i <= width; i++) {
      path.lineTo(
        i,
        centerY - 10 + math.sin((i * 0.05) - (animation.value * math.pi * 2)) * 10,
      );
    }

    canvas.drawPath(path, wavePaint);

    // Second wave (more blurred)
    final wavePaint2 = Paint()
      ..color = const Color(0xFF06CAFC).withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final waveGradient2 = LinearGradient(
      colors: [
        const Color(0xFF06CAFC).withOpacity(0),
        const Color(0xFF06CAFC).withOpacity(0.2),
        const Color(0xFF06CAFC).withOpacity(0),
      ],
      stops: const [0.0, 0.5, 1.0],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final waveRect2 = Rect.fromLTWH(0, centerY - 40, width, 80);
    wavePaint2.shader = waveGradient2.createShader(waveRect2);

    final path2 = Path();
    path2.moveTo(0, centerY - 20);

    for (double i = 0; i <= width; i++) {
      path2.lineTo(
        i,
        centerY - 20 + math.sin((i * 0.03) - ((animation.value + 0.5) * math.pi * 2)) * 20,
      );
    }

    canvas.drawPath(path2, wavePaint2);
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) => true;
}

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rectWidth = 5.0;
    final rectRadius = 2.0;
    final paint = Paint()..style = PaintingStyle.fill;

    // First bar
    paint.color = const Color(0xFF8A3FFC);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.3, rectWidth, size.height * 0.4),
        Radius.circular(rectRadius),
      ),
      paint,
    );

    // Second bar
    paint.color = const Color(0xFFA66BFD);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rectWidth * 1.5, size.height * 0.2, rectWidth, size.height * 0.6),
        Radius.circular(rectRadius),
      ),
      paint,
    );

    // Third bar
    paint.color = const Color(0xFFC29AFC);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rectWidth * 3, size.height * 0.1, rectWidth, size.height * 0.8),
        Radius.circular(rectRadius),
      ),
      paint,
    );

    // Fourth bar
    paint.color = const Color(0xFF06CAFC);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rectWidth * 4.5, size.height * 0.25, rectWidth, size.height * 0.5),
        Radius.circular(rectRadius),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Animation for the wave bars in the logo
class AnimatedBarsPainter extends CustomPainter {
  final Animation<double> animation;

  AnimatedBarsPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rectWidth = 5.0;
    final rectRadius = 2.0;
    final paint = Paint()..style = PaintingStyle.fill;

    // Animate the heights
    final height1 = size.height * (0.4 + 0.2 * math.sin(animation.value * math.pi));
    final height2 = size.height * (0.6 + 0.2 * math.sin((animation.value + 0.25) * math.pi));
    final height3 = size.height * (0.8 + 0.1 * math.sin((animation.value + 0.5) * math.pi));
    final height4 = size.height * (0.5 + 0.2 * math.sin((animation.value + 0.75) * math.pi));

    // First bar
    paint.color = const Color(0xFF8A3FFC);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height - height1, rectWidth, height1),
        Radius.circular(rectRadius),
      ),
      paint,
    );

    // Second bar
    paint.color = const Color(0xFFA66BFD);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rectWidth * 1.5, size.height - height2, rectWidth, height2),
        Radius.circular(rectRadius),
      ),
      paint,
    );

    // Third bar
    paint.color = const Color(0xFFC29AFC);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rectWidth * 3, size.height - height3, rectWidth, height3),
        Radius.circular(rectRadius),
      ),
      paint,
    );

    // Fourth bar
    paint.color = const Color(0xFF06CAFC);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rectWidth * 4.5, size.height - height4, rectWidth, height4),
        Radius.circular(rectRadius),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(AnimatedBarsPainter oldDelegate) => true;
}

// Add this to your pubspec.yaml:
/*
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  google_fonts: ^4.0.0


flutter:
  uses-material-design: true
  assets:
    - assets/background_pattern.png
*/

// Note: You'll need to create or download a suitable background_pattern.png
// with the pattern similar to the one used in the HTML version