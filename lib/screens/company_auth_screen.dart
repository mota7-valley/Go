import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_constants.dart';

class CompanyAuthScreen extends StatefulWidget {
  const CompanyAuthScreen({super.key});

  @override
  State<CompanyAuthScreen> createState() => _CompanyAuthScreenState();
}

class _CompanyAuthScreenState extends State<CompanyAuthScreen> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  File? _logoFile;

  final cloudinary = CloudinaryPublic('dqyz90nfz', 'tvve8pts', cache: false);

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _logoFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!isLogin && _logoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى اختيار لوجو الشركة")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: "${_phoneController.text.trim()}@gmail.com",
          password: _passwordController.text.trim(),
        );
      } else {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(_logoFile!.path, folder: 'company_logos'),
        );
        String uploadedLogoUrl = response.secureUrl;

        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: "${_phoneController.text.trim()}@gmail.com",
          password: _passwordController.text.trim(),
        );

        await FirebaseFirestore.instance
            .collection('companies')
            .doc(userCredential.user!.uid)
            .set({
          'companyId': userCredential.user!.uid,
          'companyName': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'logoUrl': uploadedLogoUrl,
          'role': 'company',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ: ${e.toString()}")),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLogin ? "دخول الشركات" : "إنشاء حساب شركة جديد",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (!isLogin) ...[
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2)),
                          image: _logoFile != null
                              ? DecorationImage(
                                  image: FileImage(_logoFile!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _logoFile == null
                            ? const Icon(Icons.add_a_photo_outlined,
                                color: AppColors.primary, size: 30)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("لوجو الشركة",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 25),
                    _buildTextField(
                      controller: _nameController,
                      label: "اسم الشركة",
                      icon: Icons.business_rounded,
                    ),
                    const SizedBox(height: 15),
                  ],
                  _buildTextField(
                    controller: _phoneController,
                    label: "رقم الهاتف",
                    icon: Icons.phone_android_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(
                    controller: _passwordController,
                    label: "كلمة المرور",
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                  ),
                  if (!isLogin) ...[
                    const SizedBox(height: 15),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: "إعادة كلمة المرور",
                      icon: Icons.lock_reset_rounded,
                      isPassword: true,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return "كلمات المرور غير متطابقة";
                        }
                        if (value == null || value.isEmpty) {
                          return "هذا الحقل مطلوب";
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 30),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : MaterialButton(
                          onPressed: _submit,
                          color: AppColors.primary,
                          minWidth: double.infinity,
                          height: 55,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            isLogin ? "تسجيل الدخول" : "إنشاء الحساب",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => setState(() => isLogin = !isLogin),
                    child: Text(
                      isLogin
                          ? "ليس لديك حساب شركة؟ سجل الآن"
                          : "لديك حساب بالفعل؟ سجل دخول",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return "هذا الحقل مطلوب";
            }
            return null;
          },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}