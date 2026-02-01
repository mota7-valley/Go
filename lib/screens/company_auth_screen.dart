import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_constants.dart';

class CompanyAuthScreen extends StatefulWidget {
  const CompanyAuthScreen({super.key});

  @override
  State<CompanyAuthScreen> createState() => _CompanyAuthScreenState();
}

class _CompanyAuthScreenState extends State<CompanyAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _companyNameController = TextEditingController();

  bool _isLoading = false;
  bool _isLogin = true;

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        await FirebaseFirestore.instance
            .collection('companies')
            .doc(userCredential.user!.uid)
            .set({
              'companyId': userCredential.user!.uid,
              'companyName': _companyNameController.text.trim(),
              'logoUrl': '',
              'email': _emailController.text.trim(),
              'createdAt': FieldValue.serverTimestamp(),
              'prices': {
                'publish': [0, 100, 200, 300, 400],
                'interaction': [0, 50, 100, 150, 200],
                'followers': [0, 20, 40, 60, 80],
              },
            });
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message = "حدث خطأ ما";
      if (e.code == 'user-not-found') {
        message = "البريد الإلكتروني غير مسجل";
      } else if (e.code == 'wrong-password') {
        message = "كلمة المرور خاطئة";
      } else if (e.code == 'email-already-in-use') {
        message = "هذا البريد مسجل بالفعل";
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(_isLogin ? "تسجيل دخول الشركات" : "تسجيل شركة جديدة"),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(
                  Icons.business_center_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 40),
                if (!_isLogin)
                  _buildTextField(
                    _companyNameController,
                    "اسم الشركة",
                    Icons.business,
                  ),
                _buildTextField(
                  _emailController,
                  "البريد الإلكتروني للشركة",
                  Icons.email,
                ),
                _buildTextField(
                  _passwordController,
                  "كلمة المرور",
                  Icons.lock,
                  isPass: true,
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _handleAuth,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 55),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          _isLogin ? "دخول" : "إنشاء حساب شركة",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  child: Text(
                    _isLogin
                        ? "ليس لديك حساب؟ سجل شركتك الآن"
                        : "لديك حساب بالفعل؟ سجل دخولك",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool isPass = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: ctrl,
        obscureText: isPass,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primary),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (v) => (v == null || v.isEmpty) ? "هذا الحقل مطلوب" : null,
      ),
    );
  }
}
