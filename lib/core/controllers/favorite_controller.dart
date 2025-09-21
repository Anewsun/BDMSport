import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/court_model.dart';
import '../utils/error_util.dart';

class FavoriteController {
  final FirebaseFirestore _db;
  final String _userCollection;

  FavoriteController({
    FirebaseFirestore? firestore,
    String userCollection = 'users',
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _userCollection = userCollection;

  CollectionReference<UserModel> get _usersRef => _db
      .collection(_userCollection)
      .withConverter<UserModel>(
        fromFirestore: (snap, _) =>
            UserModel.fromMap(snap.data()!..['id'] = snap.id),
        toFirestore: (user, _) => user.toMap(),
      );

  Future<List<String>> getFavoriteCourtIds(String userId) async {
    try {
      final doc = await _usersRef.doc(userId).get();
      if (doc.exists) {
        final user = doc.data()!;
        return user.favoriteCourts;
      }
      throw Exception('Không tìm thấy người dùng với ID: $userId');
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }

  Future<void> addToFavorites(String userId, String courtId) async {
    try {
      final doc = await _usersRef.doc(userId).get();
      if (!doc.exists) {
        throw Exception('Không tìm thấy người dùng với ID: $userId');
      }

      final user = doc.data()!;
      final favoriteCourts = List<String>.from(user.favoriteCourts);

      if (favoriteCourts.contains(courtId)) {
        throw Exception('Sân đã có trong danh sách yêu thích');
      }

      favoriteCourts.add(courtId);

      await _usersRef.doc(userId).update({
        'favoriteCourts': favoriteCourts,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }

  Future<void> removeFromFavorites(String userId, String courtId) async {
    try {
      final doc = await _usersRef.doc(userId).get();
      if (!doc.exists) {
        throw Exception('Không tìm thấy người dùng với ID: $userId');
      }

      final user = doc.data()!;
      final favoriteCourts = List<String>.from(user.favoriteCourts);

      if (!favoriteCourts.contains(courtId)) {
        throw Exception('Sân không có trong danh sách yêu thích');
      }

      favoriteCourts.remove(courtId);

      await _usersRef.doc(userId).update({
        'favoriteCourts': favoriteCourts,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }

  Future<bool> isCourtInFavorites(String userId, String courtId) async {
    try {
      final favoriteCourts = await getFavoriteCourtIds(userId);
      return favoriteCourts.contains(courtId);
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }

  Future<List<Court>> getFavoriteCourts(String userId) async {
    try {
      final favoriteCourtIds = await getFavoriteCourtIds(userId);

      if (favoriteCourtIds.isEmpty) {
        return [];
      }

      final courtsRef = FirebaseFirestore.instance
          .collection('courts')
          .withConverter<Court>(
            fromFirestore: (snap, _) => Court.fromFirestore(snap),
            toFirestore: (court, _) => court.toMap(),
          );

      final query = courtsRef.where(
        FieldPath.documentId,
        whereIn: favoriteCourtIds,
      );
      final snap = await query.get();

      return snap.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }

  Future<void> toggleFavorite(String userId, String courtId) async {
    try {
      final isFavorite = await isCourtInFavorites(userId, courtId);

      if (isFavorite) {
        await removeFromFavorites(userId, courtId);
      } else {
        await addToFavorites(userId, courtId);
      }
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }
}

final favoriteControllerProvider = Provider<FavoriteController>((ref) {
  return FavoriteController(firestore: FirebaseFirestore.instance);
});

final favoriteCourtIdsProvider = FutureProvider.family<List<String>, String>((
  ref,
  userId,
) {
  final controller = ref.read(favoriteControllerProvider);
  return controller.getFavoriteCourtIds(userId);
});

final isFavoriteProvider =
    FutureProvider.family<bool, ({String userId, String courtId})>((
      ref,
      params,
    ) {
      final controller = ref.read(favoriteControllerProvider);
      return controller.isCourtInFavorites(params.userId, params.courtId);
    });

final favoriteCourtsProvider = FutureProvider.family<List<Court>, String>((
  ref,
  userId,
) {
  final controller = ref.read(favoriteControllerProvider);
  return controller.getFavoriteCourts(userId);
});
