import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/auth/auth_repository.dart';
import '../../../core/utils/error_util.dart';

class ForgotPasswordController {
  final AuthRepository _authRepository;

  ForgotPasswordController(this._authRepository);

  Future<void> sendResetPasswordEmail(String email) async {
    try {
      await _authRepository.sendPasswordResetEmail(email);
      Fluttertoast.showToast(
        msg:
            "Email đặt lại mật khẩu đã được gửi đến $email.",
        toastLength: Toast.LENGTH_LONG,
      );
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        msg: getFriendlyErrorMessage(e),
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      rethrow;
    }
  }
}
