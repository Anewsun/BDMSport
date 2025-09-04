import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/court_model.dart';
import '../../../core/models/location_model.dart';
import '../../../core/utils/error_util.dart';

class CourtController {
  final FirebaseFirestore _db;
  final String _courtCollection;
  final String _locationCollection;

  CourtController({
    FirebaseFirestore? firestore,
    String courtCollection = 'courts',
    String locationCollection = 'locations',
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _courtCollection = courtCollection,
       _locationCollection = locationCollection;

  CollectionReference<Court> get _courtsRef => _db
      .collection(_courtCollection)
      .withConverter<Court>(
        fromFirestore: (snap, _) => Court.fromFirestore(snap),
        toFirestore: (court, _) => court.toMap(),
      );

  CollectionReference<LocationModel> get _locationsRef => _db
      .collection(_locationCollection)
      .withConverter<LocationModel>(
        fromFirestore: (snap, _) => LocationModel.fromFirestore(snap),
        toFirestore: (loc, _) => loc.toMap(),
      );

  Future<List<Court>> getDiscountedCourts() async {
    try {
      final snap = await _courtsRef
          .where('highestDiscountPercent', isGreaterThan: 0)
          .where('status', isEqualTo: 'active')
          .get();

      final courts = <Court>[];
      for (var doc in snap.docs) {
        final court = doc.data();
        courts.add(court);
      }

      return courts;
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }

  Future<List<Map<String, dynamic>>> getTopLocationsWithCourts() async {
    try {
      final snap = await _courtsRef.get();
      final counts = <String, int>{};
      for (var doc in snap.docs) {
        final court = doc.data();
        final locationId = court.locationId;
        counts[locationId] = (counts[locationId] ?? 0) + 1;
      }

      final locSnap = await _locationsRef.get();
      final result = <Map<String, dynamic>>[];
      for (var d in locSnap.docs) {
        final loc = d.data();
        final count = counts[d.id] ?? 0;
        if (count > 0) {
          result.add({
            'id': d.id,
            'name': loc.name,
            'image': loc.image,
            'courtCount': count,
          });
        }
      }

      result.sort(
        (a, b) => (b['courtCount'] as int).compareTo(a['courtCount'] as int),
      );
      return result;
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }

  Future<List<Court>> searchCourtsByLocationAndTime({
    required String locationId,
    required DateTime startTime,
    required DateTime endTime,
    String sortBy = 'rating',
    bool descending = true,
  }) async {
    try {
      Query<Court> q = _courtsRef
          .where('locationId', isEqualTo: locationId)
          .where('status', isEqualTo: 'active')
          .orderBy(sortBy, descending: descending);

      final snap = await q.get();
      final courts = snap.docs.map((d) => d.data()).toList();

      // thêm hàm tính area có được book hay chưa(cần xem xét lại DB cho phù hợp)
      return courts;
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }

  Future<List<LocationModel>> searchLocationsByKeyword(String keyword) async {
    try {
      final snap = await _locationsRef
          .orderBy('name')
          .startAt([keyword])
          .endAt(['$keyword\uf8ff'])
          .limit(10)
          .get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }

  Future<List<Court>> searchCourtsWithSorting({
    required String locationId,
    required DateTime startTime,
    required DateTime endTime,
    String sortBy = 'rating',
    bool descending = true,
  }) async {
    try {
      Query<Court> q = _courtsRef
          .where('locationId', isEqualTo: locationId)
          .where('status', isEqualTo: 'active')
          .orderBy(sortBy, descending: descending);

      final snap = await q.get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }

  Future<List<Court>> getActiveCourts() async {
    try {
      final snap = await _courtsRef
          .where('status', isEqualTo: 'active')
          .orderBy('rating', descending: true)
          .get();

      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }
}

final courtControllerProvider = Provider<CourtController>((ref) {
  return CourtController(firestore: FirebaseFirestore.instance);
});
