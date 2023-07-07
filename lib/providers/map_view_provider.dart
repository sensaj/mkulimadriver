import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mkulimadriver/models/request.dart';
import 'package:mkulimadriver/models/schedule.dart';
import 'package:mkulimadriver/services/helper_services.dart';

class MapViewProvider extends ChangeNotifier {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  LatLng? _driverPosition;
  Map<String, dynamic>? _mapErrors;
  late GoogleMapController _googleMapController;
  late CameraPosition _initialCameraPosition;
  bool _isLoading = false;
  List<ClientRequest> _requests = [];
  String _currentLocName = "---";

  Set<Marker> _markers = {};
  Map<String, dynamic>? get mapErrors => _mapErrors;

  LatLng? get driverPosition => _driverPosition;
  bool get isLoading => _isLoading;
  String get currentLocName => _currentLocName;
  CameraPosition get initialCameraPosition => _initialCameraPosition;
  GoogleMapController get googleMapController => _googleMapController;
  Set<Marker> get markers => _markers;
  List<ClientRequest> get requests => _requests;

  MapViewProvider(context) {
    determinePosition(context);
  }
  changePosition(LatLng position) async {
    _driverPosition = position;
    _currentLocName = await helper.getLocationName(location: position);
    notifyListeners();
  }

  updateUserPositionOnMap(DriverSchedule schedule) async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _driverPosition = LatLng(position.latitude, position.longitude);

    try {
      DocumentReference scheduleDoc =
          FirebaseFirestore.instance.collection('schedules').doc(schedule.id);

      await scheduleDoc.update(
          {'driver_position': '${position.latitude},${position.longitude}'});

      print('Schedule-------Document updated successfully');
    } catch (e) {
      print('Error: $e');
    }
    // _markers.removeWhere((m) => m.markerId.value == "user_position");

    notifyListeners();
    return;
  }

  initMap(List<ClientRequest> requests) async {
    // _initialCameraPosition = CameraPosition(target: _driverPosition!, zoom: 5);
    // _addMarker(_driverPosition!, "user_position",
    //     icon: BitmapDescriptor.defaultMarker);
    _requests = requests;
    _createClientsMarkers(requests);
    notifyListeners();
  }

  onCreated(GoogleMapController controller) {
    _googleMapController = controller;
    notifyListeners();
  }

  void onCamerMove(CameraPosition position) {
    // _driverPosition = position.target;
    // notifyListeners();
  }

  void _addMarker(LatLng location, String address,
      {BitmapDescriptor? icon, String? markerId}) {
    _markers.add(Marker(
      markerId: MarkerId(markerId ?? location.toString()),
      position: location,
      infoWindow: InfoWindow(title: "Pickup Location", snippet: address),
      icon: icon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    ));
  }

  Future<void> _createClientsMarkers(List<ClientRequest> requests) async {
    requests.forEach((request) {
      if (request.senderPosition != null && request.receiverPosition != null) {
        _addMarker(request.senderPosition!, "${request.senderPosition!}");
        _addMarker(request.receiverPosition!, "${request.receiverPosition!}",
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen));
      }
    });
    notifyListeners();
  }

  Future determinePosition(context) async {
    _isLoading = true;
    notifyListeners();
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _mapErrors = {
        "header": "Location Disabled",
        "msg": "Enable location services to continue"
      };
      _isLoading = false;
      notifyListeners();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _mapErrors = {
          "header": "Location Denied",
          "msg": "Enable app to access location in settings"
        };
        _isLoading = false;
        notifyListeners();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _mapErrors = {
        "header": "Location Denied",
        "msg":
            "Location permissions are permanently denied, we cannot request permissions."
      };
      _isLoading = false;
      notifyListeners();
      return;
    }
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    _driverPosition = LatLng(position.latitude, position.longitude);
    _currentLocName = await helper.getLocationName(
        location: LatLng(position.latitude, position.longitude));
    _initialCameraPosition =
        CameraPosition(target: _driverPosition!, zoom: 11.5);

    _isLoading = false;
    _mapErrors = null;
    notifyListeners();
  }

  startJourney(DriverSchedule schedule, context) async {
    _isLoading = true;
    notifyListeners();
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _driverPosition = LatLng(position.latitude, position.longitude);

      DocumentReference scheduleDoc =
          FirebaseFirestore.instance.collection('schedules').doc(schedule.id);

      await scheduleDoc.update({
        'status': 'started',
        'driver_position': '${position.latitude},${position.longitude}'
      });

      print('Document updated successfully');
    } catch (e) {
      print('Error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }
}
