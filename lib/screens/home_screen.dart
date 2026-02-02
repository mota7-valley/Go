import 'package:flutter/material.dart';
import '../core/app_constants.dart';
import 'my_orders_screen.dart';
import 'companies_screen.dart';
import 'company_auth_screen.dart';
import 'company_account_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _showFacebookServices = false;
  final String adminPhone = "01220883999";

  Future<void> _makePhoneCall() async {
    final Uri url = Uri.parse('tel:$adminPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _openWhatsApp() async {
    final Uri url = Uri.parse('https://wa.me/201220883999');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget homeTabContent = _showFacebookServices
        ? FacebookServicesScreen(
            onBack: () => setState(() => _showFacebookServices = false))
        : HomeContent(
            onFacebookTap: () => setState(() => _showFacebookServices = true));

    final List<Widget> pages = [
      homeTabContent,
      const MyOrdersScreen(),
      const CompanyAccountScreen(),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: "الرئيسية",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: "طلباتي",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.support_agent_rounded),
              label: "الشركات و الدعم الفني",
            ),
          ],
          onTap: (index) {
            if (index == 2) {
              _showSupportAndCompanyOptions(context);
            } else {
              setState(() {
                _currentIndex = index;
                if (index != 0) _showFacebookServices = false;
              });
            }
          },
        ),
        body: IndexedStack(index: _currentIndex, children: pages),
      ),
    );
  }

  void _showSupportAndCompanyOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "الشركات و الدعم الفني",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: AppColors.primary,
                ),
                title: const Text(
                  "انشاء حساب شركة",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (FirebaseAuth.instance.currentUser == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CompanyAuthScreen(),
                      ),
                    );
                  } else {
                    setState(() => _currentIndex = 2);
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Colors.green,
                ),
                title: const Text(
                  "التواصل مع الادارة (واتساب)",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _openWhatsApp();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.phone_in_talk_rounded,
                  color: Colors.blue,
                ),
                title: const Text(
                  "التواصل مع الادارة (اتصال هاتفي)",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _makePhoneCall();
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final VoidCallback onFacebookTap;
  const HomeContent({super.key, required this.onFacebookTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          child: Column(
            children: [
              const Text(
                "نورتنا بوجودك في \"Go\"",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              const Icon(
                Icons.campaign_rounded,
                size: 90,
                color: AppColors.primary,
              ),
              const SizedBox(height: 20),
              const Text(
                "محتاج أنهي خدمة؟",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCircularButton(
                    context,
                    "نشر و استهدف",
                    Icons.facebook_rounded,
                    const Color(0xFF1877F2),
                    onFacebookTap,
                  ),
                  _buildCircularButton(
                    context,
                    "تفعيل Canva",
                    Icons.auto_awesome_rounded,
                    const Color(0xFF00C4CC),
                    () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
            ),
            child: Icon(icon, color: color, size: 50),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class FacebookServicesScreen extends StatelessWidget {
  final VoidCallback onBack;
  const FacebookServicesScreen({super.key, required this.onBack});

  void _showInfoSheet(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.all(25),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Divider(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.8,
                      color: AppColors.textMain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              MaterialButton(
                onPressed: () => Navigator.pop(context),
                minWidth: double.infinity,
                height: 55,
                color: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  "فهمت ذلك",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: onBack,
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.facebook_rounded,
                size: 70,
                color: Color(0xFF1877F2),
              ),
              const SizedBox(height: 40),
              _buildServiceButton(
                context,
                "الشركات المتاحة",
                Icons.business_rounded,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CompaniesScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              _buildServiceButton(
                context,
                "شرح وطريقة الاستخدام",
                Icons.help_outline_rounded,
                () => _showInfoSheet(
                  context,
                  "شرح وطريقة الاستخدام",
                  "مرحباً بك في خدمة 'نشر واستهدف'. إليك خطوات تنفيذ طلبك بنجاح:\n\n"
                      "1. اختيار الشركة: قم بالدخول على 'الشركات المتاحة' واختيار الشركة المناسبة لميزانيتك ومجال عملك.\n"
                      "2. تقديم الطلب: قم بملء بيانات الحملة الإعلانية بدقة (رابط المنشور، الفئة المستهدفة، والميزانية).\n"
                      "3. مراجعة الطلب: بمجرد إرسال الطلب، ستتم مراجعته من قبل إدارة الشركة المختارة.\n"
                      "4. التنفيذ والمتابعة: بعد الموافقة، سيتحول طلبك إلى 'جاري التنفيذ'. يمكنك متابعة حالة طلباتك دائماً من تبويب 'طلباتي' في الشاشة الرئيسية.\n"
                      "5. الدعم الفني: في حال وجود أي استفسار، يمكنك التواصل مع الشركة اتصال هاتفي او واتساب.",
                ),
              ),
              const SizedBox(height: 15),
              _buildServiceButton(
                context,
                "سياسة الاستخدام والشروط",
                Icons.gavel_rounded,
                () => _showInfoSheet(
                  context,
                  "سياسة الاستخدام والشروط",
                  "باستخدامك لهذه الخدمة، فإنك تقر وتوافق على الشروط التالية:\n\n"
                      "• مسؤولية المحتوى: يتحمل المستخدم المسؤولية الكاملة عن المنشورات والروابط التي يتم الترويج لها، ويجب ألا تخالف سياسات فيسبوك أو القوانين العامة.\n"
                      "• إخلاء مسؤولية: تطبيق 'Go' والشركات المدرجة هم وسيط للتنفيذ فقط. نحن لا نضمن نتائج بيعية محددة حيث تعتمد النتائج على جودة محتواك وتفاعل الجمهور.\n"
                      "• سياسة الإلغاء: لا يمكن تعديل أو إلغاء الطلب بمجرد أن تصبح حالته 'جاري التنفيذ'.\n"
                      "• مراجعة الإعلانات: للشركة الحق في رفض أي طلب يخالف معاييرها الخاصة مع توضيح السبب.\n"
                      "• الخصوصية: نلتزم بحماية بياناتك ولن يتم مشاركتها مع أي أطراف خارج نطاق تنفيذ الخدمة.",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceButton(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return MaterialButton(
      onPressed: onTap,
      minWidth: double.infinity,
      height: 70,
      color: Colors.white,
      elevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
