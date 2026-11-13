import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized configuration and constants for Supabase.
class SupabaseConstants {
  SupabaseConstants._();

  static const String supabaseUrl = 'https://fnbcoehktdaixsmxtcam.supabase.co';
  static const String supabasePublishableKey =
      'sb_publishable_hlWpDHRNTCQP1ln4dLvyEQ_dTq1Gp3Q';
  static const String supabaseAnonKey = supabasePublishableKey;

  // Table names
  static const String profilesTable = 'profiles';
  static const String subscriptionsTable = 'subscriptions';
}

/// Global convenience accessor for the Supabase client
SupabaseClient get supabase => Supabase.instance.client;
