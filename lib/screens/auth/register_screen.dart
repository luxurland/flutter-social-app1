import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../../utils/aes128.dart';
import '../../widgets/animated_liquid_background.dart';
import '../../widgets/glass_field.dart';

class RegisterScreen extends StatefulWidget {
  final ApiService api;
  const RegisterScreen({super.key, required this.api});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  DateTime? dob;

  bool loading = false;

  Future<void> pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year - 18, now.month, now.day),
    );
    if (picked != null) {
      setState(() => dob = picked);
    }
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> register() async {
    if (passCtrl.text != confirmCtrl.text) {
      showError("Passwords do not match");
      return;
    }
    if (dob == null) {
      showError("Select your date of birth");
      return;
    }

    final age = DateTime.now().year - dob!.year;
    if (age < 18) {
      showError("You must be 18+");
      return;
    }

    setState(() => loading = true);

    final encryptedEmail = AES128.encrypt(emailCtrl.text.trim());
    final encryptedPassword = AES128.encrypt(passCtrl.text);

    final res = await widget.api.post("/auth/register", {
      "email": encryptedEmail,
      "password": encryptedPassword,
      "name": nameCtrl.text.trim(),
      "date_of_birth": dob!.toIso8601String(),
    });

    setState(() => loading = false);

    if (res["success"] == true) {
      Navigator.pushNamed(
        context,
        "/verify_email",
        arguments: emailCtrl.text.trim(),
      );
    } else {
      showError(res["error"] ?? "Registration failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedLiquidBackground(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GlassField(
                    controller: emailCtrl,
                    hint: "Email",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  GlassField(
                    controller: passCtrl,
                    hint: "Password",
                    obscure: true,
                  ),
                  const SizedBox(height: 12),
                  GlassField(
                    controller: confirmCtrl,
                    hint: "Confirm password",
                    obscure: true,
                  ),
                  const SizedBox(height: 12),
                  GlassField(
                    controller: nameCtrl,
                    hint: "Name",
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: pickDob,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          Icon(Icons.cake, color: Colors.white.withOpacity(0.7)),
                          const SizedBox(width: 12),
                          Text(
                            dob == null
                                ? "Date of birth (18+)"
                                : "${dob!.year}-${dob!.month.toString().padLeft(2, '0')}-${dob!.day.toString().padLeft(2, '0')}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: loading ? null : register,
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              "Sign up",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/login");
                    },
                    child: const Text(
                      "Already have an account? Log in",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
