import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';
import '../core/app_constants.dart';

class AddOrderScreen extends StatefulWidget {
  final String companyId;
  final String companyName;
  final String serviceType;
  final String companyPhone;

  const AddOrderScreen({
    super.key,
    required this.companyId,
    required this.companyName,
    required this.serviceType,
    required this.companyPhone,
  });

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _detailsController = TextEditingController();
  final _linkController = TextEditingController();
  final _budgetController = TextEditingController();

  int _currentStep = 1;
  bool _isLoading = false;
  File? _paymentScreenshot;

  String? _selectedDuration;
  double _calculatedPrice = 0.0;

  final cloudinary = CloudinaryPublic('dqyz90nfz', 'tvve8pts', cache: false);

  final List<Map<String, dynamic>> _canvaOptions = [
    {'title': 'تفعيل Canva Pro لمدة 6 شهور', 'price': 50.0},
    {'title': 'تفعيل Canva Pro لمدة 1 سنة', 'price': 100.0},
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _paymentScreenshot = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitOrder() async {
    if (_paymentScreenshot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى رفع صورة التحويل للتأكيد")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;

      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(_paymentScreenshot!.path,
            folder: 'payment_receipts'),
      );

      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user?.uid,
        'companyId': widget.companyId,
        'companyName': widget.companyName,
        'serviceType': widget.serviceType,
        'userName': _nameController.text.trim(),
        'userPhone': _phoneController.text.trim(),
        'customerEmail': _emailController.text.trim(),
        'details': _detailsController.text.trim(),
        'duration': _selectedDuration,
        'postLink': widget.serviceType == 'facebook'
            ? _linkController.text.trim()
            : null,
        'totalPrice': widget.serviceType == 'canva'
            ? _calculatedPrice
            : double.tryParse(_budgetController.text) ?? 0.0,
        'paymentReceiptUrl': response.secureUrl,
        'status': "قيد المراجعة",
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم إرسال طلبك بنجاح، جاري المراجعة")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطأ: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isCanva = widget.serviceType == 'canva';
    Color themeColor = isCanva ? const Color(0xFF00C4CC) : AppColors.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("طلب خدمة ${isCanva ? 'Canva Pro' : 'نشر واستهداف'}"),
          backgroundColor: Colors.white,
          foregroundColor: themeColor,
          elevation: 0,
          centerTitle: true,
        ),
        body: _currentStep == 1
            ? _buildStepOne(themeColor, isCanva)
            : _buildPaymentStep(themeColor),
      ),
    );
  }

  Widget _buildStepOne(Color color, bool isCanva) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ابدأ حملتك مع ${widget.companyName}",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 25),
            _buildField(
                "الاسم بالكامل", Icons.person_outline, _nameController, color),
            _buildField("رقم الموبايل (واتساب)", Icons.phone_android_outlined,
                _phoneController, color,
                isPhone: true),
            if (isCanva) ...[
              _buildField("الإيميل المراد تفعيله",
                  Icons.alternate_email_rounded, _emailController, color),
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "مدة التفعيل",
                    prefixIcon: Icon(Icons.timer_outlined, color: color),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                  ),
                  hint: const Text("اختر مدة التفعيل"),
                  initialValue: _selectedDuration,
                  items: _canvaOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option['title'],
                      child:
                          Text("${option['title']} (${option['price']} ج.م)"),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedDuration = val;
                      _calculatedPrice = _canvaOptions
                          .firstWhere((e) => e['title'] == val)['price'];
                    });
                  },
                  validator: (v) => v == null ? "يرجى اختيار المدة" : null,
                ),
              ),
            ],
            if (!isCanva) ...[
              _buildField(
                  "رابط المنشور", Icons.link_rounded, _linkController, color),
              _buildField("الميزانية المقترحة", Icons.payments_outlined,
                  _budgetController, color,
                  isPhone: true),
            ],
            _buildField("ملاحظات إضافية", Icons.edit_note_rounded,
                _detailsController, color,
                maxLines: 3),
            const SizedBox(height: 20),
            if (isCanva && _calculatedPrice > 0)
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("المبلغ الكلي:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("$_calculatedPrice ج.م",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: color)),
                  ],
                ),
              ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() => _currentStep = 2);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text(
                "التالي (الانتقال للدفع)",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStep(Color color) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet_rounded, size: 80, color: color),
          const SizedBox(height: 20),
          const Text("تأكيد عملية الدفع",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          _buildPaymentInfoCard(color),
          const SizedBox(height: 30),
          InkWell(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
                border:
                    Border.all(color: color.withValues(alpha: 0.4), width: 1),
              ),
              child: _paymentScreenshot == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined,
                            size: 40, color: color),
                        const Text("ارفع صورة التحويل هنا")
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(_paymentScreenshot!, fit: BoxFit.cover),
                    ),
            ),
          ),
          const SizedBox(height: 40),
          _isLoading
              ? CircularProgressIndicator(color: color)
              : ElevatedButton(
                  onPressed: _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text(
                    "تأكيد وإرسال الطلب",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
          TextButton(
            onPressed: () => setState(() => _currentStep = 1),
            child: Text("الرجوع لتعديل البيانات",
                style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard(Color color) {
    String priceToShow = widget.serviceType == 'canva'
        ? "$_calculatedPrice"
        : _budgetController.text;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("المبلغ المطلوب:"),
              Text(
                "$priceToShow ج.م",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              )
            ],
          ),
          const Divider(height: 30),
          const Text("رقم التحويل النقدي (فودافون كاش / غيره)"),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.companyPhone,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 1.2),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.companyPhone));
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("تم نسخ الرقم")));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField(
      String hint, IconData icon, TextEditingController controller, Color color,
      {bool isPhone = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        validator: (v) => v!.isEmpty ? "هذا الحقل مطلوب" : null,
        decoration: InputDecoration(
          labelText: hint,
          prefixIcon: Icon(icon, color: color),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: color)),
        ),
      ),
    );
  }
}
