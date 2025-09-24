import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import '../../../core/controllers/court_controller.dart';
import '../../../core/models/court_model.dart';
import '../../../core/widgets/court_card.dart';
import '../../../core/widgets/sort_options.dart';
import '../../../core/widgets/pagination_controls.dart';
import '../widgets/search_header.dart';

class SearchResultScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? searchParams;

  const SearchResultScreen({super.key, this.searchParams});

  @override
  ConsumerState<SearchResultScreen> createState() => SearchResultScreenState();
}

class SearchResultScreenState extends ConsumerState<SearchResultScreen> {
  String _location = '';
  String? _locationId;
  DateTime? _startTime;
  DateTime? _endTime;
  String _selectedSort = 'rating';
  bool _showSortOptions = false;
  bool _loading = false;
  int _total = 0;
  int _currentPage = 1;
  int _totalPages = 1;
  List<Court> _courts = [];
  List<dynamic> _searchResults = [];
  bool _showLocationDropdown = false;
  bool _isSearchingLocation = false;

  double _minPrice = 0;
  double _maxPrice = 500000;
  double _minRating = 0;
  double _maxRating = 5;
  List<String> _selectedCourtTypes = [];
  List<String> _selectedAmenities = [];

  @override
  void initState() {
    super.initState();

    _location = widget.searchParams?['locationName'] ?? '';
    _locationId = widget.searchParams?['locationId'];
    _startTime = widget.searchParams?['startTime'];
    _endTime = widget.searchParams?['endTime'];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uri = GoRouterState.of(context).uri;
      final base64Params = uri.queryParameters['params'];

      if (base64Params != null && base64Params.isNotEmpty) {
        try {
          final jsonString = utf8.decode(base64Url.decode(base64Params));
          final searchParams = jsonDecode(jsonString) as Map<String, dynamic>;

          final decodedParams = _decodeSearchParams(searchParams);

          setState(() {
            _location = decodedParams['locationName'] ?? '';
            _locationId = decodedParams['locationId'];
            _startTime = decodedParams['startTime'];
            _endTime = decodedParams['endTime'];
          });

          _fetchData();
        } catch (e) {
          print('Error decoding search params: $e');
          _fetchData();
        }
      } else {
        _fetchData();
      }
    });
  }

  Map<String, dynamic> _decodeSearchParams(Map<String, dynamic> params) {
    final decoded = Map<String, dynamic>.from(params);

    if (decoded['startTime'] is String) {
      try {
        decoded['startTime'] = DateTime.parse(decoded['startTime'] as String);
      } catch (e) {
        print('Error parsing startTime: $e');
        decoded['startTime'] = null;
      }
    }

    if (decoded['endTime'] is String) {
      try {
        decoded['endTime'] = DateTime.parse(decoded['endTime'] as String);
      } catch (e) {
        print('Error parsing endTime: $e');
        decoded['endTime'] = null;
      }
    }

    return decoded;
  }

  Future<void> _fetchData() async {
    if (_locationId == null || _startTime == null || _endTime == null) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final searchParams = {
        'locationName': _location,
        'startTime': _startTime!,
        'endTime': _endTime!,
        'minPrice': _minPrice > 0 ? _minPrice : null,
        'maxPrice': _maxPrice < 500000 ? _maxPrice : null,
        'minRating': _minRating > 0 ? _minRating : null,
        'maxRating': _maxRating < 5 ? _maxRating : null,
        'courtTypes': _selectedCourtTypes.isNotEmpty
            ? _selectedCourtTypes
            : null,
        'amenities': _selectedAmenities.isNotEmpty ? _selectedAmenities : null,
        'sortBy': _selectedSort,
        'descending': true,
        'page': _currentPage,
        'limit': 10,
      };

      final courts = await ref.read(searchCourtsProvider(searchParams).future);

      setState(() {
        _courts = courts;
        _total = courts.length;
        _totalPages = (_total / 10).ceil();
        _loading = false;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Lỗi khi tìm kiếm: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 17,
      );
      setState(() {
        _loading = false;
        _courts = [];
        _total = 0;
        _totalPages = 1;
      });
    }
  }

  void _handleSearch() {
    if (_locationId == null) {
      Fluttertoast.showToast(
        msg: "Vui lòng chọn địa điểm từ danh sách",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 17,
      );
      return;
    }
    setState(() {
      _currentPage = 1;
    });
    _fetchData();
  }

  void _handleSortChange(String value) {
    setState(() {
      _selectedSort = value;
      _showSortOptions = false;
      _currentPage = 1;
    });
    _fetchData();
  }

  void _handlePageChange(int newPage) {
    if (newPage >= 1 && newPage <= _totalPages) {
      setState(() {
        _currentPage = newPage;
      });
      _fetchData();
    }
  }

  Future<void> _applyFilters(Map<String, dynamic> filters) async {
    setState(() {
      _minPrice = filters['minPrice'] ?? 0;
      _maxPrice = filters['maxPrice'] ?? 500000;
      _minRating = filters['minRating'] ?? 0;
      _maxRating = filters['maxRating'] ?? 5;
      _selectedCourtTypes = List<String>.from(filters['courtTypes'] ?? []);
      _selectedAmenities = List<String>.from(filters['amenities'] ?? []);
      _currentPage = 1;
    });
    await _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf0f4ff),
      body: SafeArea(
        child: Column(
          children: [
            SearchHeader(
              location: _location,
              onLocationChanged: (value) {
                setState(() {
                  _location = value;
                  _locationId = null;
                  _showLocationDropdown = value.isNotEmpty;
                });
              },
              onSearch: _handleSearch,
              onFilterPressed: () async {
                final filters = await context.push<Map<String, dynamic>>(
                  '/filter',
                  extra: {
                    'minPrice': _minPrice,
                    'maxPrice': _maxPrice,
                    'minRating': _minRating,
                    'maxRating': _maxRating,
                    'courtTypes': _selectedCourtTypes,
                    'amenities': _selectedAmenities,
                  },
                );

                if (filters != null) {
                  await _applyFilters(filters);
                }
              },
              onSortPressed: () {
                setState(() {
                  _showSortOptions = true;
                });
              },
              searchResults: _searchResults,
              showLocationDropdown: _showLocationDropdown,
              isSearchingLocation: _isSearchingLocation,
              onLocationSelected: (location) {
                setState(() {
                  _location = location['name'];
                  _locationId = location['id'];
                  _showLocationDropdown = false;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Text(
                '$_total kết quả được tìm thấy',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _courts.isEmpty
                  ? const Center(
                      child: Text(
                        'Không tìm thấy sân nào phù hợp',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                            childAspectRatio: 0.56,
                          ),
                      itemCount: _courts.length,
                      itemBuilder: (context, index) {
                        final court = _courts[index];
                        return CourtCard(
                          court: court.toMap(),
                          onTap: () {
                            context.push('/court-detail/${court.id}');
                          },
                        );
                      },
                    ),
            ),
            if (_totalPages > 1)
              PaginationControls(
                currentPage: _currentPage,
                totalPages: _totalPages,
                onPageChanged: _handlePageChange,
              ),
          ],
        ),
      ),
      bottomSheet: _showSortOptions
          ? SortOptions(
              showAsModal: true,
              selectedSort: _selectedSort,
              onSelect: _handleSortChange,
              onClose: () => setState(() => _showSortOptions = false),
            )
          : null,
    );
  }
}
