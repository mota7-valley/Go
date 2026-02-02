import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_constants.dart';

class CompanyAccountScreen extends StatelessWidget {
  const CompanyAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text(
            "طلبات العملاء الواردة",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => FirebaseAuth.instance.signOut(),
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .where('companyId', isEqualTo: user?.uid)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_rounded, size: 80, color: Colors.grey),
                    SizedBox(height: 10),
                    Text(
                      "لا توجد طلبات مقدمة لشركتك حتى الآن",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            var orders = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                var orderData = orders[index].data() as Map<String, dynamic>;
                String orderId = orders[index].id;
                String currentStatus = orderData['status'] ?? "قيد المراجعة";
                String userName = orderData['userName'] ?? "عميل";

                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "العميل: $userName",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            _buildStatusBadge(currentStatus),
                          ],
                        ),
                        const Divider(height: 25),
                        _buildInfoRow(
                          Icons.link,
                          "رابط المنشور",
                          orderData['postUrl'] ?? 'لا يوجد',
                        ),
                        _buildInfoRow(
                          Icons.payments_outlined,
                          "المبلغ الإجمالي",
                          "${orderData['totalPrice']} ج.م",
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "تحديث حالة الطلب:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildActionBtn(
                                context,
                                orderId,
                                "قيد المراجعة",
                                Colors.orange,
                                currentStatus,
                                "المراجعة",
                              ),
                              const SizedBox(width: 8),
                              _buildActionBtn(
                                context,
                                orderId,
                                "تم التأكيد وجاري التنفيذ",
                                Colors.blue,
                                currentStatus,
                                "تأكيد",
                              ),
                              const SizedBox(width: 8),
                              _buildActionBtn(
                                context,
                                orderId,
                                "تم التنفيذ - نشكرك يا $userName على انضمامك معنا",
                                Colors.green,
                                currentStatus,
                                "إنهاء الطلب",
                                isLong: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
    Color color = Colors.orange;
    if (status.contains("التنفيذ") && !status.contains("تم التنفيذ")) {
      color = Colors.blue;
    } else if (status.contains("تم التنفيذ")) {
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.length > 15 ? "تم التنفيذ" : status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(
    BuildContext context,
    String docId,
    String targetStatus,
    Color color,
    String currentStatus,
    String btnText, {
    bool isLong = false,
  }) {
    bool isActive = currentStatus == targetStatus;

    return InkWell(
      onTap: () async {
        await FirebaseFirestore.instance.collection('orders').doc(docId).update(
          {'status': targetStatus},
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          btnText,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black54,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
