import 'package:flutter/material.dart';
import '../core/app_constants.dart';
import 'campaign_details_screen.dart';

class FacebookCompaniesScreen extends StatelessWidget {
  const FacebookCompaniesScreen({super.key});

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
          title: const Text(
            "شركات النشر والاستهداف",
            style: TextStyle(
              color: AppColors.textMain,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildActionCard(
                context,
                title: "شرح وطريقة الاستخدام",
                icon: Icons.info_outline_rounded,
                color: Colors.orange,
                onTap: () => _showInfoDialog(context),
              ),
              const SizedBox(height: 15),
              _buildActionCard(
                context,
                title: "سياسة الاستخدام والشروط والأحكام",
                icon: Icons.gavel_rounded,
                color: Colors.redAccent,
                onTap: () => _showPolicyDialog(context),
              ),
              const SizedBox(height: 30),
              const Text(
                "الشركات المتاحة",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 20),
              _buildCompanyCard(
                context,
                name: "شركة النسر للتسويق",
                logo: Icons.business_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CampaignDetailsScreen(
                        companyName: "شركة النسر للتسويق",
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyCard(
    BuildContext context, {
    required String name,
    required IconData logo,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.background,
          child: Icon(logo, color: AppColors.primary, size: 30),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: const Text("متصل حالياً - جاهز للتنفيذ"),
        trailing: const Icon(Icons.arrow_forward_ios_rounded),
        onTap: onTap,
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "دليل استخدام خدمة النشر",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _infoStep(
                  "1. اختيار الشركة:",
                  "اختر الشركة التي تفضل التعامل معها من القائمة المتاحة.",
                ),
                _infoStep(
                  "2. تعبئة البيانات:",
                  "أدخل بياناتك ورابط المنشور بشكل صحيح لضمان سرعة التنفيذ.",
                ),
                _infoStep(
                  "3. تحديد الاستهداف:",
                  "اختر المحافظات المستهدفة والميزانية المطلوبة عبر المؤشرات.",
                ),
                _infoStep(
                  "4. تحويل المبلغ:",
                  "انسخ رقم تحويل الشركة وأرسل المبلغ المطلوب.",
                ),
                _infoStep(
                  "5. تأكيد الطلب:",
                  "ارفع صورة التحويل واضغط تأكيد لتبدأ الشركة في المراجعة.",
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("بدء الاستخدام"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoStep(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            desc,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  void _showPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "سياسة الاستخدام وإخلاء المسؤولية",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: Text(
              "• تطبيق (Go) هو منصة تقنية وسيطة تربط بين المستخدم وشركات الخدمات؛ لذا فإن التطبيق غير مسؤول عن محتوى المنشورات أو نتائج الحملات.\n\n"
              "• تخلي الشركات المتعاقدة مسؤوليتها تماماً عن أي منشور يخالف سياسات فيسبوك أو القوانين العامة، ويتحمل المستخدم المسؤولية القانونية الكاملة عن محتواه.\n\n"
              "• يقر المستخدم بأن جميع البيانات (الروابط، الأرقام، المناطق) صحيحة، ولا يحق له طلب استرداد المبلغ بعد تحول حالة الطلب إلى (جاري التنفيذ).\n\n"
              "• يحق للتطبيق والشركات رفض أي طلب لا يتوافق مع المعايير الأمنية والأخلاقية دون إبداء أسباب.",
              style: TextStyle(fontSize: 13, height: 1.6),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("أوافق على جميع الشروط"),
            ),
          ],
        ),
      ),
    );
  }
}
