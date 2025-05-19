import 'package:flutter/material.dart';
import 'package:park/data/model/vehicle.dart';

class VehicleDropdown extends StatelessWidget {
  final List<Vehicle> vehicles;
  final String? selectedVehicleId;
  final Function(String?) onChanged;

  const VehicleDropdown({
    super.key,
    required this.vehicles,
    required this.selectedVehicleId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return vehicles.isEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Chọn xe",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "Bạn chưa có xe nào. Vui lòng thêm xe trước khi đặt chỗ.",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Chọn xe",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: selectedVehicleId,
                  hint: Text("Chọn xe của bạn", style: TextStyle(color: Theme.of(context).hintColor)),
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: Theme.of(context).cardColor,
                  onChanged: onChanged,
                  items: vehicles.map((vehicle) => DropdownMenuItem<String>(
                    value: vehicle.vehicleId,
                    child: Text(vehicle.licensePlate, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                  )).toList(),
                ),
              ),
            ],
          );
  }
} 