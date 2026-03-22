import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingRepository {
  final BookingService _bookingService = BookingService();

  Future<void> createBooking(BookingModel booking) async {
    await _bookingService.createBooking(booking);
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _bookingService.updateBookingStatus(bookingId, status);
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    return await _bookingService.getUserBookings(userId);
  }

  Future<List<BookingModel>> getWorkerBookings(String workerId) async {
    return await _bookingService.getWorkerBookings(workerId);
  }
}
