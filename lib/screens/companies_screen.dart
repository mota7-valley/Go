import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'campaign_details_screen.dart';

class CompaniesScreen extends StatelessWidget {
  const CompaniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "الشركات المتاحة",
            style: TextStyle(
              color: Color(0xFF1D2D50),
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1D2D50)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('companies')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("لا توجد شركات مسجلة حالياً"));
            }

            var companies = snapshot.data!.docs;

            return GridView.builder(
              padding: const EdgeInsets.all(25),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              itemCount: companies.length,
              itemBuilder: (context, index) {
                var companyDoc = companies[index];
                var company = companyDoc.data() as Map<String, dynamic>;
                String companyId = companyDoc.id;
                String name = company['companyName'] ?? "بدون اسم";
                String? logo = company['logoUrl'];

                return GestureDetector(
                  onTap: () =>
                      _showCompanyOptions(context, name, companyId, company),
                  child: Column(
                    children: [
                      Container(
                        width: 85,
                        height: 85,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: logo != null && logo.isNotEmpty
                              ? Image.network(logo, fit: BoxFit.cover)
                              : const Icon(
                                  Icons.business,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D2D50),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showCompanyOptions(
    BuildContext context,
    String name,
    String id,
    Map<String, dynamic> data,
  ) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1877F2),
                  ),
                ),
                const SizedBox(height: 30),
                _buildModalButton(
                  context,
                  "ابدأ الحملة",
                  Icons.rocket_launch_rounded,
                  const Color(0xFFE3F2FD),
                  const Color(0xFF1877F2),
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CampaignDetailsScreen(
                          companyId: id,
                          companyName: name,
                          companyData: data,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),
                _buildModalButton(
                  context,
                  "للمساعدة والدعم الفني",
                  Icons.headset_mic_rounded,
                  const Color(0xFFFFF3E0),
                  const Color(0xFFFF9800),
                  () => _showSupportOptions(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalButton(
    BuildContext context,
    String title,
    IconData icon,
    Color bg,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(Icons.arrow_back_ios, size: 14, color: color),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 15),
            Icon(icon, color: color),
          ],
        ),
      ),
    );
  }

  void _showSupportOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "تواصل معنا",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.green),
                  title: const Text("اتصال هاتفي"),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.chat, color: Colors.green),
                  title: const Text("محادثة واتساب"),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
