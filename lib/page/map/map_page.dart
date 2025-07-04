/// Trang hiển thị bản đồ và quản lý tương tác với bản đồ
/// Bao gồm các chức năng:
/// - Hiển thị vị trí người dùng
/// - Hiển thị các bãi đỗ xe trên bản đồ
/// - Tìm kiếm bãi đỗ xe
/// - Menu điều hướng
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:park/bloc/user_bloc/user_event.dart';
import 'package:park/config/colors.dart';
import 'package:park/data/service/parking_service.dart';
import 'package:park/bloc/map_bloc/map_bloc.dart';
import 'package:park/bloc/user_bloc/user_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:park/data/model/parking_lot.dart';
import 'package:park/controller/theme_controller.dart';
import 'package:park/config/routes.dart';

import '../../bloc/user_bloc/user_state.dart';

/// Widget hiển thị trang bản đồ
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  /// Controller để điều khiển Google Map
  final Completer<GoogleMapController> _controller = Completer();
  
  /// Vị trí hiện tại của người dùng
  LatLng? _userLocation;
  
  /// Marker cho kết quả tìm kiếm
  Marker? _searchMarker;

  @override
  void initState() {
    super.initState();

    /// Lấy vị trí người dùng khi khởi tạo trang
    _determinePosition().then((position) {
      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
    }).catchError((e) {
      print("Lỗi lấy vị trí: $e");
    });

    /// Thêm listener để áp dụng style bản đồ khi theme thay đổi
    ThemeController.themeNotifier.addListener(_applyMapStyle);
  }

  @override
  void dispose() {
    /// Xóa listener khi dispose widget
    ThemeController.themeNotifier.removeListener(_applyMapStyle);
    super.dispose();
  }

  /// Áp dụng style bản đồ dựa trên theme hiện tại
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
    return MultiBlocProvider(
      providers: [
        /// Provider cho MapBloc để quản lý trạng thái bản đồ
        BlocProvider(create: (context) => MapBloc(ParkingService())..add(LoadParkingMarkersEvent())),
        /// Provider cho UserBloc để quản lý thông tin người dùng
        BlocProvider(create: (context) => UserBloc()..add(LoadUserInfo())),
      ],
      child: Scaffold(
        /// AppBar với logo và nút thông báo
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
        /// Drawer menu với thông tin người dùng và các tùy chọn
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
                  child: BlocBuilder<UserBloc, UserState>(
                    builder: (context, state) {
                      /// Hiển thị trạng thái loading
                      if (state is UserLoading) {
                        return const UserAccountsDrawerHeader(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                          ),
                          accountName: Text(
                            'Đang tải...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          accountEmail: Text(
                            'Đang tải...',
                            style: TextStyle(color: Colors.white70),
                          ),
                          currentAccountPicture: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, size: 40, color: blueColor),
                          ),
                        );
                      }

                      /// Hiển thị trạng thái lỗi
                      if (state is UserError) {
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

                      /// Hiển thị thông tin người dùng đã đăng nhập
                      if (state is UserLoaded) {
                        return UserAccountsDrawerHeader(
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          accountName: Text(
                            state.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          accountEmail: Text(
                            state.email,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          currentAccountPicture: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              backgroundImage: state.avatarUrl != null ? NetworkImage(state.avatarUrl!) : null,
                              child: state.avatarUrl == null ? const Icon(Icons.person, size: 40, color: blueColor) : null,
                            ),
                          ),
                        );
                      }

                      /// Hiển thị mặc định khi chưa có thông tin
                      return const UserAccountsDrawerHeader(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                        accountName: Text(
                          'Người dùng',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        accountEmail: Text(
                          'user@example.com',
                          style: TextStyle(color: Colors.white70),
                        ),
                        currentAccountPicture: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 40, color: blueColor),
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
                      /// Các mục menu trong drawer
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
        /// Body chứa bản đồ và thanh tìm kiếm
        body: _userLocation == null
            ? const Center(child: CircularProgressIndicator())
            : BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            /// Hiển thị loading khi đang tải dữ liệu
            if (state is MapLoading) return const Center(child: CircularProgressIndicator());
            /// Hiển thị lỗi nếu có
            if (state is MapError) return Center(child: Text(state.message));
            /// Hiển thị bản đồ với các marker
            if (state is MapLoaded) {
              Set<Marker> markers = {
                /// Marker vị trí người dùng
                Marker(
                  markerId: const MarkerId("user_location"),
                  position: _userLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                  infoWindow: const InfoWindow(title: "Vị trí của bạn"),
                ),
                /// Marker kết quả tìm kiếm nếu có
                if (_searchMarker != null) _searchMarker!,
              };
              /// Thêm các marker bãi đỗ xe
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
                  /// Google Map widget
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
                  /// Thanh tìm kiếm
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
        /// Nút định vị vị trí hiện tại
        floatingActionButton: FloatingActionButton(
          onPressed: () async => await _getCurrentLocation(),
          backgroundColor: blueColor,
          child: const Icon(Icons.my_location, color: Colors.white),
        ),
      ),
    );
  }

  /// Kiểm tra và yêu cầu quyền truy cập vị trí
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

  /// Cập nhật vị trí hiện tại của người dùng
  Future<void> _getCurrentLocation() async {
    Position position = await _determinePosition();
    LatLng newLocation = LatLng(position.latitude, position.longitude);
    setState(() => _userLocation = newLocation);
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(newLocation));
  }

  /// Widget tạo các mục trong drawer menu
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
