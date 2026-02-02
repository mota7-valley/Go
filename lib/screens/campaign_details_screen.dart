import 'package:flutter/material.dart';
import '../core/app_constants.dart';
import 'payment_screen.dart';

class CampaignDetailsScreen extends StatefulWidget {
  final String companyId;
  final String companyName;
  final Map<String, dynamic> companyData;

  const CampaignDetailsScreen({
    super.key,
    required this.companyId,
    required this.companyName,
    required this.companyData,
  });

  @override
  State<CampaignDetailsScreen> createState() => _CampaignDetailsScreenState();
}

class _CampaignDetailsScreenState extends State<CampaignDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _linkController = TextEditingController();

  double _budget = 100;
  String _selectedLocation = "القاهرة";
  String _selectedService = "نشر واستهدف";

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> prices = widget.companyData['prices'] ??
        {
          'publish': [0, 100, 200, 300, 400],
          'interaction': [0, 50, 100, 150, 200],
          'followers': [0, 20, 40, 60, 80],
        };

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text("بدء حملة مع ${widget.companyName}"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("بيانات العميل"),
                _buildTextField(_nameController, "اسمك الثنائي", Icons.person),
                _buildTextField(_phoneController, "رقم الهاتف", Icons.phone,
                    isPhone: true),
                _buildTextField(_linkController, "رابط المنشور", Icons.link),
                const SizedBox(height: 20),
                _buildSectionTitle("تفاصيل الحملة"),
                const Text("اختر الخدمة:"),
                DropdownButton<String>(
                  value: _selectedService,
                  isExpanded: true,
                  items: ['نشر واستهدف', 'تعزيز التفاعل', 'زيادة المتابعين']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedService = v!),
                ),
                const SizedBox(height: 20),
                const Text("المكان المستهدف:"),
                DropdownButton<String>(
                  value: _selectedLocation,
                  isExpanded: true,
                  items: ["القاهرة", "الجيزة", "الإسكندرية", "الدلتا", "الصعيد"]
                      .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedLocation = v!),
                ),
                const SizedBox(height: 20),
                Text(
                    "الميزانية (الأسعار تبدأ من ${prices['publish'][1]} ج.م):"),
                Slider(
                  value: _budget,
                  min: 100,
                  max: 1000,
                  divisions: 18,
                  label: "${_budget.toInt()} ج.م",
                  onChanged: (double value) => setState(() => _budget = value),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Map<String, dynamic> orderData = {
                        'userName': _nameController.text.trim(),
                        'userPhone': _phoneController.text.trim(),
                        'postLink': _linkController.text.trim(),
                        'serviceType': _selectedService,
                        'location': _selectedLocation,
                        'companyId': widget.companyId,
                        'companyName': widget.companyName,
                        'totalPrice': _budget,
                        'status': 'pending',
                        'createdAt': DateTime.now().toIso8601String(),
                      };

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentScreen(
                            amount: _budget,
                            orderData: orderData,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("متابعة لعملية الدفع",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon,
      {bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => (v == null || v.isEmpty) ? "هذا الحقل مطلوب" : null,
      ),
    );
  }
}
