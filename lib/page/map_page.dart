import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class mapPage extends StatefulWidget {
  const mapPage({Key? key}) : super(key: key);

  @override
  State<mapPage> createState() => _mapPageState();
}

class _mapPageState extends State<mapPage> {
  Location _locationController = Location();

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  static const LatLng HCMLat = LatLng(10.8414669, 106.6222061);
  static const LatLng Shop1Lng = LatLng(10.7797, 106.6992);
  static const LatLng Shop2Lng = LatLng(10.8144264, 106.6191543);

  LatLng? _currentPosition;

  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    getLocationUpdate().then((_) {
      print("getLocationUpdate completed");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition == null
          ? Center(child: Text("Loading..."))
          : GoogleMap(
              onMapCreated: ((GoogleMapController controller) =>
                  _mapController.complete(controller)),
              initialCameraPosition: CameraPosition(target: HCMLat, zoom: 13),
              markers: {
                Marker(
                  markerId: MarkerId("_currentLocation"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: _currentPosition!,
                ),
                Marker(
                  markerId: MarkerId("_shop1Location"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: Shop1Lng,
                ),
                Marker(
                  markerId: MarkerId("_shop2Location"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: Shop2Lng,
                ),
              },
              polylines: Set<Polyline>.of(polylines.values),
            ),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition newCamPos = CameraPosition(
      target: pos,
      zoom: 13,
    );
    await controller.animateCamera(CameraUpdate.newCameraPosition(newCamPos));
  }

  Future<void> getLocationUpdate() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
    }

    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
    }

    if (permissionGranted != PermissionStatus.granted) {
      print('Location permissions are denied.');
      return;
    }

    _locationController.onLocationChanged.listen(
      (LocationData currentLocation) {
        if (currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          print(
              'Current location: ${currentLocation.latitude}, ${currentLocation.longitude}');
          setState(() {
            _currentPosition =
                LatLng(currentLocation.latitude!, currentLocation.longitude!);
            _cameraToPosition(_currentPosition!);
            // Draw polyline here
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
      },
    );
  }
  LatLng? _findClosestShop() {
    double minDistance = double.infinity;
    LatLng? closestShop;
    List<LatLng> shopLocations = [Shop1Lng, Shop2Lng];
    for (LatLng shopLocation in shopLocations) {
      double distance = _calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        shopLocation.latitude,
        shopLocation.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        closestShop = shopLocation;
      }
    }
    return closestShop;
  }
   double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
  Future<List<LatLng>> getPolylinePoints() async {
    LatLng? closestShop= _findClosestShop();
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult polylineResult =
        await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyBuUQXoeB0qP0Amvis2IOivctJGOv59Bw8",
      PointLatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      PointLatLng(closestShop!.latitude, closestShop!.longitude),
      travelMode: TravelMode.walking,
    );

    if (polylineResult.points.isNotEmpty) {
      polylineResult.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(polylineResult.errorMessage);
    }
    return polylineCoordinates;
  }

  void generatePolyLineFromPoint(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 8,
    );

    setState(() {
      polylines[id] = polyline;
    });
  }
}
