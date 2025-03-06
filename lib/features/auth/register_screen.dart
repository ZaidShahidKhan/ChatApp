import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool agreeToTerms = false;
  late AnimationController _waveController;
  double passwordStrength = 0.4; // Initial password strength (medium)
  bool isRegistering = false;

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
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
              // Apply top margin here
              child: _buildRegisterContainer(),

            ),
          ),

        ],
      ),
    );
  }

  Widget _buildBackgroundWaves() {
    return Opacity(
      opacity: 0.1,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_dark_blue.jpg'),
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

  Widget _buildRegisterContainer() {
    return SingleChildScrollView( // Ensure scrolling
      child: Container(
        width: 400,  // Keep width fixed
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // image: DecorationImage(
          //   image: AssetImage("assets/images/bg_dark_blue.jpg"),
          //   fit: BoxFit.cover,
          // ),
          color: const Color(0xFF0A1829).withOpacity(0.7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 35,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Prevent overflow
              children: [
                SizedBox(height: 40,),
                _buildLogo(),
                const SizedBox(height: 30),
                _buildRegisterTitle(),
                const SizedBox(height: 25),
                _buildNameFields(),
                const SizedBox(height: 20),
                _buildEmailField(),
                const SizedBox(height: 20),
                _buildPasswordField(),
                const SizedBox(height: 20),
                _buildConfirmPasswordField(),
                const SizedBox(height: 24),
                _buildTermsCheckbox(),
                const SizedBox(height: 24),
                _buildRegisterButton(),
                _buildDivider(),
                _buildSocialRegister(),
                _buildLoginLink(),
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
        const SizedBox(width: 15),
        Padding(
          padding: const EdgeInsets.only(top: 20), // Moves text slightly downward
          child: const Text(
            'KENVERSE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,fontFamily: 'Mokoto',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedLogoIcon() {
    return SizedBox(
      width: 25,
      height: 35,
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return CustomPaint(
            painter: AnimatedBarsPainter(animation: _waveController),
          );
        },
      ),
    );
  }

  Widget _buildRegisterTitle() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Create your account',
        style: TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }


  Widget _buildNameFields() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'First Name',
                style: TextStyle(
                  color: Color(0xB3FFFFFF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: firstNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'First name',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  prefixIcon: const Icon(Icons.person_outline, color: Color(0x66FFFFFF)),
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
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Last Name',
                style: TextStyle(
                  color: Color(0xB3FFFFFF),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: lastNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Last name',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  prefixIcon: const Icon(Icons.person_outline, color: Color(0x66FFFFFF)),
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
          ),
        ),
      ],
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
            hintText: 'Your email address',
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

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create Password',
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
          onChanged: (value) {
            // Simple password strength calculation
            if (value.length < 6) {
              setState(() => passwordStrength = 0.2);
            } else if (value.length < 10) {
              setState(() => passwordStrength = 0.4);
            } else if (RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
              setState(() => passwordStrength = 0.8);
            } else {
              setState(() => passwordStrength = 0.6);
            }
          },
          decoration: InputDecoration(
            hintText: 'Create a strong password',
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
        const SizedBox(height: 8),
        _buildPasswordStrengthIndicator(),
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    String strengthText = "Weak";
    Color indicatorColor = const Color(0xFFFF6B6B);

    if (passwordStrength > 0.7) {
      strengthText = "Strong";
      indicatorColor = const Color(0xFF06CAFC);
    } else if (passwordStrength > 0.3) {
      strengthText = "Medium";
      indicatorColor = const Color(0xFFFFD166);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: double.infinity,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: passwordStrength,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF8A3FFC), indicatorColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          strengthText + " strength",
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirm Password',
          style: TextStyle(
            color: Color(0xB3FFFFFF),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: confirmPasswordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Confirm your password',
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

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: agreeToTerms,
            onChanged: (bool? value) {
              setState(() {
                agreeToTerms = value ?? false;
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(color: Colors.white.withOpacity(0.2)),
            activeColor: const Color(0xFF8A3FFC),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: 'I agree to the ',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: 'Terms of Service',
                  style: const TextStyle(
                    color: Color(0xFF06CAFC),
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(
                    color: Color(0xFF06CAFC),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
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
            isRegistering = true;
          });

          try {
            // Get values from text controllers
            final firstName = firstNameController.text.trim();
            final lastName = lastNameController.text.trim();
            final email = emailController.text.trim();
            final password = passwordController.text.trim();

            // Validate inputs
            if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill in all fields')),
              );
              return;
            }

            // Validate email format
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid email address')),
              );
              return;
            }

            // Validate password strength (minimum 6 characters)
            if (password.length < 6) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password must be at least 6 characters long')),
              );
              return;
            }

            // Create user with email and password
            final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: email,
              password: password,
            );

            // If registration successful, save additional user information
            if (userCredential.user != null) {
              // Create a user profile in Firestore
              await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                'firstName': firstName,
                'lastName': lastName,
                'email': email,
                'createdAt': FieldValue.serverTimestamp(),
              });

              // Update user display name
              await userCredential.user!.updateDisplayName('$firstName $lastName');

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account created successfully!')),
              );

              // Navigate to home screen or login screen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          } on FirebaseAuthException catch (e) {
            // Handle specific Firebase auth errors
            String errorMessage = 'Registration failed';

            if (e.code == 'weak-password') {
              errorMessage = 'The password provided is too weak';
            } else if (e.code == 'email-already-in-use') {
              errorMessage = 'An account already exists for this email';
            } else if (e.code == 'invalid-email') {
              errorMessage = 'Invalid email format';
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMessage)),
            );
          } catch (e) {
            // Handle other exceptions
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Registration failed: ${e.toString()}')),
            );
          } finally {
            // Hide loading indicator
            setState(() {
              isRegistering = false;
            });
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: isRegistering
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'Create Account',
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
      padding: const EdgeInsets.symmetric(vertical: 24),
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
              'or register with',
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

  Widget _buildSocialRegister() {
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

  Widget _buildLoginLink() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Already have an account?",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.only(left: 5),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Sign in',
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

// Reused from the login screen
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

// -----------------------------------
// To integrate this with the login screen, add the following navigation code to the login screen:
//
// In the _buildSignupLink() method of the LoginScreen class, update the onPressed callback:
//
// TextButton(
//   onPressed: () {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const RegisterScreen()),
//     );
//   },
//   style: TextButton.styleFrom(
//     padding: const EdgeInsets.only(left: 5),
//     minimumSize: Size.zero,
//     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//   ),
//   child: const Text(
//     'Sign up',
//     style: TextStyle(
//       color: Color(0xFF06CAFC),
//       fontSize: 14,
//       fontWeight: FontWeight.w500,
//     ),
//   ),
// ),