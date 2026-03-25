import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

Future<void> main() async {
  // We need to load dotenv from current directory
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  final _supabase = Supabase.instance.client;

  final res = await _supabase.from('workers').select('*, profiles(*)');
  print('RAW JSON RESPONSE:');
  print(res);
  exit(0);
}
