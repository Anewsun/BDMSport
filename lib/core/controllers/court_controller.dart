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

  Future<List<Court>> searchCourtsWithAvailableAreas({
    required String locationName,
    required DateTime startTime,
    required DateTime endTime,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    double? maxRating,
    List<String>? courtTypes,
    List<String>? amenities,
    String sortBy = 'rating',
    bool descending = true,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      if (endTime.difference(startTime).inHours < 1) {
        throw Exception('Thời gian thuê sân phải ít nhất 1 giờ');
      }

      final locations = await _searchLocations(keyword: locationName, limit: 1);

      if (locations.isEmpty) {
        return [];
      }

      final locationId = locations.first.id;

      Query<Court> courtQuery = _courtsRef
          .where('locationId', isEqualTo: locationId)
          .where('status', isEqualTo: 'active');

      if (minRating != null) {
        courtQuery = courtQuery.where(
          'rating',
          isGreaterThanOrEqualTo: minRating,
        );
      }
      if (maxRating != null) {
        courtQuery = courtQuery.where('rating', isLessThanOrEqualTo: maxRating);
      }
      if (minPrice != null) {
        courtQuery = courtQuery.where(
          'lowestPrice',
          isGreaterThanOrEqualTo: minPrice,
        );
      }
      if (maxPrice != null) {
        courtQuery = courtQuery.where(
          'lowestPrice',
          isLessThanOrEqualTo: maxPrice,
        );
      }

      courtQuery = courtQuery.orderBy(sortBy, descending: descending);

      final courtSnap = await courtQuery.limit(limit).get();
      final courts = courtSnap.docs.map((d) => d.data()).toList();

      final availableCourts = <Court>[];

      for (final court in courts) {
        final availableAreas = await getAvailableAreasForCourt(
          courtId: court.id,
          startTime: startTime,
          endTime: endTime,
          courtTypes: courtTypes,
          amenities: amenities,
        );

        if (availableAreas.isNotEmpty) {
          availableCourts.add(court);
        }
      }

      return availableCourts;
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }

  Future<List<LocationModel>> searchLocationsByName(String keyword) async {
    return await _searchLocations(keyword: keyword);
  }

  Future<List<LocationModel>> _searchLocations({
    required String keyword,
    int limit = 10,
  }) async {
    try {
      if (keyword.isEmpty) {
        return [];
      }

      Query<LocationModel> query = _locationsRef
          .orderBy('name')
          .startAt([keyword])
          .endAt(['$keyword\uf8ff'])
          .limit(limit);

      final snap = await query.get();
      return snap.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }

  Future<List<LocationModel>> getLocations({int limit = 50}) async {
    try {
      final query = _locationsRef.orderBy('name').limit(limit);

      final snap = await query.get();
      return snap.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }

  Future<List<Area>> getAvailableAreasForCourt({
    required String courtId,
    required DateTime startTime,
    required DateTime endTime,
    List<String>? courtTypes,
    List<String>? amenities,
  }) async {
    try {
      Query<Area> areaQuery = _areasRef
          .where('courtId', isEqualTo: courtId)
          .where('status', isEqualTo: 'available');

      if (courtTypes != null && courtTypes.isNotEmpty) {
        areaQuery = areaQuery.where('type', whereIn: courtTypes);
      }

      if (amenities != null && amenities.isNotEmpty) {
        for (final amenity in amenities) {
          areaQuery = areaQuery.where('amenities.$amenity', isEqualTo: true);
        }
      }

      final areaSnap = await areaQuery.get();
      final areas = areaSnap.docs.map((doc) => doc.data()).toList();

      final availableAreas = <Area>[];

      for (final area in areas) {
        final isAvailable = await _checkAreaAvailability(
          areaId: area.id!,
          startTime: startTime,
          endTime: endTime,
        );

        if (isAvailable) {
          availableAreas.add(area);
        }
      }

      return availableAreas;
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }

  Future<bool> _checkAreaAvailability({
    required String areaId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final bookingQuery = await _db
          .collection('bookings')
          .where('areaId', isEqualTo: areaId)
          .where('status', whereIn: ['confirmed', 'pending'])
          .where('endTime', isGreaterThan: Timestamp.fromDate(startTime))
          .where('startTime', isLessThan: Timestamp.fromDate(endTime))
          .get();

      return bookingQuery.docs.isEmpty;
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

  Stream<List<Area>> getAreasStream(String courtId) {
    try {
      return _areasRef
          .where('courtId', isEqualTo: courtId)
          .where('status', isEqualTo: 'available')
          .orderBy('price', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      throw Exception(getFriendlyErrorMessage(e));
    }
  }

  Stream<Court> getCourtStream(String courtId) {
    try {
      return _courtsRef.doc(courtId).snapshots().map((snap) {
        if (snap.exists) {
          return snap.data()!;
        } else {
          throw Exception('Không tìm thấy sân với ID: $courtId');
        }
      });
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

final courtStreamProvider = StreamProvider.family<Court, String>((
  ref,
  courtId,
) {
  final controller = ref.read(courtControllerProvider);
  return controller.getCourtStream(courtId);
});

final areasStreamProvider = StreamProvider.family<List<Area>, String>((
  ref,
  courtId,
) {
  final controller = ref.read(courtControllerProvider);
  return controller.getAreasStream(courtId);
});

final searchLocationsProvider =
    FutureProvider.family<List<LocationModel>, String>((ref, keyword) async {
      final controller = ref.read(courtControllerProvider);
      return await controller.searchLocationsByName(keyword);
    });

final locationsProvider = FutureProvider<List<LocationModel>>((ref) async {
  final controller = ref.read(courtControllerProvider);
  return await controller.getLocations();
});

final searchCourtsProvider =
    FutureProvider.family<List<Court>, Map<String, dynamic>>((
      ref,
      params,
    ) async {
      final controller = ref.read(courtControllerProvider);
      return await controller.searchCourtsWithAvailableAreas(
        locationName: params['locationName'],
        startTime: params['startTime'],
        endTime: params['endTime'],
        minPrice: params['minPrice'],
        maxPrice: params['maxPrice'],
        minRating: params['minRating'],
        maxRating: params['maxRating'],
        courtTypes: params['courtTypes'],
        amenities: params['amenities'],
        sortBy: params['sortBy'] ?? 'rating',
        descending: params['descending'] ?? true,
        page: params['page'] ?? 1,
        limit: params['limit'] ?? 10,
      );
    });
