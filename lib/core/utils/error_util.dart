import 'package:firebase_auth/firebase_auth.dart';

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
        return 'Tài khoản hoặc mật khẩu không đúng.';
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
      default:
        return 'Đã xảy ra lỗi không xác định.';
    }
  }
  return error.toString();
}
