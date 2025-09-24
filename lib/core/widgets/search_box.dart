import 'package:flutter/material.dart';
import 'package:bdm_sport/core/widgets/date_time_picker_row.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../controllers/court_controller.dart';
import 'search_box_container.dart';
import '../models/location_model.dart';

class SearchBox extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>)? onSearch;

  const SearchBox({super.key, this.onSearch});

  @override
  ConsumerState<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends ConsumerState<SearchBox> {
  final TextEditingController _locationController = TextEditingController();
  DateTime checkInDate = DateTime.now();
  DateTime checkOutDate = DateTime.now().add(const Duration(hours: 1));
  List<LocationModel> locations = [];
  List<LocationModel> filteredLocations = [];
  String? selectedLocationId;
  bool showLocationDropdown = false;
  FocusNode _locationFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _locationFocusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _locationFocusNode.removeListener(_handleFocusChange);
    _locationFocusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_locationFocusNode.hasFocus) {
      setState(() {
        showLocationDropdown = true;
      });
      if (_locationController.text.isEmpty) {
        _loadAllLocations();
      }
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            showLocationDropdown = false;
          });
        }
      });
    }
  }

  void _loadAllLocations() {
    ref
        .read(courtControllerProvider)
        .getLocations()
        .then((allLocations) {
          if (mounted) {
            setState(() {
              filteredLocations = allLocations;
              showLocationDropdown =
                  allLocations.isNotEmpty && _locationFocusNode.hasFocus;
            });
          }
        })
        .catchError((e) {
          print('Error loading locations: $e');
          if (mounted) {
            setState(() {
              filteredLocations = [];
              showLocationDropdown = _locationFocusNode.hasFocus;
            });
          }
        });
  }

  void _filterLocations(String query) {
    if (_locationFocusNode.hasFocus) {
      setState(() {
        showLocationDropdown = true;
      });
    }

    if (query.isEmpty) {
      _loadAllLocations();
      return;
    }

    ref
        .read(courtControllerProvider)
        .searchLocationsByName(query)
        .then((searchResults) {
          if (mounted) {
            setState(() {
              filteredLocations = searchResults;
              showLocationDropdown =
                  searchResults.isNotEmpty && _locationFocusNode.hasFocus;
            });
          }
        })
        .catchError((e) {
          print('Error searching locations: $e');
          if (mounted) {
            setState(() {
              filteredLocations = [];
              showLocationDropdown = _locationFocusNode.hasFocus;
            });
          }
        });
  }

  void _selectLocation(LocationModel location) {
    setState(() {
      _locationController.text = location.name;
      selectedLocationId = location.id;
      showLocationDropdown = false;
      _locationFocusNode.unfocus();
    });
  }

  void openDatePicker(bool isCheckIn) async {
    DateTime initialDate = isCheckIn ? checkInDate : checkOutDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      helpText: isCheckIn ? 'Chọn ngày nhận sân' : 'Chọn ngày trả sân',
      locale: const Locale('vi'),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          checkInDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            checkInDate.hour,
            checkInDate.minute,
          );
          if (checkOutDate.isBefore(
            checkInDate.add(const Duration(hours: 1)),
          )) {
            checkOutDate = checkInDate.add(const Duration(hours: 1));
          }
        } else {
          checkOutDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            checkOutDate.hour,
            checkOutDate.minute,
          );
          if (checkOutDate.isBefore(
            checkInDate.add(const Duration(hours: 1)),
          )) {
            checkOutDate = checkInDate.add(const Duration(hours: 1));
          }
        }
      });
    }
  }

  void openTimePicker(bool isCheckIn) async {
    final initialTime = TimeOfDay.fromDateTime(
      isCheckIn ? checkInDate : checkOutDate,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: isCheckIn ? 'Chọn giờ nhận sân' : 'Chọn giờ trả sân',
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          checkInDate = DateTime(
            checkInDate.year,
            checkInDate.month,
            checkInDate.day,
            picked.hour,
            picked.minute,
          );
          if (checkOutDate.isBefore(
            checkInDate.add(const Duration(hours: 1)),
          )) {
            checkOutDate = checkInDate.add(const Duration(hours: 1));
          }
        } else {
          checkOutDate = DateTime(
            checkOutDate.year,
            checkOutDate.month,
            checkOutDate.day,
            picked.hour,
            picked.minute,
          );
          if (checkOutDate.isBefore(
            checkInDate.add(const Duration(hours: 1)),
          )) {
            checkOutDate = checkInDate.add(const Duration(hours: 1));
          }
        }
      });
    }
  }

  void _searchCourts() {
    if (selectedLocationId == null) {
      final typed = _locationController.text.trim().toLowerCase();
      LocationModel? match;
      for (var l in filteredLocations) {
        if (l.name.trim().toLowerCase() == typed) {
          match = l;
          break;
        }
      }

      if (match != null) {
        setState(() {
          selectedLocationId = match!.id;
        });
      } else {
        ref
            .read(courtControllerProvider)
            .searchLocationsByName(_locationController.text)
            .then((res) {
              if (res.isNotEmpty) {
                setState(() {
                  selectedLocationId = res.first.id;
                });
                if (checkOutDate.difference(checkInDate).inHours < 1) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thời gian thuê sân phải ít nhất 1 giờ'),
                    ),
                  );
                  return;
                }
                widget.onSearch?.call(getSearchParams());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng chọn địa điểm')),
                );
              }
            })
            .catchError((e) {
              print('Error finding location by name: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lỗi khi tìm địa điểm')),
              );
            });
        return;
      }
    }

    if (selectedLocationId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn địa điểm')));
      return;
    }

    if (checkOutDate.difference(checkInDate).inHours < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thời gian thuê sân phải ít nhất 1 giờ')),
      );
      return;
    }
    widget.onSearch?.call(getSearchParams());
  }

  Map<String, dynamic> getSearchParams() {
    return {
      'locationId': selectedLocationId,
      'locationName': _locationController.text,
      'startTime': checkInDate,
      'endTime': checkOutDate,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showLocationDropdown = false;
          _locationFocusNode.unfocus();
        });
      },
      child: SearchBoxContainer(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Địa điểm",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                fontFamily: 'Times New Roman',
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),

          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Row(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.locationDot,
                      size: 20,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _locationController,
                        focusNode: _locationFocusNode,
                        onChanged: _filterLocations,
                        decoration: const InputDecoration(
                          hintText: 'Nhập tỉnh/thành phố',
                          hintStyle: TextStyle(color: Colors.black),
                          border: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                        ),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (showLocationDropdown && filteredLocations.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: filteredLocations.length,
                    itemBuilder: (context, index) {
                      final location = filteredLocations[index];
                      return InkWell(
                        onTap: () => _selectLocation(location),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: index < filteredLocations.length - 1
                                ? Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade200,
                                      width: 0.5,
                                    ),
                                  )
                                : null,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  location.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),
          DateTimePickerRow(
            label: "Thời điểm nhận sân",
            dateTime: checkInDate,
            onDateTap: () => openDatePicker(true),
            onTimeTap: () => openTimePicker(true),
          ),
          const SizedBox(height: 16),
          DateTimePickerRow(
            label: "Thời điểm trả sân",
            dateTime: checkOutDate,
            onDateTap: () => openDatePicker(false),
            onTimeTap: () => openTimePicker(false),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _searchCourts,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1167B1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Center(
              child: Text(
                'Tìm kiếm',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
