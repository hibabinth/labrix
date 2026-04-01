import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/location_service.dart';

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;
  const LocationPickerScreen({super.key, this.initialLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  Future<void> _goToMyLocation() async {
    final position = await _locationService.getCurrentPosition();
    if (position != null && _mapController != null) {
      final latLng = LatLng(position.latitude, position.longitude);
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
      setState(() => _selectedLocation = latLng);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Work Location', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (_selectedLocation != null)
            TextButton(
              onPressed: () => Navigator.pop(context, _selectedLocation),
              child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation ?? const LatLng(0, 0),
              zoom: _selectedLocation != null ? 15 : 2,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              if (_selectedLocation == null) _goToMyLocation();
            },
            onTap: (latLng) {
              setState(() => _selectedLocation = latLng);
            },
            markers: _selectedLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('selected'),
                      position: _selectedLocation!,
                    ),
                  }
                : {},
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              onPressed: _goToMyLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: AppColors.primaryColor),
            ),
          ),
          const Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Tap on the map to set your work location. This helps customers find you!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
