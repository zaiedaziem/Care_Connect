import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';

class ClinicLocationsPage extends StatefulWidget {
  const ClinicLocationsPage({super.key});

  @override
  State<ClinicLocationsPage> createState() => _ClinicLocationsPageState();
}

class _ClinicLocationsPageState extends State<ClinicLocationsPage> {
  final LocationService _locationService = LocationService();
  final CameraPosition _skudaiInitialPosition = const CameraPosition(
    target: LatLng(1.5374, 103.6578), // Skudai coordinates
    zoom: 14,
  );

  late GoogleMapController _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClinicsAndLocation();
  }

  Future<void> _loadClinicsAndLocation() async {
    setState(() => _isLoading = true);

    // Get current position
    _currentPosition = await _locationService.getCurrentPosition();

    // Load clinic locations (hardcoded for Skudai area)
    _markers = {
      // User's current location marker
      if (_currentPosition != null)
        Marker(
          markerId: const MarkerId('current_location'),
          position:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),

      // Clinic markers
      Marker(
        markerId: const MarkerId('clinic1'),
        position: const LatLng(1.5385, 103.6582),
        infoWindow: const InfoWindow(title: 'Skudai Medical Center'),
      ),
      Marker(
        markerId: const MarkerId('clinic2'),
        position: const LatLng(1.5362, 103.6601),
        infoWindow: const InfoWindow(title: 'Columbia Asia Hospital'),
      ),
      Marker(
        markerId: const MarkerId('clinic3'),
        position: const LatLng(1.5350, 103.6550),
        infoWindow: const InfoWindow(title: 'Klinik Kesihatan Skudai'),
      ),
      Marker(
        markerId: const MarkerId('clinic4'),
        position: const LatLng(1.5400, 103.6530),
        infoWindow: const InfoWindow(title: 'Pusat Perubatan Universiti'),
      ),
    };

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinics Around Skudai'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadClinicsAndLocation,
            tooltip: 'Refresh Location',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: _skudaiInitialPosition,
              onMapCreated: (controller) {
                _mapController = controller;
                _centerMap();
              },
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: false,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centerMap,
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

  void _centerMap() {
    if (_currentPosition != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
      );
    } else {
      _mapController.animateCamera(
        CameraUpdate.newLatLng(_skudaiInitialPosition.target),
      );
    }
  }
}
