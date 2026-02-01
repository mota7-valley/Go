import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_constants.dart';

class CompanyAccountScreen extends StatefulWidget {
  const CompanyAccountScreen({super.key});

  @override
  State<CompanyAccountScreen> createState() => _CompanyAccountScreenState();
}

class _CompanyAccountScreenState extends State<CompanyAccountScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  String selectedMainService = 'نشر و استهدف';

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("لوحة تحكم الشركة"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _signOut(context),
            ),
          ],
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('companies')
              .doc(user?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("لا توجد بيانات لهذه الشركة"));
            }

            var companyData = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "أهلاً، ${companyData['companyName']}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 40),
                  const Text(
                    "الخدمة الأساسية التي تقدمها:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: selectedMainService,
                    isExpanded: true,
                    items: ['نشر و استهدف', 'تفعيل Canva Pro'].map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedMainService = val);
                      }
                    },
                  ),
                  const SizedBox(height: 30),
                  if (selectedMainService == 'نشر و استهدف') ...[
                    const Text(
                      "تعديل أسعار الخدمات الفرعية:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    _priceEditTile(
                      "نشر واستهدف",
                      companyData['prices']['publish'],
                      'publish',
                    ),
                    _priceEditTile(
                      "تعزيز التفاعل",
                      companyData['prices']['interaction'],
                      'interaction',
                    ),
                    _priceEditTile(
                      "زيادة المتابعين",
                      companyData['prices']['followers'],
                      'followers',
                    ),
                  ],
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: () {
                      // سيتم ربط شاشة عرض طلبات المستخدمين هنا
                    },
                    icon: const Icon(Icons.list_alt),
                    label: const Text("عرض طلبات العملاء المرفوعة لي"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _priceEditTile(String title, List prices, String fieldKey) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("الأسعار الحالية: ${prices.join(' - ')} ج.م"),
        trailing: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
        onTap: () {
          // دالة تعديل الأسعار ستوضع هنا
        },
      ),
    );
  }
}
