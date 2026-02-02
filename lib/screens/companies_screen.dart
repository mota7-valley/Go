import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/app_constants.dart';
import 'campaign_details_screen.dart';

class CompaniesScreen extends StatelessWidget {
  const CompaniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("الشركات المتاحة"),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('companies')
              .where('isApproved', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text("لا توجد شركات موثقة حالياً",
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
              );
            }

            var companies = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: companies.length,
              itemBuilder: (context, index) {
                var data = companies[index].data() as Map<String, dynamic>;
                String logoUrl = data['logoUrl'] ?? "";

                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: ClipOval(
                        child: logoUrl.isNotEmpty
                            ? Image.network(
                                logoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.business,
                                        color: Colors.grey, size: 30),
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2));
                                },
                              )
                            : const Icon(Icons.business,
                                color: Colors.grey, size: 30),
                      ),
                    ),
                    title: Text(
                      data['companyName'] ?? "شركة غير مسمى",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: const Row(
                      children: [
                        Icon(Icons.verified, color: Colors.blue, size: 16),
                        SizedBox(width: 5),
                        Text("موثقة",
                            style: TextStyle(color: Colors.blue, fontSize: 13)),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        color: AppColors.primary, size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CampaignDetailsScreen(
                            companyId: companies[index].id,
                            companyName: data['companyName'] ?? "",
                            companyData: data,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
