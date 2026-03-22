import 'package:flutter/material.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/booking_repository.dart';

class BookingViewModel extends ChangeNotifier {
  final BookingRepository _bookingRepository = BookingRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<BookingModel> _userBookings = [];
  List<BookingModel> get userBookings => _userBookings;

  List<BookingModel> _workerBookings = [];
  List<BookingModel> get workerBookings => _workerBookings;

  Future<bool> createBooking(BookingModel booking) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _bookingRepository.createBooking(booking);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadUserBookings(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _userBookings = await _bookingRepository.getUserBookings(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWorkerBookings(String workerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _workerBookings = await _bookingRepository.getWorkerBookings(workerId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus(String bookingId, String status) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _bookingRepository.updateBookingStatus(bookingId, status);
      // Reload lists locally by finding and updating in-memory models if needed
      // Or just reload entirely
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
