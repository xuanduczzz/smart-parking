import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:park/config/colors.dart';
import 'package:park/data/service/parking_service.dart';
import 'package:park/bloc/map_bloc/map_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:park/data/model/parking_lot.dart';
import 'package:park/data/service/reservation_status_listener.dart';
import 'package:park/controller/theme_controller.dart';
import 'package:park/config/routes.dart';

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

    ReservationStatusListener().listenToStatusChanges();

    _determinePosition().then((position) {
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
    }).catchError((e) {
      print("Lỗi lấy vị trí: $e");
    });

    ThemeController.themeNotifier.addListener(_applyMapStyle);
  }

  @override
  void dispose() {
    ThemeController.themeNotifier.removeListener(_applyMapStyle);
    super.dispose();
  }

  void _applyMapStyle() async {
    final controller = await _controller.future;
    final isDark = ThemeController.themeNotifier.value == ThemeMode.dark;
    if (isDark) {
      final darkStyle = await rootBundle.loadString('assets/map_style_dark.json');
      controller.setMapStyle(darkStyle);
    } else {
      controller.setMapStyle(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapBloc(ParkingService())..add(LoadParkingMarkersEvent()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: blueColor,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/white_logo.png", width: 40, height: 40),
              const SizedBox(width: 20),
              const Text(
                "CAR PARKING",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.notifications);
                },
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: blueColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  child: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('user_customer').doc(FirebaseAuth.instance.currentUser?.uid).get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return UserAccountsDrawerHeader(
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          accountName: const Text(
                            'Người dùng',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          accountEmail: const Text(
                            'user@example.com',
                            style: TextStyle(color: Colors.white70),
                          ),
                          currentAccountPicture: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person, size: 40, color: blueColor),
                            ),
                          ),
                        );
                      }

                      final userData = snapshot.data!;
                      final name = userData['name'] ?? 'Người dùng';
                      final email = userData['email'] ?? 'user@example.com';
                      final avatarUrl = userData['avatar'];

                      return UserAccountsDrawerHeader(
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        accountName: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        accountEmail: Text(
                          email,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        currentAccountPicture: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                            child: avatarUrl == null ? const Icon(Icons.person, size: 40, color: blueColor) : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildDrawerItem(
                        icon: Icons.person,
                        title: 'Hồ sơ cá nhân',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                        textColor: Theme.of(context).textTheme.bodyLarge?.color,
                        iconColor: blueColor,
                      ),
                      _buildDrawerItem(
                        icon: Icons.book_online,
                        title: 'Lịch sử đặt chỗ',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.reservationHistory),
                        textColor: Theme.of(context).textTheme.bodyLarge?.color,
                        iconColor: blueColor,
                      ),
                      _buildDrawerItem(
                        icon: Icons.rate_review,
                        title: 'Đánh giá của tôi',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.myReviews),
                        textColor: Theme.of(context).textTheme.bodyLarge?.color,
                        iconColor: blueColor,
                      ),
                      _buildDrawerItem(
                        icon: Icons.car_crash,
                        title: 'Phương tiện',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.vehicles),
                        textColor: Theme.of(context).textTheme.bodyLarge?.color,
                        iconColor: blueColor,
                      ),
                      _buildDrawerItem(
                        icon: Icons.settings,
                        title: 'Cài đặt',
                        onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                        textColor: Theme.of(context).textTheme.bodyLarge?.color,
                        iconColor: blueColor,
                      ),
                      Divider(color: Theme.of(context).dividerColor.withOpacity(0.2)),
                      _buildDrawerItem(
                        icon: Icons.logout,
                        title: 'Đăng xuất',
                        textColor: Colors.red,
                        iconColor: Colors.red,
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacementNamed(context, AppRoutes.login);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        body: _userLocation == null
            ? const Center(child: CircularProgressIndicator())
            : BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            if (state is MapLoading) return const Center(child: CircularProgressIndicator());
            if (state is MapError) return Center(child: Text(state.message));
            if (state is MapLoaded) {
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
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.home,
                      arguments: {'parkingLot': lot},
                    ),
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
                    onMapCreated: (controller) async {
                      _controller.complete(controller);
                      _applyMapStyle();
                    },
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () async {
                        final result = await Navigator.pushNamed(context, AppRoutes.search);
                        if (result != null && result is ParkingLot) {
                          final controller = await _controller.future;
                          controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(result.latitude, result.longitude), 18));
                          setState(() {
                            _searchMarker = Marker(
                              markerId: const MarkerId("search_result"),
                              position: LatLng(result.latitude, result.longitude),
                              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                              infoWindow: InfoWindow(title: result.name, snippet: result.address),
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.home,
                                arguments: {'parkingLot': result},
                              ),
                            );
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: const Row(
                          children: [Icon(Icons.search, color: Colors.grey), SizedBox(width: 10), Text("Tìm kiếm bãi đỗ...", style: TextStyle(color: Colors.grey))],
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
          onPressed: () async => await _getCurrentLocation(),
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
      if (permission == LocationPermission.denied) return Future.error('Quyền vị trí bị từ chối.');
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Quyền vị trí bị từ chối vĩnh viễn.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await _determinePosition();
    LatLng newLocation = LatLng(position.latitude, position.longitude);
    setState(() => _userLocation = newLocation);
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(newLocation));
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Theme.of(context).iconTheme.color,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.07),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
