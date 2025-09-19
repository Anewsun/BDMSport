import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/widgets/loading_overlay.dart';

class CourtMap extends StatefulWidget {
  final String? address;
  final bool isLoading;
  final bool isNotFound;

  const CourtMap({
    super.key,
    this.address,
    this.isLoading = false,
    this.isNotFound = false,
  });

  @override
  State<CourtMap> createState() => _CourtMapState();
}

class _CourtMapState extends State<CourtMap> {
  LatLng? _courtLocation;
  bool _isLoadingLocation = true;
  String? _errorMessage;
  late MapController _mapController;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    if (widget.address != null && widget.address!.isNotEmpty) {
      _getLocationFromAddress(widget.address!);
    } else {
      setState(() {
        _isLoadingLocation = false;
        _errorMessage = 'Không có địa chỉ';
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CourtMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.address != widget.address && widget.address != null) {
      _getLocationFromAddress(widget.address!);
    }
  }

  Future<void> _getLocationFromAddress(String address) async {
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = null;
      _courtLocation = null;
    });

    try {
      final locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        final location = locations.first;
        setState(() {
          _courtLocation = LatLng(location.latitude, location.longitude);
          _isLoadingLocation = false;
        });

        if (_isMapReady && _courtLocation != null) {
          _mapController.move(_courtLocation!, 15);
        }
      } else {
        setState(() {
          _isLoadingLocation = false;
          _errorMessage = 'Không tìm thấy địa chỉ: $address';
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _errorMessage = 'Lỗi khi tìm địa chỉ: ${e.toString()}';
      });
    }
  }

  void _onMapReady() {
    setState(() {
      _isMapReady = true;
    });

    if (_courtLocation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(_courtLocation!, 15);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: widget.isLoading || _isLoadingLocation,
      child: Container(
        height: 250,
        margin: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _buildMapContent(),
      ),
    );
  }

  Widget _buildMapContent() {
    if (widget.isNotFound || _errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 48, color: Colors.red),
              const SizedBox(height: 10),
              Text(
                _errorMessage ?? 'Không tìm thấy địa chỉ sân cầu lông',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_courtLocation == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 48, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              'Đang tải bản đồ...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  _courtLocation ?? const LatLng(10.762622, 106.660172),
              initialZoom: 15.0,
              onMapReady: _onMapReady,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.de/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.bdmsport.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _courtLocation!,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (widget.address != null)
            Positioned(
              bottom: 10,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 230),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  widget.address!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
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
