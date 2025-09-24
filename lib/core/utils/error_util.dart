import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

String getFriendlyErrorMessage(dynamic error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'Email này đã được sử dụng.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Phải có ít nhất 6 ký tự.';
      case 'invalid-credential':
        return 'Thông tin đăng nhập không hợp lệ hoặc đã hết hạn.';
      case 'too-many-requests':
        return 'Đăng nhập quá nhiều lần. Vui lòng thử lại sau';
      case 'network-request-failed':
        return 'Lỗi mạng. Kiểm tra kết nối internet';
      case 'email-not-verified':
        return 'Email chưa được xác minh. Vui lòng kiểm tra hộp thư của bạn.';
      case 'missing-email':
        return 'Vui lòng nhập email';
      case 'missing-password':
        return 'Vui lòng nhập mật khẩu';
      case 'account-exists-with-different-credential':
        return 'Email này đã được sử dụng với phương thức đăng nhập khác.';
      case 'account-reauth-failed':
      case 'account-reauthentication-failed':
        return 'Xác thực lại tài khoản thất bại. Vui lòng thử lại.';
      case 'user-cancelled':
        return 'Đăng nhập bị hủy bỏ.';
      default:
        return 'Đã xảy ra lỗi không xác định.';
    }
  }

  if (error is GoogleSignInException) {
    switch (error.code) {
      case GoogleSignInExceptionCode.canceled:
        return 'Đăng nhập bằng Google đã bị hủy bỏ.';
      default:
        return 'Lỗi đăng nhập Google. Vui lòng thử lại.';
    }
  }

  return error.toString();
}
