import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/court_model.dart';
import '../models/location_model.dart';
import '../models/area_model.dart';
import '../utils/error_util.dart';

class CourtController {
  final FirebaseFirestore _db;
  final String _courtCollection;
  final String _locationCollection;
  final String _areaCollection;

  CourtController({
    FirebaseFirestore? firestore,
    String courtCollection = 'courts',
    String locationCollection = 'locations',
    String areaCollection = 'areas',
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _courtCollection = courtCollection,
       _locationCollection = locationCollection,
       _areaCollection = areaCollection;

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

  CollectionReference<Area> get _areasRef => _db
      .collection(_areaCollection)
      .withConverter<Area>(
        fromFirestore: (snap, _) => Area.fromFirestore(snap),
        toFirestore: (area, _) => area.toFirestore(),
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
      return courts;
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

  Future<List<Area>> getAvailableAreasByCourt({required String courtId}) async {
    try {
      final query = _areasRef
          .where('courtId', isEqualTo: courtId)
          .where('status', isEqualTo: 'available')
          .orderBy('price', descending: true);

      final snap = await query.get();
      final areas = snap.docs.map((doc) => doc.data()).toList();

      return areas;
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> getAmenityDetails(String amenityId) async {
    try {
      final doc = await _db.collection('amenities').doc(amenityId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      throw Exception('Không tìm thấy thông tin tiện nghi');
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }

  Future<Court> getCourtById(String courtId) async {
    try {
      final doc = await _courtsRef.doc(courtId).get();
      if (doc.exists) {
        return doc.data()!;
      } else {
        throw Exception('Không tìm thấy sân với ID: $courtId');
      }
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

final courtFutureProvider = FutureProvider.family<Court, String>((
  ref,
  courtId,
) async {
  final controller = ref.read(courtControllerProvider);
  return await controller.getCourtById(courtId);
});

final areasFutureProvider = FutureProvider.family<List<Area>, String>((
  ref,
  courtId,
) async {
  final controller = ref.read(courtControllerProvider);
  return await controller.getAvailableAreasByCourt(courtId: courtId);
});
