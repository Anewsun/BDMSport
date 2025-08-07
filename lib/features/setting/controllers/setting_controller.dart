import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/auth/auth_repository.dart';
import '../../../core/models/user_model.dart';
import '../../auth/controllers/sign_in_controller.dart';

class SettingController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  SettingController(this.ref) : super(const AsyncValue.data(null));

  Future<void> updateAvatar(File imageFile, String userId) async {
    try {
      state = const AsyncValue.loading();
      final currentUser = ref.read(signInControllerProvider).user;
      final oldAvatarUrl = currentUser?.avatar;

      final isDefaultAvatar =
          oldAvatarUrl?.contains('default-avatar.jpg') ?? false;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_avatars')
          .child('$userId-$timestamp.jpg');

      await _retry(() => storageRef.putFile(imageFile));
      final downloadUrl = await _retry(() => storageRef.getDownloadURL());

      await _updateUserField(userId, 'avatar', downloadUrl);

      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(avatar: downloadUrl);
        ref.read(signInControllerProvider.notifier).updateUser(updatedUser);
      }

      if (oldAvatarUrl != null && !isDefaultAvatar) {
        try {
          await _retry(
            () => FirebaseStorage.instance.refFromURL(oldAvatarUrl).delete(),
          );
        } catch (e) {
          debugPrint('Không thể xóa ảnh cũ: $e');
        }
      }

      await ref.read(signInControllerProvider.notifier).syncUserState();

      Fluttertoast.showToast(
        msg: "Cập nhật avatar thành công",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 17
      );

      state = const AsyncValue.data(null);
    } catch (e, st) {
      debugPrint('Lỗi khi cập nhật avatar: $e\n$st');
      Fluttertoast.showToast(
        msg: "Lỗi kết nối. Vui lòng thử lại",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<T> _retry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
  }) async {
    int attempt = 0;
    while (true) {
      try {
        return await operation();
      } catch (e) {
        if (++attempt >= maxRetries) rethrow;
        await Future.delayed(Duration(seconds: attempt));
      }
    }
  }

  Future<void> updateUserInfo({
    required String userId,
    required Map<String, dynamic> updatedData,
  }) async {
    state = const AsyncValue.loading();
    try {
      if (userId.isEmpty) throw ArgumentError('User ID cannot be empty');

      updatedData.remove('email');

      await ref
          .read(authRepositoryProvider)
          .firestore
          .collection('users')
          .doc(userId)
          .update({...updatedData, 'updatedAt': FieldValue.serverTimestamp()});

      final snapshot = await ref
          .read(authRepositoryProvider)
          .firestore
          .collection('users')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        final updatedUser = UserModel.fromMap(snapshot.data()!);
        ref.read(signInControllerProvider.notifier).updateUser(updatedUser);
      }

      if (mounted) {
        Fluttertoast.showToast(
          msg: "Cập nhật thông tin thành công",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }

      state = const AsyncValue.data(null);
    } catch (e, st) {
      debugPrint('Lỗi khi cập nhật thông tin user: $e');
      if (mounted) {
        Fluttertoast.showToast(
          msg: "Lỗi khi cập nhật: ${e.toString()}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> _updateUserField(
    String userId,
    String field,
    dynamic value,
  ) async {
    if (userId.isEmpty) {
      throw ArgumentError('User ID rỗng');
    }

    try {
      await ref
          .read(authRepositoryProvider)
          .firestore
          .collection('users')
          .doc(userId)
          .update({field: value, 'updatedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      print('Lỗi khi cập nhật user field: $e');
      rethrow;
    }
  }
}

final settingControllerProvider =
    StateNotifierProvider<SettingController, AsyncValue<void>>((ref) {
      return SettingController(ref);
    });
