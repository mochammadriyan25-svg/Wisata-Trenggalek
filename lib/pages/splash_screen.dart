import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(
        context,
        '/login',
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget loadingDot(int index) {
    return ScaleTransition(
      scale: Tween(begin: 0.5, end: 1.2).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.2,
            1,
            curve: Curves.easeInOut,
          ),
        ),
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: Colors.green.shade600,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [
              Color(0xFFE8F5E9), // soft hijau
              Colors.white
            ],
          ),
        ),

        child: Stack(
          children: [



            Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [

                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green
                              .withOpacity(0.2),
                          blurRadius: 30,
                          offset:
                              const Offset(0, 15),
                        )
                      ],
                    ),

                    child: const Icon(
                      Icons.travel_explore,
                      size: 70,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    "Virtual",
                    style: TextStyle(
                      fontSize: 34,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "Tourism",
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 4,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Text(
                    "TRENGGALEK",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [

                      Container(
                        width: 30,
                        height: 1,
                        color: Colors.grey.shade300,
                      ),

                      const Padding(
                        padding:
                            EdgeInsets.symmetric(
                                horizontal: 10),
                        child: Text(
                          "EAST JAVA",
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 3,
                            color: Colors.grey,
                          ),
                        ),
                      ),

                      Container(
                        width: 30,
                        height: 1,
                        color: Colors.grey.shade300,
                      ),
                    ],
                  ),

                  const SizedBox(height: 60),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      loadingDot(0),
                      const SizedBox(width: 8),
                      loadingDot(1),
                      const SizedBox(width: 8),
                      loadingDot(2),
                    ],
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    "PREPARING YOUR JOURNEY",
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 3,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "TRENGGALEK TOURISM BOARD • v2.0.0",
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}