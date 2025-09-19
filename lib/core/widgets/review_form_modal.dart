import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

typedef ReviewSubmitCallback = void Function(Map<String, dynamic> reviewData);

class ReviewFormModal extends StatefulWidget {
  final bool visible;
  final bool isEditing;
  final Map<String, dynamic>? review;
  final VoidCallback onClose;
  final ReviewSubmitCallback onSubmit;

  const ReviewFormModal({
    super.key,
    required this.visible,
    this.isEditing = false,
    this.review,
    required this.onClose,
    required this.onSubmit,
  });

  @override
  State<ReviewFormModal> createState() => _ReviewFormModalState();
}

class _ReviewFormModalState extends State<ReviewFormModal> {
  int _rating = 0;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  bool _isAnonymous = false;

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _populateForm();
  }

  @override
  void didUpdateWidget(ReviewFormModal oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.visible &&
        widget.review != null &&
        (oldWidget.review != widget.review || !oldWidget.visible)) {
      _populateForm();
    }
  }

  void _populateForm() {
    if (widget.isEditing && widget.review != null) {
      setState(() {
        _rating = widget.review!['rating'] ?? 0;
        _titleController.text = widget.review!['title'] ?? '';
        _commentController.text = widget.review!['comment'] ?? '';
        _isAnonymous = widget.review!['isAnonymous'] ?? false;
      });
    } else {
      // Reset form khi tạo mới
      setState(() {
        _rating = 0;
        _titleController.clear();
        _commentController.clear();
        _isAnonymous = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    return AnimatedModal(
      visible: widget.visible,
      onClose: widget.onClose,
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.isEditing ? 'Chỉnh sửa đánh giá' : 'Viết đánh giá',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: FaIcon(
                        index < _rating
                            ? FontAwesomeIcons.solidStar
                            : FontAwesomeIcons.star,
                        color: Colors.amber,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          _rating = index + 1;
                        });
                      },
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                ),
                maxLength: 100,
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: 'Nội dung đánh giá',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 12,
                  ),
                ),
                maxLines: 3,
                minLines: 3,
                maxLength: 500,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  const Text(
                    'Ẩn danh:',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: _isAnonymous,
                    onChanged: (value) {
                      setState(() {
                        _isAnonymous = value;
                      });
                    },
                    activeColor: const Color(0xFF1167B1),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: widget.onClose,
                      child: const Text(
                        'Hủy',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1167B1),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        widget.onSubmit({
                          'rating': _rating,
                          'title': _titleController.text,
                          'comment': _commentController.text,
                          'isAnonymous': _isAnonymous,
                        });
                      },
                      child: const Text(
                        'Gửi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedModal extends StatelessWidget {
  final bool visible;
  final Widget child;
  final VoidCallback onClose;

  const AnimatedModal({
    super.key,
    required this.visible,
    required this.child,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onClose,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.black54),
            ),
          ),
          Center(
            child: AnimatedOpacity(
              opacity: visible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Material(color: Colors.transparent, child: child),
            ),
          ),
        ],
      ),
    );
  }
}
