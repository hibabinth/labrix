import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodel/nearby_workers_viewmodel.dart';
import 'worker_detail_screen.dart';

class WorkerMapScreen extends StatefulWidget {
  const WorkerMapScreen({super.key});

  @override
  State<WorkerMapScreen> createState() => _WorkerMapScreenState();
}

class _WorkerMapScreenState extends State<WorkerMapScreen> {
  GoogleMapController? _mapController;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NearbyWorkersViewModel>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final nearbyVM = Provider.of<NearbyWorkersViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Professionals', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: AppColors.primaryColor),
            onPressed: () => _goToMyLocation(nearbyVM),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 🗺️ The Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                nearbyVM.currentPosition?.latitude ?? 0,
                nearbyVM.currentPosition?.longitude ?? 0,
              ),
              zoom: 13,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: _buildMarkers(nearbyVM),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // 🔄 Loading Indicator
          if (nearbyVM.isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),

          // 📏 Radius Slider
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: _buildRadiusSlider(nearbyVM),
          ),

          // 📇 Bottom Worker Card (Slide in on marker tap)
          // (Implemented as a placeholder for now, you can add state for selected worker)
        ],
      ),
    );
  }

  Widget _buildRadiusSlider(NearbyWorkersViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Search Radius', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${vm.radiusKm.floor()} km', 
                style: const TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: vm.radiusKm,
            min: 1,
            max: 50,
            divisions: 10,
            activeColor: AppColors.primaryColor,
            onChanged: (val) => vm.setRadius(val),
          ),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers(NearbyWorkersViewModel vm) {
    final markers = <Marker>{};

    for (var worker in vm.nearbyWorkers) {
      if (worker.latitude != null && worker.longitude != null) {
        markers.add(
          Marker(
            markerId: MarkerId(worker.id),
            position: LatLng(worker.latitude!, worker.longitude!),
            infoWindow: InfoWindow(
              title: worker.name,
              snippet: '${worker.category} • ★ ${worker.rating}',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WorkerDetailScreen(worker: worker)),
                );
              },
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
               _getCategoryHue(worker.category),
            ),
          ),
        );
      }
    }
    return markers;
  }

  double _getCategoryHue(String category) {
    switch (category.toLowerCase()) {
      case 'plumber': return BitmapDescriptor.hueAzure;
      case 'electrician': return BitmapDescriptor.hueOrange;
      case 'carpenter': return BitmapDescriptor.hueViolet;
      default: return BitmapDescriptor.hueRed;
    }
  }

  void _goToMyLocation(NearbyWorkersViewModel vm) {
    if (vm.currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(vm.currentPosition!.latitude, vm.currentPosition!.longitude),
            zoom: 14,
          ),
        ),
      );
    }
  }
}
