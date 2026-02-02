import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_constants.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final Map<String, dynamic> orderData;

  const PaymentScreen(
      {super.key, required this.amount, required this.orderData});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  File? _receiptImage;
  bool _isUploading = false;
  final String walletNumber = "01220883999";

  final cloudinary = CloudinaryPublic('dqyz90nfz', 'tvve8pts', cache: false);

  Future<void> _pickReceipt() async {
    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _receiptImage = File(pickedFile.path));
    }
  }

  Future<void> _confirmPayment() async {
    if (_receiptImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("يرجى إرفاق صورة إيصال التحويل")));
      return;
    }

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final String orderId = DateTime.now().millisecondsSinceEpoch.toString();

      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(_receiptImage!.path,
            folder: 'payment_receipts'),
      );
      final String receiptUrl = response.secureUrl;

      await FirebaseFirestore.instance.collection('orders').doc(orderId).set({
        ...widget.orderData,
        'userId': user?.uid,
        'totalPrice': widget.amount,
        'paymentReceiptUrl': receiptUrl,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("حدث خطأ: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("تم إرسال الطلب"),
          content: const Text("جاري مراجعة الإيصال من قبل الإدارة."),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("حسناً"))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("تأكيد الدفع"),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              const Icon(Icons.account_balance_wallet_rounded,
                  size: 80, color: AppColors.primary),
              const SizedBox(height: 20),
              const Text("حول المبلغ إلى الرقم التالي:",
                  style: TextStyle(fontSize: 16)),
              SelectableText(walletNumber,
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
              const SizedBox(height: 10),
              Text("المبلغ المطلوب: ${widget.amount} ج.م",
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: _pickReceipt,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[300]!)),
                  child: _receiptImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(_receiptImage!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Icon(Icons.add_a_photo,
                                  size: 50, color: Colors.grey[400]),
                              const SizedBox(height: 10),
                              const Text("ارفع صورة الإيصال",
                                  style: TextStyle(color: Colors.grey))
                            ]),
                ),
              ),
              const SizedBox(height: 40),
              _isUploading
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : ElevatedButton(
                      onPressed: _confirmPayment,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      child: const Text("تأكيد وإرسال",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ),
    );
  }
}
