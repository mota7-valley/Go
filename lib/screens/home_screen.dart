import 'package:flutter/material.dart';
import '../core/app_constants.dart';
import 'my_orders_screen.dart';
import 'companies_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
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
              icon: Icon(Icons.person_outline_rounded),
              label: "حسابي",
            ),
          ],
          onTap: (index) {
            setState(() => _currentIndex = index);
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyOrdersScreen()),
              );
            } else if (index == 2) {
              _showAccountOptions(context);
            }
          },
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "نورتنا بوجودك في \"Go\"",
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(1, 2),
                        ),
                      ],
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
                      _buildCircularServiceButton(
                        context: context,
                        title: "نشر و استهداف",
                        icon: Icons.facebook_rounded,
                        color: const Color(0xFF1877F2),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const FacebookServicesScreen(),
                          ),
                        ),
                      ),
                      _buildCircularServiceButton(
                        context: context,
                        title: "تفعيل Canva",
                        icon: Icons.auto_awesome_rounded,
                        color: const Color(0xFF00C4CC),
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircularServiceButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
              border: Border.all(
                color: color.withValues(alpha: 0.5),
                width: 2.5,
              ),
            ),
            child: Icon(icon, color: color, size: 55),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _showAccountOptions(BuildContext context) {
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
                "إدارة الحساب والشركات",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 25),
              _buildListOption(
                context,
                "تسجيل دخول الشركات",
                Icons.login_rounded,
                () {},
              ),
              _buildListOption(
                context,
                "إنشاء حساب شركات جديد",
                Icons.app_registration_rounded,
                () {},
              ),
              _buildListOption(
                context,
                "تحدث معنا",
                Icons.chat_bubble_outline_rounded,
                () {},
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }
}

class FacebookServicesScreen extends StatelessWidget {
  const FacebookServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.facebook_rounded,
                size: 70,
                color: Color(0xFF1877F2),
              ),
              const SizedBox(height: 15),
              const Text(
                "خدمات النشر والاستهداف",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 50),
              _buildMenuButton(
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
              const SizedBox(height: 20),
              _buildMenuButton(
                context,
                "شرح وطريقة الاستخدام",
                Icons.menu_book_rounded,
                () => _showManual(context),
              ),
              const SizedBox(height: 20),
              _buildMenuButton(
                context,
                "سياسة الاستخدام والأحكام",
                Icons.gavel_rounded,
                () => _showPolicy(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return MaterialButton(
      onPressed: onTap,
      minWidth: double.infinity,
      height: 75,
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  void _showManual(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: const Text(
            "شرح طريقة الاستخدام",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          content: const SingleChildScrollView(
            child: Text(
              "• ابدأ باختيار 'الشركات المتاحة' لتظهر لك قائمة بالشركات الموثوقة لدينا.\n"
              "• اضغط على لوجو الشركة ثم اختر 'ابدأ الحملة'.\n"
              "• قم بتعبئة بياناتك (الاسم، الهاتف، ورابط المنشور) بدقة.\n"
              "• حدد المناطق المستهدفة في مصر من قائمة المحافظات.\n"
              "• استخدم الـ Seek Bar لتحديد الميزانية المطلوبة.\n"
              "• في صفحة الدفع، انسخ رقم التحويل الخاص بالشركة وقم بإتمام العملية.\n"
              "• ارفع صورة إيصال التحويل واضغط 'تأكيد' لمتابعة طلبك.",
              style: TextStyle(height: 1.6),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("تم، ابدأ الآن"),
            ),
          ],
        ),
      ),
    );
  }

  void _showPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: const Text(
            "سياسة الاستخدام والأحكام",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          content: const SingleChildScrollView(
            child: Text(
              "• تطبيق Go هو منصة وسيطة، والشركات هي المسؤولة عن تنفيذ الطلبات.\n"
              "• يخلي التطبيق والشركات مسؤوليتهم تماماً عن أي منشور يخالف القوانين أو المعايير الأخلاقية.\n"
              "• لا يحق للمستخدم المطالبة باسترداد المبلغ بعد بدء تنفيذ الحملة فعلياً.\n"
              "• يجب أن تكون صورة الإيصال المرفوعة واضحة وتظهر رقم العملية وتاريخها.\n"
              "• في حال وجود مشكلة، يرجى التواصل مع الدعم الفني الخاص بالشركة المختارة.",
              style: TextStyle(height: 1.6),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("أوافق على الشروط"),
            ),
          ],
        ),
      ),
    );
  }
}
