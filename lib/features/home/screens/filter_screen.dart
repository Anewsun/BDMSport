import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import '../../../core/widgets/custom_header.dart';

class FilterScreen extends StatefulWidget {
  final Map<String, dynamic>? searchParams;
  final Map<String, dynamic>? filters;

  const FilterScreen({super.key, this.searchParams, this.filters});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  double _minPrice = 0;
  double _maxPrice = 500000;
  double _minRating = 0;
  double _maxRating = 5;
  final List<String> _selectedCourtTypes = [];
  final List<String> _selectedAmenities = [];
  int _activeFilterCount = 0;

  final List<String> _courtTypes = [
    'Sân tiêu chuẩn',
    'Sân cao cấp',
    'Sân thi đấu',
    'Sân tập luyện',
  ];

  final List<Map<String, dynamic>> _amenities = [
    {'id': '1', 'name': 'Điều hòa', 'icon': Ionicons.snow},
    {'id': '2', 'name': 'Quạt mát', 'icon': Ionicons.flower},
    {'id': '3', 'name': 'Thảm lót', 'icon': Ionicons.layers},
    {'id': '4', 'name': 'Vòi sen', 'icon': Ionicons.water},
    {'id': '5', 'name': 'Chỗ đỗ xe', 'icon': Ionicons.car},
    {'id': '6', 'name': 'Quán nước', 'icon': Ionicons.cafe},
    {'id': '7', 'name': 'WC riêng', 'icon': Ionicons.man},
  ];

  @override
  void initState() {
    super.initState();
    _updateActiveFilterCount();
  }

  void _updateActiveFilterCount() {
    int count = 0;
    if (_minPrice > 0 || _maxPrice < 500000) count++;
    if (_minRating > 0 || _maxRating < 5) count++;
    count += _selectedCourtTypes.length;
    count += _selectedAmenities.length;

    setState(() {
      _activeFilterCount = count;
    });
  }

  void _toggleCourtType(String type) {
    setState(() {
      if (_selectedCourtTypes.contains(type)) {
        _selectedCourtTypes.remove(type);
      } else {
        _selectedCourtTypes.add(type);
      }
      _updateActiveFilterCount();
    });
  }

  void _toggleAmenity(String amenityId) {
    setState(() {
      if (_selectedAmenities.contains(amenityId)) {
        _selectedAmenities.remove(amenityId);
      } else {
        _selectedAmenities.add(amenityId);
      }
      _updateActiveFilterCount();
    });
  }

  void _resetFilters() {
    setState(() {
      _minPrice = 0;
      _maxPrice = 500000;
      _minRating = 0;
      _maxRating = 5;
      _selectedCourtTypes.clear();
      _selectedAmenities.clear();
      _activeFilterCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: CustomHeader(
            title: 'Bộ lọc ($_activeFilterCount)',
            onBackPress: () => Navigator.pop(context),
            showBackIcon: true,
            rightComponent: null,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Đánh giá (★)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Từ: $_minRating★',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Slider(
                      value: _minRating,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      label: _minRating.toStringAsFixed(1),
                      activeColor: Colors.blue,
                      inactiveColor: Colors.blue.shade100,
                      onChanged: (value) {
                        setState(() {
                          _minRating = value;
                          _updateActiveFilterCount();
                        });
                      },
                    ),
                    Text(
                      'Đến: $_maxRating★',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Slider(
                      value: _maxRating,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      label: _maxRating.toStringAsFixed(1),
                      activeColor: Colors.blue,
                      inactiveColor: Colors.blue.shade100,
                      onChanged: (value) {
                        setState(() {
                          _maxRating = value;
                          _updateActiveFilterCount();
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Khoảng giá (VND)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Từ: ${_minPrice.toInt()}đ',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Đến: ${_maxPrice.toInt()}đ',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _maxPrice,
                      min: 50000,
                      max: 500000,
                      divisions: 9,
                      label: '${_maxPrice.toInt()}đ',
                      activeColor: Colors.blue,
                      inactiveColor: Colors.blue.shade100,
                      onChanged: (value) {
                        setState(() {
                          _maxPrice = value;
                          _updateActiveFilterCount();
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Loại sân',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _courtTypes.map((type) {
                        final isSelected = _selectedCourtTypes.contains(type);
                        return FilterChip(
                          label: Text(
                            type,
                            style: const TextStyle(fontSize: 16),
                          ),
                          selected: isSelected,
                          onSelected: (_) => _toggleCourtType(type),
                          selectedColor: Colors.blue[100],
                          checkmarkColor: Colors.blue,
                          backgroundColor: Colors.grey[300],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Tiện nghi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 0.8,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                      itemCount: _amenities.length,
                      itemBuilder: (context, index) {
                        final amenity = _amenities[index];
                        final isSelected = _selectedAmenities.contains(
                          amenity['id'],
                        );
                        return GestureDetector(
                          onTap: () => _toggleAmenity(amenity['id']),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue[50]
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(amenity['icon'], size: 24),
                                const SizedBox(height: 4),
                                Text(
                                  amenity['name'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetFilters,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.black, width: 1.5),
                      ),
                      child: const Text(
                        'Đặt lại',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'minPrice': _minPrice,
                          'maxPrice': _maxPrice,
                          'minRating': _minRating,
                          'maxRating': _maxRating,
                          'courtTypes': _selectedCourtTypes,
                          'amenities': _selectedAmenities,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Áp dụng',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
