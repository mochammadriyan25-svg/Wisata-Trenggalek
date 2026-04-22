import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
const RegisterScreen({super.key});

@override
State<RegisterScreen> createState() =>
_RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

final AuthService _authService = AuthService();

final TextEditingController nameController =
TextEditingController();

final TextEditingController emailController =
TextEditingController();

final TextEditingController passwordController =
TextEditingController();

final TextEditingController confirmController =
TextEditingController();

bool agree = false;
bool isLoading = false;

void register() async {

if (!agree) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Please agree to the terms"),
    ),
  );
  return;
}

if (passwordController.text != confirmController.text) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Password tidak sama"),
    ),
  );
  return;
}

setState(() => isLoading = true);

try {

  await _authService.registerUser(
    emailController.text.trim(),
    passwordController.text.trim(),
  );

  if (!mounted) return;

  Navigator.pushReplacementNamed(
    context,
    '/login',
  );

} catch (e) {

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Register gagal"),
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

InputDecoration inputStyle(
String hint, IconData icon) {

return InputDecoration(
  hintText: hint,
  filled: true,
  fillColor: Colors.white,
  suffixIcon: Icon(icon),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  ),
);

}

@override
Widget build(BuildContext context) {

return Scaffold(
  backgroundColor: const Color(0xFFF6F8F7),

  body: SafeArea(

    child: SingleChildScrollView(

      child: Column(
        children: [

          // HEADER
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [

                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),

                const Expanded(
                  child: Center(
                    child: Text(
                      "Virtual Tourism Trenggalek",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 48),
              ],
            ),
          ),

          // HERO IMAGE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Create Account",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            "Join us to explore the hidden gems of Trenggalek",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),

            child: Column(
              children: [

                // NAME
                TextField(
                  controller: nameController,
                  decoration:
                      inputStyle("Name", Icons.person),
                ),

                const SizedBox(height: 14),

                // EMAIL
                TextField(
                  controller: emailController,
                  decoration:
                      inputStyle("hello@example.com", Icons.mail),
                ),

                const SizedBox(height: 14),

                // PASSWORD
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration:
                      inputStyle("Password", Icons.lock),
                ),

                const SizedBox(height: 14),

                // CONFIRM
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration:
                      inputStyle("Confirm Password", Icons.shield),
                ),

                const SizedBox(height: 14),

                // TERMS
                Row(
                  children: [

                    Checkbox(
                      value: agree,
                      activeColor: const Color(0xFF13EC80),
                      onChanged: (value) {
                        setState(() {
                          agree = value!;
                        });
                      },
                    ),

                    const Expanded(
                      child: Text(
                        "I agree to the Terms and Conditions",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // REGISTER BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF13EC80),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [

                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade300,
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("OR"),
                    ),

                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // GUEST
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: guestLogin,
                    icon: const Icon(Icons.explore),
                    label: const Text(
                      "Continue as Guest",
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // LOGIN LINK
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [

                    const Text(
                      "Already have an account?",
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Color(0xFF13EC80),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          const Text(
            "© 2026 Virtual Tourism Trenggalek",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    ),
  ),
);

}
}