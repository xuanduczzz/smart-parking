import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:park/config/colors.dart';
import 'package:park/data/service/parking_service.dart';
import 'package:park/bloc/map_bloc/map_bloc.dart';
import 'package:park/page/home/home_page.dart';
import 'package:park/page/reservation_history/reservation_history_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _determinePosition().then((position) {
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
    }).catchError((e) {
      print("Lỗi lấy vị trí: $e");
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapBloc(ParkingService())..add(LoadParkingMarkersEvent()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: blueColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/white_logo.png", width: 40, height: 40),
              const SizedBox(width: 20),
              const Text(
                "CAR PARKING",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          centerTitle: true,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: blueColor),
                accountName: Text('Người dùng'),
                accountEmail: Text('user@example.com'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: blueColor),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Hồ sơ cá nhân'),
                onTap: () {
                  Get.toNamed('/profile');
                },
              ),
              ListTile(
                leading: Icon(Icons.book_online),
                title: Text('Lịch sử đặt chỗ'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReservationHistoryPage()),
                    );
                  }

              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Cài đặt'),
                onTap: () {
                  Get.toNamed('/settings');
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Get.offAllNamed('/login');
                },
              ),
            ],
          ),
        ),
        body: _userLocation == null
            ? const Center(child: CircularProgressIndicator())
            : BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            if (state is MapLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MapError) {
              return Center(child: Text(state.message));
            } else if (state is MapLoaded) {
              Set<Marker> markers = {
                Marker(
                  markerId: const MarkerId("user_location"),
                  position: _userLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                  infoWindow: const InfoWindow(title: "Your Location"),
                )
              };

              for (var lot in state.parkingLots) {
                markers.add(
                  Marker(
                    markerId: MarkerId(lot.id),
                    position: LatLng(lot.latitude, lot.longitude),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                    infoWindow: InfoWindow(
                      title: lot.name,
                      snippet: 'Available: ${lot.availableSlots}, Price: ${lot.pricePerHour} VND/hr',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomePage(parkingLot: lot),
                        ),
                      );
                    },
                  ),
                );
              }

              return GoogleMap(
                buildingsEnabled: true,
                compassEnabled: true,
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(target: _userLocation!, zoom: 16.0),
                markers: markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              );
            }

            return const Center(child: Text("Something went wrong"));
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await _getCurrentLocation();
          },
          backgroundColor: blueColor,
          child: const Icon(Icons.my_location, color: Colors.white),
        ),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Dịch vụ vị trí chưa bật.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Quyền vị trí bị từ chối.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Quyền vị trí bị từ chối vĩnh viễn.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await _determinePosition();
    LatLng newLocation = LatLng(position.latitude, position.longitude);
    setState(() {
      _userLocation = newLocation;
    });

    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(newLocation));
  }
}
