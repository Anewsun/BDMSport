import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../config/app_config.dart';

class PaymentController {
  static String get _clientId => AppConfig.paypalClientId;
  static String get _secretKey => AppConfig.paypalSecret;

  Future<void> depositWithPayPal(BuildContext context, int amountVND) async {
    final double usd = amountVND / 26000;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => PaypalCheckoutView(
          sandboxMode: true,
          clientId: _clientId,
          secretKey: _secretKey,
          transactions: [
            {
              "amount": {
                "total": usd.toStringAsFixed(2),
                "currency": "USD",
                "details": {
                  "subtotal": usd.toStringAsFixed(2),
                  "shipping": '0',
                  "shipping_discount": 0,
                },
              },
              "description": "Nạp $amountVND VND vào ví",
              "item_list": {
                "items": [
                  {
                    "name": "Nạp tiền",
                    "quantity": 1,
                    "price": usd.toStringAsFixed(2),
                    "currency": "USD",
                  },
                ],
              },
            },
          ],
          note: "Cảm ơn bạn đã sử dụng dịch vụ",
          onSuccess: (Map params) async {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              final docRef = FirebaseFirestore.instance
                  .collection("users")
                  .doc(user.uid);
              await FirebaseFirestore.instance.runTransaction((txn) async {
                final snapshot = await txn.get(docRef);
                final currentBalance = snapshot["balance"] ?? 0;
                txn.update(docRef, {"balance": currentBalance + amountVND});
              });
              Fluttertoast.showToast(
                msg: "Nạp $amountVND VND thành công!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 18,
              );
            }
            Navigator.pop(context);
          },
          onError: (error) {
            debugPrint("Lỗi PayPal: $error");
            Navigator.pop(context);
          },
          onCancel: () {
            debugPrint("Người dùng hủy thanh toán");
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
