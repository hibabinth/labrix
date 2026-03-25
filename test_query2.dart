import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final url = Uri.parse('https://lmvoqahtmpaodturlwat.supabase.co/rest/v1/workers?select=*,profiles(*)');
  final res = await http.get(url, headers: {
    'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxtdm9xYWh0bXBhb2R0dXJsd2F0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEwMzA0OTUsImV4cCI6MjA4NjYwNjQ5NX0.Gq-WYYakay-gd41OGx0eTrkruPM8GattETEV-4tAlPU',
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxtdm9xYWh0bXBhb2R0dXJsd2F0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEwMzA0OTUsImV4cCI6MjA4NjYwNjQ5NX0.Gq-WYYakay-gd41OGx0eTrkruPM8GattETEV-4tAlPU'
  });
  print(res.body);
}
