import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_constants.dart';
import 'edit_order_screen.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "طلباتي الحالية",
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
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('userId', isEqualTo: user?.uid)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_late_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "لا توجد طلبات حتى الآن",
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var order = doc.data() as Map<String, dynamic>;
                String status = order['status'] ?? 'pending';
                String companyName = order['companyName'] ?? 'شركة غير معروفة';
                String serviceType = order['serviceType'] ?? 'facebook';
                String orderId = doc.id;
                String? duration = order['duration'];
                String? receiptUrl = order['paymentReceiptUrl'];

                String dateDisplay = "قيد المعالجة";
                if (order['createdAt'] != null &&
                    order['createdAt'] is Timestamp) {
                  dateDisplay = (order['createdAt'] as Timestamp)
                      .toDate()
                      .toString()
                      .split(' ')[0];
                }

                bool isCanva = serviceType == 'canva';
                Color serviceColor =
                    isCanva ? const Color(0xFF00C4CC) : AppColors.primary;

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: serviceColor.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isCanva
                                      ? Icons.auto_awesome_mosaic_rounded
                                      : Icons.campaign_rounded,
                                  color: serviceColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    companyName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    isCanva ? "خدمة Canva Pro" : "حملة إعلانية",
                                    style: TextStyle(
                                      color: serviceColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (isCanva && duration != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        duration,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          _buildStatusBadge(status),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: Colors.black12),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "تاريخ الطلب",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dateDisplay,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "المبلغ المدفوع",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${order['totalPrice'] ?? 0} ج.م",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: serviceColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (receiptUrl != null && receiptUrl.isNotEmpty) ...[
                        const SizedBox(height: 15),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                child: Image.network(receiptUrl),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.image_outlined,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 5),
                              Text(
                                "عرض إيصال الدفع المرفق",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (status == 'pending' || status == 'قيد المراجعة') ...[
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _confirmDelete(context, orderId),
                                icon: const Icon(Icons.delete_forever,
                                    color: Colors.red, size: 18),
                                label: const Text("حذف",
                                    style: TextStyle(color: Colors.red)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditOrderScreen(
                                        orderId: orderId,
                                        currentData: order,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text("تعديل"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: serviceColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildStatusBadge(String status) {
    Color color;
    String displayStatus;

    switch (status) {
      case 'approved':
      case 'تم التأكيد وجاري التنفيذ':
        color = Colors.blue;
        displayStatus = "جاري التنفيذ";
        break;
      case 'completed':
      case 'تم التنفيذ والانتهاء':
        color = Colors.green;
        displayStatus = "تم التنفيذ ✅";
        break;
      case 'rejected':
      case 'مرفوض':
        color = Colors.red;
        displayStatus = "مرفوض";
        break;
      default:
        color = Colors.orange;
        displayStatus = "قيد المراجعة";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        displayStatus,
        style:
            TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("حذف الطلب"),
        content: const Text("هل أنت متأكد من حذف هذا الطلب؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('orders')
                  .doc(orderId)
                  .delete();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("تأكيد الحذف",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
