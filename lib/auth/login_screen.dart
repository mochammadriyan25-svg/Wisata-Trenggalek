import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
const LoginScreen({super.key});

@override
State<LoginScreen> createState() =>
_LoginScreenState();
}

class _LoginScreenState
extends State<LoginScreen> {

final _emailController =
TextEditingController();

final _passwordController =
TextEditingController();

final AuthService _authService =
AuthService();

bool isLoading = false;
bool obscure = true;

void login() async {

setState(() => isLoading = true);

try {

  await _authService.loginUser(
    _emailController.text.trim(),
    _passwordController.text.trim(),
  );

  if (!mounted) return;

  Navigator.pushReplacementNamed(
    context,
    '/home_screen',
  );

} catch (e) {

  ScaffoldMessenger.of(context)
      .showSnackBar(
    SnackBar(
      content: Text("Login gagal"),
    ),
  );

}

setState(() => isLoading = false);

}

void guestLogin() {

Navigator.pushReplacementNamed(
  context,
  '/home_screen',
);

}

@override
Widget build(BuildContext context) {

return Scaffold(
  backgroundColor:
      const Color(0xFFF6F8F7),

  body: Center(

    child: Container(

      margin:
          const EdgeInsets.all(16),

      constraints:
          const BoxConstraints(
        maxWidth: 420,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.08),
            blurRadius: 20,
          )
        ],
      ),

      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [

          // ================= HEADER =================
          Container(
            padding:
                const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [

                const SizedBox(width: 40),

                Row(
                  children: [

                    Container(
                      width: 32,
                      height: 32,
                      decoration:
                          BoxDecoration(
                        color: Colors.green,
                        borderRadius:
                            BorderRadius
                                .circular(8),
                      ),
                      child: const Icon(
                        Icons.travel_explore,
                        size: 18,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(width: 8),

                    const Text(
                      "Trenggalek VR",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    )
                  ],
                ),

                const SizedBox(width: 40),
              ],
            ),
          ),

          // ================= IMAGE =================
          Padding(
            padding:
                const EdgeInsets.symmetric(
                    horizontal: 16),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(12),
              child: Image.network(
                "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ================= TEXT =================
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  "Explore the hidden gems of Trenggalek from your screen.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // ================= FORM =================
          Padding(
            padding:
                const EdgeInsets.symmetric(
                    horizontal: 16),
            child: Column(
              children: [

                // EMAIL
                TextField(
                  controller:
                      _emailController,
                  decoration:
                      InputDecoration(
                    labelText:
                        "Email Address",
                    prefixIcon:
                        const Icon(
                            Icons.mail),
                    filled: true,
                    fillColor:
                        Colors.grey
                            .shade100,
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                                  10),
                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // PASSWORD
                TextField(
                  controller:
                      _passwordController,
                  obscureText: obscure,
                  decoration:
                      InputDecoration(
                    labelText:
                        "Password",
                    prefixIcon:
                        const Icon(
                            Icons.lock),
                    suffixIcon:
                        IconButton(
                      icon: Icon(
                        obscure
                            ? Icons
                                .visibility_off
                            : Icons
                                .visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscure =
                              !obscure;
                        });
                      },
                    ),
                    filled: true,
                    fillColor:
                        Colors.grey
                            .shade100,
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                                  10),
                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // LOGIN BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child:
                      ElevatedButton(
                    onPressed:
                        isLoading
                            ? null
                            : login,
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          const Color(
                              0xFF13EC80),
                      foregroundColor:
                          Colors.black,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            "Login",
                            style: TextStyle(
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Or continue with",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 12),

                // GOOGLE BUTTON (UI ONLY)
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child:
                      OutlinedButton(
                    onPressed: () {},
                    child:
                        const Text(
                      "Google",
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // GUEST BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child:
                      OutlinedButton(
                    onPressed:
                        guestLogin,
                    child:
                        const Text(
                      "Continue as Guest",
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // ================= FOOTER =================
          Container(
            padding:
                const EdgeInsets.all(16),
            decoration:
                BoxDecoration(
              color: Colors
                  .grey.shade100,
              borderRadius:
                  const BorderRadius.vertical(
                bottom:
                    Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .center,
              children: [

                const Text(
                    "Don't have an account? "),

                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/register',
                    );
                  },
                  child: const Text(
                    "Register",
                    style: TextStyle(
                      color: Color(
                          0xFF13EC80),
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);

}
}