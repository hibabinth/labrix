import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';

class BookingService {
  final _supabase = Supabase.instance.client;

  Future<void> createBooking(BookingModel booking) async {
    await _supabase.from('bookings').insert(booking.toJson());
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _supabase
        .from('bookings')
        .update({'status': status})
        .eq('id', bookingId);
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    final res = await _supabase
        .from('bookings')
        .select('*, profiles:worker_id(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (res as List).map((e) => BookingModel.fromJson(e)).toList();
  }

  Future<List<BookingModel>> getWorkerBookings(String workerId) async {
    final res = await _supabase
        .from('bookings')
        .select('*, profiles:user_id(*)')
        .eq('worker_id', workerId)
        .order('created_at', ascending: false);
    return (res as List).map((e) => BookingModel.fromJson(e)).toList();
  }
}
