import 'package:flutter/material.dart';

class BookingValidator {
  static bool isValidDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);
    return selected.isAfter(today) || selected.isAtSameMomentAs(today);
  }

  static bool isValidTimeForToday(TimeOfDay time) {
    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);
    
    final timeInMinutes = time.hour * 60 + time.minute;
    final currentTimeInMinutes = currentTime.hour * 60 + currentTime.minute;
    
    return timeInMinutes >= currentTimeInMinutes;
  }

  static bool isValidTimeRange(DateTime selectedDate, TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    final duration = endMinutes - startMinutes;
    
    if (duration <= 0) return false;
    if (duration > 24 * 60) return false; // Không cho phép đặt quá 24 giờ
    
    // Kiểm tra nếu là ngày hiện tại
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    
    if (selected.isAtSameMomentAs(today)) {
      if (!isValidTimeForToday(start)) return false;
    }
    
    return true;
  }

  static String? validateBookingTime(DateTime selectedDate, TimeOfDay startTime, TimeOfDay endTime) {
    if (!isValidDate(selectedDate)) {
      return "Không thể chọn ngày trong quá khứ";
    }

    if (!isValidTimeRange(selectedDate, startTime, endTime)) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      
      if (selected.isAtSameMomentAs(today) && !isValidTimeForToday(startTime)) {
        return "Không thể chọn thời gian trước thời gian hiện tại cho ngày hôm nay";
      }
      return "Thời gian không hợp lệ. Vui lòng chọn thời gian kết thúc lớn hơn thời gian bắt đầu và không quá 24 giờ.";
    }

    return null;
  }

  static TimeOfDay getDefaultStartTime() {
    return TimeOfDay.now();
  }

  static TimeOfDay getDefaultEndTime() {
    return TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
  }
} 