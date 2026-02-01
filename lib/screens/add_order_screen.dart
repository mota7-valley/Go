import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_constants.dart';

class AddOrderScreen extends StatefulWidget {
  final String companyId;
  final String companyName;

  const AddOrderScreen({
    super.key,
    required this.companyId,
    required this.companyName,
  });

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _detailsController = TextEditingController();

  String? _selectedService;
  bool _isLoading = false;

  final List<String> _services = ["خدمة نشر واستهداف", "تفعيل Canva Pro"];

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate() || _selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى ملء كافة البيانات واختيار الخدمة")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('orders').add({
        'userName': _nameController.text.trim(),
        'userPhone': _phoneController.text.trim(),
        'details': _detailsController.text.trim(),
        'serviceName': _selectedService,
        'companyId': widget.companyId,
        'companyName': widget.companyName,
        'status': "قيد المراجعة",
        'createdAt': FieldValue.serverTimestamp(),
        'totalPrice': 0, // سيتم تحديثه من قبل الشركة لاحقاً
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("تم إرسال طلبك بنجاح")));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("خطأ في الإرسال: $e")));
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
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text("طلب خدمة من ${widget.companyName}"),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textMain,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "بيانات مقدم الطلب",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 20),
                _buildTextField(_nameController, "اسمك بالكامل", Icons.person),
                _buildTextField(
                  _phoneController,
                  "رقم الموبايل",
                  Icons.phone,
                  isPhone: true,
                ),

                const SizedBox(height: 20),
                const Text(
                  "اختر الخدمة المطلوبة",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text("اختر من القائمة"),
                      value: _selectedService,
                      items: _services
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedService = val),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                _buildTextField(
                  _detailsController,
                  "تفاصيل إضافية (اختياري)",
                  Icons.note_add,
                  maxLines: 3,
                ),

                const SizedBox(height: 40),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submitOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "إرسال الطلب للشركة",
                          style: TextStyle(fontSize: 18, color: Colors.white),
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
    bool isPhone = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        validator: (v) => v!.isEmpty ? "هذا الحقل مطلوب" : null,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.primary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
