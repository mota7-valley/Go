import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_constants.dart';
import 'campaign_details_screen.dart';

class CompaniesScreen extends StatelessWidget {
  const CompaniesScreen({super.key});

  final List<Map<String, String>> _companies = const [
    {"name": "شركة النسر", "logo": "🦅", "phone": "01012345678"},
    {"name": "جو للدعاية", "logo": "🚀", "phone": "01000000000"},
    {"name": "الرواد", "logo": "🌟", "phone": "01100000000"},
    {"name": "ميديا ستار", "logo": "💎", "phone": "01200000000"},
    {"name": "البرق", "logo": "⚡", "phone": "01200000000"},
    {"name": "تارجت", "logo": "🎯", "phone": "01200000000"},
  ];

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
            "الشركات المتاحة",
            style: TextStyle(
              color: AppColors.textMain,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 5,
              runSpacing: 25,
              children: _companies
                  .map((company) => _buildCompanyItem(context, company))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyItem(BuildContext context, Map<String, String> company) {
    double itemWidth = (MediaQuery.of(context).size.width - 40) / 3;

    return SizedBox(
      width: itemWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => _showCompanyActions(context, company),
            borderRadius: BorderRadius.circular(100),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  company['logo']!,
                  style: const TextStyle(fontSize: 35),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            company['name']!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.textMain,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showCompanyActions(BuildContext context, Map<String, String> company) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  company['name']!,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 30),
                _buildActionRow(
                  context: context,
                  title: "ابدأ الحملة",
                  icon: Icons.rocket_launch_rounded,
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CampaignDetailsScreen(
                          companyName: company['name']!,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),
                _buildActionRow(
                  context: context,
                  title: "للمساعدة والدعم الفني",
                  icon: Icons.support_agent_rounded,
                  color: Colors.orange,
                  onTap: () => _showSupportOptions(context, company['phone']!),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionRow({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  void _showSupportOptions(BuildContext context, String phone) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "تواصل معنا",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.phone_in_talk_rounded,
                  color: Colors.green,
                ),
                title: const Text("اتصال هاتفي"),
                onTap: () async {
                  final Uri url = Uri.parse('tel:$phone');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.message_rounded,
                  color: Color(0xFF25D366),
                ),
                title: const Text("محادثة واتساب"),
                onTap: () async {
                  // استخدام البادئة 2 ليصبح الرقم 201... كما طلبت
                  final String whatsappUrl = "whatsapp://send?phone=2$phone";
                  final Uri uri = Uri.parse(whatsappUrl);

                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } else {
                    final Uri webUri = Uri.parse("https://wa.me/2$phone");
                    await launchUrl(
                      webUri,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
