import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../core/app_constants.dart';

class EditOrderScreen extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic> currentData;

  const EditOrderScreen({
    super.key,
    required this.orderId,
    required this.currentData,
  });

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _detailsController;
  late TextEditingController _linkController;
  late TextEditingController _budgetController;

  File? _newReceiptImage;
  String? _selectedDuration;
  double _calculatedPrice = 0.0;
  bool _isLoading = false;

  final cloudinary = CloudinaryPublic('dqyz90nfz', 'tvve8pts', cache: false);

  final List<Map<String, dynamic>> _canvaOptions = [
    {'title': 'تفعيل Canva Pro لمدة 6 شهور', 'price': 50.0},
    {'title': 'تفعيل Canva Pro لمدة 1 سنة', 'price': 100.0},
  ];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.currentData['userName']);
    _phoneController =
        TextEditingController(text: widget.currentData['userPhone']);
    _emailController =
        TextEditingController(text: widget.currentData['customerEmail'] ?? "");
    _detailsController =
        TextEditingController(text: widget.currentData['details'] ?? "");
    _linkController =
        TextEditingController(text: widget.currentData['postLink'] ?? "");
    _budgetController = TextEditingController(
        text: widget.currentData['totalPrice']?.toString() ?? "0.0");

    _selectedDuration = widget.currentData['duration'];
    _calculatedPrice =
        (widget.currentData['totalPrice'] as num?)?.toDouble() ?? 0.0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _detailsController.dispose();
    _linkController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _pickNewReceipt() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _newReceiptImage = File(pickedFile.path));
    }
  }

  Future<void> _updateOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      String? receiptUrl = widget.currentData['paymentReceiptUrl'];

      if (_newReceiptImage != null) {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(_newReceiptImage!.path,
              folder: 'payment_receipts'),
        );
        receiptUrl = response.secureUrl;
      }

      Map<String, dynamic> updatedData = {
        'userName': _nameController.text.trim(),
        'userPhone': _phoneController.text.trim(),
        'details': _detailsController.text.trim(),
        'paymentReceiptUrl': receiptUrl,
      };

      if (widget.currentData['serviceType'] == 'canva') {
        updatedData['customerEmail'] = _emailController.text.trim();
        updatedData['duration'] = _selectedDuration;
        updatedData['totalPrice'] = _calculatedPrice;
      } else {
        updatedData['postLink'] = _linkController.text.trim();
        updatedData['totalPrice'] =
            double.tryParse(_budgetController.text.trim()) ?? 0.0;
      }

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update(updatedData);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تحديث البيانات بنجاح")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطأ في التحديث: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isCanva = widget.currentData['serviceType'] == 'canva';
    Color themeColor = isCanva ? const Color(0xFF00C4CC) : AppColors.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("تعديل الطلب"),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: themeColor,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(themeColor),
                const SizedBox(height: 25),
                _buildField("الاسم بالكامل", Icons.person_outline,
                    _nameController, themeColor),
                _buildField("رقم الموبايل", Icons.phone_android_outlined,
                    _phoneController, themeColor,
                    isPhone: true),
                if (isCanva) ...[
                  _buildField(
                      "الإيميل المطلوب تفعيله",
                      Icons.alternate_email_rounded,
                      _emailController,
                      themeColor),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "مدة التفعيل",
                        prefixIcon:
                            Icon(Icons.timer_outlined, color: themeColor),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none),
                      ),
                      initialValue: _selectedDuration,
                      items: _canvaOptions.map((option) {
                        return DropdownMenuItem<String>(
                          value: option['title'],
                          child: Text(
                              "${option['title']} (${option['price']} ج.م)"),
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
                  _buildField("رابط المنشور", Icons.link_rounded,
                      _linkController, themeColor),
                  _buildField("الميزانية", Icons.payments_outlined,
                      _budgetController, themeColor,
                      isPhone: true),
                ],
                _buildField("ملاحظات إضافية", Icons.edit_note_rounded,
                    _detailsController, themeColor,
                    maxLines: 3),
                const SizedBox(height: 10),
                const Text("إيصال الدفع:",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _pickNewReceipt,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: _newReceiptImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(_newReceiptImage!,
                                fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload_outlined,
                                  color: themeColor, size: 40),
                              const Text("تغيير صورة الإيصال (اختياري)",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: themeColor))
                    : ElevatedButton(
                        onPressed: _updateOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          minimumSize: const Size(double.infinity, 60),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text(
                          "حفظ التعديلات",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "يمكنك تعديل البيانات الأساسية أو تحديث صورة الإيصال إذا قمت برفع صورة خاطئة.",
              style: TextStyle(fontSize: 12),
            ),
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
