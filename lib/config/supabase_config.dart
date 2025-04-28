import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Replace these with your actual Supabase project URL and anon key
  static const String supabaseUrl = 'https://evoysvkttxmowdzxwftm.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV2b3lzdmt0dHhtb3dkenh3ZnRtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUxNDEyMTYsImV4cCI6MjA2MDcxNzIxNn0.DnEFCWbArTIq1ex_0W6rFYF6T1u6pa1enl0me5KjQXk';

  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Enable debug mode to see more detailed logs
    );
  }

  // Get Supabase client
  static SupabaseClient get client => Supabase.instance.client;
}
