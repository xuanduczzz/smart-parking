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
import 'package:park/page/profile/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:park/page/vehicle/vehicle_page.dart';
import 'package:park/page/login/login_screen.dart';
import 'package:park/page/settings/settings_page.dart';
import 'package:park/data/model/parking_lot.dart';
import 'package:park/page/search/search_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _userLocation;
  Marker? _searchMarker;

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
              const Text("CAR PARKING", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
          centerTitle: true,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('user_customer')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const UserAccountsDrawerHeader(
                      decoration: BoxDecoration(color: blueColor),
                      accountName: Text('Loading...'),
                      accountEmail: Text('Loading...'),
                      currentAccountPicture: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 40, color: blueColor),
                      ),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                    return const UserAccountsDrawerHeader(
                      decoration: BoxDecoration(color: blueColor),
                      accountName: Text('Error'),
                      accountEmail: Text('Error loading data'),
                      currentAccountPicture: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 40, color: blueColor),
                      ),
                    );
                  }

                  final userData = snapshot.data!;
                  final String name = userData['name'] ?? 'Người dùng';
                  final String email = userData['email'] ?? 'user@example.com';
                  final String? avatarUrl = userData['avatar'];

                  return UserAccountsDrawerHeader(
                    decoration: BoxDecoration(color: blueColor),
                    accountName: Text(name),
                    accountEmail: Text(email),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null
                          ? Icon(Icons.person, size: 40, color: blueColor)
                          : null,
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Hồ sơ cá nhân'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.book_online),
                title: Text('Lịch sử đặt chỗ'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ReservationHistoryPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.car_crash),
                title: Text('Phương tiện'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => VehiclesPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Cài đặt'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
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
                  infoWindow: const InfoWindow(title: "Vị trí của bạn"),
                ),
                if (_searchMarker != null) _searchMarker!,
              };

              for (var lot in state.parkingLots) {
                markers.add(
                  Marker(
                    markerId: MarkerId(lot.id),
                    position: LatLng(lot.latitude, lot.longitude),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => HomePage(parkingLot: lot)),
                      );
                    },
                  ),
                );
              }

              return Stack(
                children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(target: _userLocation!, zoom: 16),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                    markers: markers,
                    onMapCreated: (controller) {
                      _controller.complete(controller);
                    },
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SearchPage()),
                        );

                        if (result != null && result is ParkingLot) {
                          final controller = await _controller.future;
                          controller.animateCamera(CameraUpdate.newLatLngZoom(
                              LatLng(result.latitude, result.longitude), 18));
                          setState(() {
                            _searchMarker = Marker(
                              markerId: const MarkerId("search_result"),
                              position: LatLng(result.latitude, result.longitude),
                              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                              infoWindow: InfoWindow(title: result.name, snippet: result.address),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => HomePage(parkingLot: result)),
                                );
                              },
                            );
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 10),
                            Text("Tìm kiếm bãi đỗ...", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return const Center(child: Text("Không tải được bản đồ"));
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
    if (!serviceEnabled) return Future.error('Dịch vụ vị trí chưa bật.');

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
