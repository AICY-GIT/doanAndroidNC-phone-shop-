import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class mapPage extends StatefulWidget {
  const mapPage({super.key});

  @override
  State<mapPage> createState() => _mapePageState();
}

class _mapePageState extends State<mapPage> {
  Location _locationController = new Location();

  final Completer<GoogleMapController> _mapControler =
      Completer<GoogleMapController>();

  static const LatLng HCMLat = LatLng(10.8414669, 106.6222061);
  //10.8414669, 106.6222061 //10.812468, 106.655070
  static const LatLng Shop1Lng = LatLng(10.7797, 106.6992);
  //10.8144264, 106.6191543 //10.7723, 106.7044
  static const LatLng Shop2Lng = LatLng(10.8144264, 106.6191543);
  static const LatLng Shop3Lng = LatLng(10.906070, 106.631804);

  LatLng? _currentP = null;

  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    getLocationUpdate().then((_) {
      print("getLocationUpdate completed");
      getPolylinePoints().then(
        (coordinates) {
          print("getPolylinePoints completed");
          generatePolyLineFromPoint(coordinates);
        },
      ).catchError((error) {
        print("Error fetching polyline points: $error");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentP == null
          ? const Center(
              child: Text("Loading..."),
            )
          : GoogleMap(
              // get controler from gg map then put it in _mapControler
              onMapCreated: ((GoogleMapController controller) =>
                  _mapControler.complete(controller)),
              initialCameraPosition: CameraPosition(target: HCMLat, zoom: 13),
              markers: {
                Marker(
                    markerId: MarkerId("_currentLocation"),
                    icon: BitmapDescriptor.defaultMarker,
                    position: _currentP!),
                Marker(
                    markerId: MarkerId("_shop1Location"),
                    icon: BitmapDescriptor.defaultMarker,
                    position: Shop1Lng),
                Marker(
                    markerId: MarkerId("_shop2Location"),
                    icon: BitmapDescriptor.defaultMarker,
                    position: Shop2Lng),
              },
              polylines: Set<Polyline>.of(polylines.values),
            ),
    );
  }

  Future<void> _camereaToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapControler.future;
    CameraPosition _newCamPos = CameraPosition(
      target: pos,
      zoom: 13,
    );
    await controller.animateCamera(CameraUpdate.newCameraPosition(_newCamPos));
  }

  //get user location
  Future<void> getLocationUpdate() async {
    bool _serviceEnable;
    PermissionStatus _permistionGranted;

    _serviceEnable = await _locationController.serviceEnabled();
    if (_serviceEnable) {
      _serviceEnable = await _locationController.requestService();
    } else {
      return;
    }
    _permistionGranted = await _locationController.hasPermission();
    if (_permistionGranted == PermissionStatus.denied) {
      _permistionGranted = await _locationController.requestPermission();
      if (_permistionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationController.onLocationChanged.listen(
      (LocationData currentLocation) {
        if (currentLocation.latitude != Null &&
            currentLocation.longitude != Null) {
          setState(() {
            _currentP =
                LatLng(currentLocation.latitude!, currentLocation.longitude!);
            _camereaToPosition(_currentP!);
          });
        }
      },
    );
  }

  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> PolylineCordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult polylineResult =
        await polylinePoints.getRouteBetweenCoordinates(
            "AIzaSyBuUQXoeB0qP0Amvis2IOivctJGOv59Bw8",
            PointLatLng(Shop1Lng.latitude, Shop1Lng.longitude),
            PointLatLng(Shop2Lng.latitude, Shop2Lng.longitude),
            travelMode: TravelMode.walking);
    if (polylineResult.points.isNotEmpty) {
      polylineResult.points.forEach((PointLatLng point) {
        PolylineCordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(polylineResult.errorMessage);
    }
    return PolylineCordinates;
  }

  void generatePolyLineFromPoint(List<LatLng> PolylineCordinates) async {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: PolylineCordinates,
        width: 8);
      
    setState(() {
      polylines[id]=polyline;
    });
  }
}
