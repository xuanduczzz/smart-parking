double calculateTotalPrice(DateTime start, DateTime end, double pricePerHour) {
  int hours = end.difference(start).inHours;
  int minutes = end.difference(start).inMinutes % 60;
  if (minutes > 0 && minutes <= 30) hours += 1;
  return hours * pricePerHour.toDouble();
}

bool validateReservationInputs({
  required String name,
  required String phone,
  required String? vehicleId,
  required DateTime startTime,
  required DateTime endTime,
}) {
  return name.isNotEmpty &&
      phone.isNotEmpty &&
      vehicleId != null &&
      !startTime.isAfter(endTime);
} 