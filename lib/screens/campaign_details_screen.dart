import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_constants.dart';
import 'add_order_screen.dart';

class CampaignDetailsScreen extends StatelessWidget {
  final String companyId;
  final String companyName;
  final Map<String, dynamic> companyData;

  const CampaignDetailsScreen({
    super.key,
    required this.companyId,
    required this.companyName,
    required this.companyData,
  });

  void _contactSupport(String phone) async {
    final url = Uri.parse("https://wa.me/$phone");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    String logoUrl = companyData['logoUrl'] ?? "";
    String companyPhone = companyData['phone'] ?? "";

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(companyName),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textMain,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 20,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: ClipOval(
                        child: logoUrl.isNotEmpty
                            ? Image.network(logoUrl, fit: BoxFit.cover)
                            : const Icon(Icons.business,
                                size: 60, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      companyName,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified, color: Colors.blue, size: 18),
                        SizedBox(width: 5),
                        Text("شريك معتمد",
                            style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _buildServiceCard(
                context: context,
                title: "ابدأ حملة إعلانية",
                subtitle: "نشر واستهداف احترافي على فيسبوك",
                icon: Icons.campaign_rounded,
                color: AppColors.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddOrderScreen(
                      companyId: companyId,
                      companyName: companyName,
                      serviceType: 'facebook',
                      companyPhone: companyPhone,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildServiceCard(
                context: context,
                title: "تفعيل Canva Pro",
                subtitle: "احصل على حساب برو لمدة سنة بـ 50 ج.م",
                icon: Icons.auto_awesome_mosaic_rounded,
                color: const Color(0xFF00C4CC),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddOrderScreen(
                      companyId: companyId,
                      companyName: companyName,
                      serviceType: 'canva',
                      companyPhone: companyPhone,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              OutlinedButton.icon(
                onPressed: () => _contactSupport(companyPhone),
                icon: const Icon(Icons.support_agent_rounded),
                label: const Text("للمساعدة والدعم الفني"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.12), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}
