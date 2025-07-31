import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/custom_header.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final policyDate = DateTime.now();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: CustomHeader(
                title: 'Chính sách bảo mật',
                showBackIcon: true,
                onBackPress: () => context.pop(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chính sách bảo mật',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Quyền riêng tư của bạn rất quan trọng đối với chúng tôi. '
                      'Chính sách bảo mật này giải thích cách chúng tôi thu thập, '
                      'sử dụng và tiết lộ thông tin về bạn khi bạn sử dụng dịch vụ của chúng tôi.',
                      style: TextStyle(fontSize: 16, height: 1.4),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Thông tin chúng tôi thu thập',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Chúng tôi thu thập thông tin mà bạn cung cấp trực tiếp cho chúng tôi, '
                      'chẳng hạn như khi bạn tạo tài khoản, thực hiện giao dịch mua hoặc liên hệ với chúng tôi để được hỗ trợ.',
                      style: TextStyle(fontSize: 16, height: 1.4),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Chúng tôi sử dụng thông tin này như thế nào?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Chúng tôi sử dụng thông tin này cho:',
                      style: TextStyle(fontSize: 16, height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '- Cung cấp, duy trì và cải thiện các dịch vụ của chúng tôi.',
                            style: TextStyle(fontSize: 16, height: 1.4),
                          ),
                          Text(
                            '- Xử lý giao dịch và gửi cho bạn thông tin liên quan.',
                            style: TextStyle(fontSize: 16, height: 1.4),
                          ),
                          Text(
                            '- Trao đổi với bạn về sản phẩm, dịch vụ và chương trình khuyến mãi.',
                            style: TextStyle(fontSize: 16, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Chia sẻ thông tin của bạn',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Chúng tôi không bán thông tin cá nhân của bạn. '
                      'Chúng tôi có thể chia sẻ thông tin của bạn với các nhà cung cấp dịch vụ bên thứ ba '
                      'để thực hiện dịch vụ thay mặt chúng tôi.',
                      style: TextStyle(fontSize: 16, height: 1.4),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Quyền của bạn',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Bạn có quyền truy cập, chỉnh sửa hoặc xóa thông tin cá nhân của mình. '
                      'Để thực hiện các quyền này, vui lòng liên hệ với chúng tôi.',
                      style: TextStyle(fontSize: 16, height: 1.4),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Những thay đổi đối với Chính sách bảo mật này',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Chúng tôi có thể cập nhật Chính sách bảo mật của mình theo thời gian. '
                      'Chúng tôi sẽ thông báo cho bạn về bất kỳ thay đổi nào bằng cách đăng Chính sách bảo mật mới trên trang này.',
                      style: TextStyle(fontSize: 16, height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Chính sách này có hiệu lực kể từ ${formatDate(policyDate)}.',
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
