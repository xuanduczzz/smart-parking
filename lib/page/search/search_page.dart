import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:park/data/model/parking_lot.dart'; // import đúng model của bạn

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<ParkingLot> allLots = [];
  List<ParkingLot> filteredLots = [];

  @override
  void initState() {
    super.initState();
    _loadParkingLots();
  }

  Future<void> _loadParkingLots() async {
    final snapshot = await FirebaseFirestore.instance.collection('parking_lots').get();

    List<ParkingLot> lots = snapshot.docs.map((doc) {
      return ParkingLot.fromFirestore(doc.id, doc.data());
    }).toList();

    setState(() {
      allLots = lots;
      filteredLots = lots;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      filteredLots = allLots.where((lot) {
        final input = query.toLowerCase();
        return lot.name.toLowerCase().contains(input) ||
            lot.address.toLowerCase().contains(input);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm bãi đỗ')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Nhập tên hoặc địa chỉ...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredLots.length,
              itemBuilder: (context, index) {
                final lot = filteredLots[index];
                return ListTile(
                  leading: const Icon(Icons.local_parking),
                  title: Text(lot.name),
                  subtitle: Text(lot.address),
                  onTap: () {
                    Navigator.pop(context, lot); // Trả kết quả về MapPage
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
