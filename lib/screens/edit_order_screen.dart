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
  late TextEditingController _linkController;

  int _publishIndex = 0;
  final List<int> _publishPrices = [0, 100, 200, 400, 600];
  final List<String> _publishLabels = ["0", "برونزي", "فضي", "ذهبي", "ماسي"];

  int _interactionIndex = 0;
  final List<int> _interactionPrices = [0, 30, 60, 90, 120];
  final List<String> _interactionLabels = [
    "0",
    "برونزي",
    "فضي",
    "ذهبي",
    "ماسي",
  ];

  int _followersIndex = 0;
  final List<int> _followersPrices = [0, 10, 20, 30, 40];
  final List<String> _followersLabels = [
    "0",
    "250 متابع",
    "500 متابع",
    "750 متابع",
    "1000 متابع",
  ];

  late String _selectedOffer;
  final Map<String, int> _offers = {
    "بدون عرض": 0,
    "عرض: 500 إعجاب مع 200 تعليق و 200 مشاركة (30ج)": 30,
    "عرض: 500 إعجاب مع 500 متابعة (30ج)": 30,
    "عرض: 500 إعجاب مع 500 تعليق مخفي (30ج)": 30,
  };

  final List<String> _governorates = [
    "الوادي الجديد",
    "أسيوط",
    "سوهاج",
    "المنيا",
    "أسوان",
    "الأقصر",
    "قنا",
    "البحر الأحمر",
    "بني سويف",
    "الفيوم",
    "الجيزة",
    "القاهرة",
    "القليوبية",
    "المنوفية",
    "الغربية",
    "الدقهلية",
    "الشرقية",
    "دمياط",
    "بورسعيد",
    "الإسماعيلية",
    "السويس",
    "كفر الشيخ",
    "البحيرة",
    "الإسكندرية",
    "مطروح",
    "شمال سيناء",
    "جنوب سيناء",
  ];
  Set<String> _selectedGovs = {};

  File? _newImage;
  bool _isUpdating = false;
  final ImagePicker _picker = ImagePicker();
  final cloudinary = CloudinaryPublic('dqyz90nfz', 'tvve8pts', cache: false);

  int get _totalAmount {
    return _publishPrices[_publishIndex] +
        _interactionPrices[_interactionIndex] +
        _followersPrices[_followersIndex] +
        (_offers[_selectedOffer] ?? 0);
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.currentData['userName'] ?? "",
    );
    _phoneController = TextEditingController(
      text: widget.currentData['userPhone'] ?? "",
    );
    _linkController = TextEditingController(
      text: widget.currentData['postLink'] ?? "",
    );
    _publishIndex = widget.currentData['publishIndex'] ?? 0;
    _interactionIndex = widget.currentData['interactionIndex'] ?? 0;
    _followersIndex = widget.currentData['followersIndex'] ?? 0;
    String? savedOffer = widget.currentData['selectedOffer'];
    _selectedOffer = (_offers.containsKey(savedOffer))
        ? savedOffer!
        : "بدون عرض";
    List<dynamic> savedGovs = widget.currentData['governorates'] ?? [];
    _selectedGovs = Set<String>.from(savedGovs.map((e) => e.toString()));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 50,
    );
    if (image != null) {
      setState(() => _newImage = File(image.path));
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.primary,
              ),
              title: const Text('المعرض'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('الكاميرا'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateOrder() async {
    if (!_formKey.currentState!.validate() ||
        _selectedGovs.isEmpty ||
        _totalAmount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("برجاء إكمال البيانات واختيار خدمة واحدة على الأقل"),
        ),
      );
      return;
    }

    setState(() => _isUpdating = true);
    try {
      String imageUrl = widget.currentData['receiptUrl'] ?? "";
      if (_newImage != null) {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(_newImage!.path, folder: 'receipts'),
        );
        imageUrl = response.secureUrl;
      }

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
            'userName': _nameController.text,
            'userPhone': _phoneController.text,
            'postLink': _linkController.text,
            'governorates': _selectedGovs.toList(),
            'publishIndex': _publishIndex,
            'interactionIndex': _interactionIndex,
            'followersIndex': _followersIndex,
            'selectedOffer': _selectedOffer,
            'amount': _totalAmount,
            'receiptUrl': imageUrl,
            'lastUpdated': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم تحديث كافة بيانات الحملة بنجاح")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("خطأ في التحديث: $e")));
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "تعديل تفاصيل الطلب",
            style: TextStyle(
              color: AppColors.textMain,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textMain,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("البيانات الأساسية"),
                _buildTextField(
                  controller: _nameController,
                  hint: "الاسم بالكامل",
                  icon: Icons.person_outline,
                ),
                _buildTextField(
                  controller: _phoneController,
                  hint: "رقم الموبايل",
                  icon: Icons.phone_android,
                  isPhone: true,
                ),
                _buildTextField(
                  controller: _linkController,
                  hint: "رابط المنشور",
                  icon: Icons.link,
                ),
                const SizedBox(height: 25),
                _buildSectionTitle("تحديد المناطق المستهدفة"),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: ListView.builder(
                    itemCount: _governorates.length,
                    itemBuilder: (context, index) {
                      final gov = _governorates[index];
                      return CheckboxListTile(
                        title: Text(gov, style: const TextStyle(fontSize: 14)),
                        value: _selectedGovs.contains(gov),
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(
                          () => val == true
                              ? _selectedGovs.add(gov)
                              : _selectedGovs.remove(gov),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 25),
                _buildSeekBar(
                  "مستوى دفعات النشر",
                  _publishIndex,
                  _publishLabels,
                  _publishPrices,
                  (val) => setState(() => _publishIndex = val.toInt()),
                ),
                _buildSeekBar(
                  "مستوى تعزيز التفاعل",
                  _interactionIndex,
                  _interactionLabels,
                  _interactionPrices,
                  (val) => setState(() => _interactionIndex = val.toInt()),
                ),
                _buildSeekBar(
                  "زيادة عدد المتابعين",
                  _followersIndex,
                  _followersLabels,
                  _followersPrices,
                  (val) => setState(() => _followersIndex = val.toInt()),
                ),
                const SizedBox(height: 30),
                _buildSectionTitle("عروض Go المختارة"),
                _buildOfferDropdown(),
                const SizedBox(height: 25),
                _buildSectionTitle("تحديث إيصال الدفع"),
                _buildReceiptUpdateSection(),
                const SizedBox(height: 40),
                _buildTotalAmountSection(),
                const SizedBox(height: 25),
                _isUpdating
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : MaterialButton(
                        onPressed: _updateOrder,
                        minWidth: double.infinity,
                        color: AppColors.primary,
                        height: 60,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Text(
                          "حفظ التعديلات والعودة",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPhone = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.right,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        validator: (val) => val == null || val.isEmpty ? "الحقل مطلوب" : null,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey),
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

  Widget _buildSeekBar(
    String title,
    int index,
    List<String> labels,
    List<int> prices,
    Function(double) onChanged,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              "${prices[index]} جنيه",
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: index.toDouble(),
          min: 0,
          max: (labels.length - 1).toDouble(),
          divisions: labels.length - 1,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels
                .map(
                  (l) => Text(
                    l,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildOfferDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedOffer,
          items: _offers.keys
              .map(
                (key) => DropdownMenuItem(
                  value: key,
                  child: Text(key, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: (val) => setState(() => _selectedOffer = val!),
        ),
      ),
    );
  }

  Widget _buildReceiptUpdateSection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
          child: _newImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(_newImage!, fit: BoxFit.cover),
                )
              : (widget.currentData['receiptUrl'] != null &&
                        widget.currentData['receiptUrl'] != "" &&
                        widget.currentData['receiptUrl'] !=
                            "no_receipt_uploaded"
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          widget.currentData['receiptUrl'],
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Center(
                        child: Text(
                          "لا يوجد إيصال مرفق حالياً",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      )),
        ),
        const SizedBox(height: 15),
        MaterialButton(
          onPressed: _showPickerOptions,
          minWidth: double.infinity,
          height: 50,
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.primary),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_file_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                "تحميل إيصال الدفع",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalAmountSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "إجمالي التكلفة الحالية:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            "$_totalAmount ج.م",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
