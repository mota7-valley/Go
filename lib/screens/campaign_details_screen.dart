import 'package:flutter/material.dart';
import '../core/app_constants.dart';
import 'payment_screen.dart';

class CampaignDetailsScreen extends StatefulWidget {
  final String companyName;
  const CampaignDetailsScreen({super.key, required this.companyName});

  @override
  State<CampaignDetailsScreen> createState() => _CampaignDetailsScreenState();
}

class _CampaignDetailsScreenState extends State<CampaignDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  final String _companyPhone = "01012345678";

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

  String _selectedOffer = "بدون عرض";
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
  final Set<String> _selectedGovs = {};

  int get _totalAmount {
    return _publishPrices[_publishIndex] +
        _interactionPrices[_interactionIndex] +
        _followersPrices[_followersIndex] +
        (_offers[_selectedOffer] ?? 0);
  }

  void _validateAndSubmit() {
    bool isFormValid = _formKey.currentState!.validate();
    bool isGovSelected = _selectedGovs.isNotEmpty;
    bool isAmountValid = _totalAmount > 0;

    if (!isFormValid || !isGovSelected || !isAmountValid) {
      String errorMessage = "الطلب غير مكتمل";
      if (isFormValid && !isGovSelected) {
        errorMessage = "برجاء تحديد المناطق المستهدفة";
      } else if (isFormValid && isGovSelected && !isAmountValid) {
        errorMessage = "برجاء اختيار خدمة أو عرض واحد على الأقل";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(20),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          totalAmount: _totalAmount,
          companyName: widget.companyName,
          companyPhone: _companyPhone,
          userName: _nameController.text,
          userPhone: _phoneController.text,
          postLink: _linkController.text,
          selectedGovs: _selectedGovs.toList(),
          publishIndex: _publishIndex,
          interactionIndex: _interactionIndex,
          followersIndex: _followersIndex,
          selectedOffer: _selectedOffer,
        ),
      ),
    );
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
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textMain,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.companyName,
            style: const TextStyle(
              color: AppColors.textMain,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("البيانات الأساسية (إجباري)"),
                _buildTextField(
                  controller: _nameController,
                  hint: "الاسم بالكامل",
                  icon: Icons.person_outline,
                  validator: (val) =>
                      val == null || val.isEmpty ? "الحقل مطلوب" : null,
                ),
                _buildTextField(
                  controller: _phoneController,
                  hint: "رقم الموبايل",
                  icon: Icons.phone_android_outlined,
                  isPhone: true,
                  validator: (val) {
                    if (val == null || val.isEmpty) return "الحقل مطلوب";
                    if (!val.startsWith("01")) return "يجب أن يبدأ بـ 01";
                    if (val.length != 11) return "يجب أن يكون 11 رقم";
                    return null;
                  },
                ),
                _buildTextField(
                  controller: _linkController,
                  hint: "رابط المنشور (يقبل اللصق)",
                  icon: Icons.link_rounded,
                  validator: (val) {
                    if (val == null || val.isEmpty) return "الحقل مطلوب";
                    if (!val.startsWith("http")) return "يرجى إدخال رابط صحيح";
                    return null;
                  },
                ),
                const SizedBox(height: 25),
                _buildSectionTitle("تحديد المناطق (إجباري)"),
                Container(
                  height: 220,
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
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedGovs.add(gov);
                            } else {
                              _selectedGovs.remove(gov);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
                _buildSeekBar(
                  "مستوى دفعات النشر",
                  _publishIndex,
                  _publishLabels,
                  _publishPrices,
                  (val) => setState(() => _publishIndex = val.toInt()),
                ),
                _buildSeekBar(
                  "مستوى تعزيز التفاعل والاعجابات",
                  _interactionIndex,
                  _interactionLabels,
                  _interactionPrices,
                  (val) => setState(() => _interactionIndex = val.toInt()),
                ),
                _buildSeekBar(
                  "زيادة عدد متابعين الصفحة",
                  _followersIndex,
                  _followersLabels,
                  _followersPrices,
                  (val) => setState(() => _followersIndex = val.toInt()),
                ),
                const SizedBox(height: 30),
                _buildSectionTitle("عروض Go المختارة"),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedOffer,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                      ),
                      items: _offers.keys.map((String key) {
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text(
                            key,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedOffer = val!),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _buildTotalAmountSection(),
                const SizedBox(height: 25),
                MaterialButton(
                  onPressed: _validateAndSubmit,
                  minWidth: double.infinity,
                  color: AppColors.primary,
                  height: 60,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    "تأكيد الطلب والذهاب للدفع",
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
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.right,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
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
                fontSize: 16,
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
          inactiveColor: Colors.black12,
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
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                .toList(),
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
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "إجمالي تكلفة الحملة:",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            "$_totalAmount ج.م",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
