import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/court_card.dart';
import '../../../core/widgets/sort_options.dart';
import '../../../core/widgets/pagination_controls.dart';
import '../widgets/search_header.dart';

class SearchResultScreen extends StatefulWidget {
  final Map<String, dynamic>? searchParams;
  final Map<String, dynamic>? filters;

  const SearchResultScreen({super.key, this.searchParams, this.filters});

  @override
  SearchResultScreenState createState() => SearchResultScreenState();
}

class SearchResultScreenState extends State<SearchResultScreen> {
  String _location = '';
  String? _locationId;
  String _selectedSort = 'price';
  bool _showSortOptions = false;
  bool _loading = false;
  int _total = 0;
  int _currentPage = 1;
  int _totalPages = 1;
  List<dynamic> _courts = [];
  List<dynamic> _searchResults = [];
  bool _showLocationDropdown = false;
  bool _isSearchingLocation = false;

  @override
  void initState() {
    super.initState();
    _location = widget.searchParams?['locationName'] ?? '';
    _locationId = widget.searchParams?['locationId'];
    _selectedSort = widget.filters?['sort'] ?? 'price';
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _courts = List.generate(
        25,
        (index) => {
          '_id': '$index',
          'name': 'Sân cầu lông ${index + 1}',
          'address': 'Quận ${index + 1}',
          'lowestPrice': 150000 + index * 10000,
          'lowestDiscountedPrice': 120000 + index * 10000,
          'highestDiscountPercent': 20,
          'featuredImageUrl':
              'https://lh7-us.googleusercontent.com/RpJsZJpUE7GiSnl6q-zehT1zgdRPVzkYRkzBnfvhq3CRQQaLmZzuxDFq2uLRhlgXEOpQusxAbKRLNsOD5ygXGoO0y0hKGA5s3AKz89G957hGLv20SBiwcIgiAzSrCMXCepOlO6pMkokJkzVA1M212tA',
          'rating': 4.0 + (index % 5) * 0.1,
        },
      );
      _total = 25;
      _totalPages = 8;
      _loading = false;
    });
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
    _fetchData();
  }

  void _handleSortChange(String value) {
    setState(() {
      _selectedSort = value;
      _showSortOptions = false;
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
              onFilterPressed: () {
                context.push('/filter');
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
                  _locationId = location['_id'];
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
                        return CourtCard(
                          court: _courts[index],
                          onTap: () {
                            context.push('/court-detail');
                          },
                        );
                      },
                    ),
            ),
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
              showAsModal: true, //hiển thị dưới dạng modal
              selectedSort: _selectedSort,
              onSelect: (value) {
                _handleSortChange(value);
                setState(() => _showSortOptions = false);
              },
              onClose: () => setState(() => _showSortOptions = false),
            )
          : null,
    );
  }
}
