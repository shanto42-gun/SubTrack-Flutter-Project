import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_constants.dart';
import '../models/user_profile.dart';

class ProfileService {
  final SupabaseClient _supabase;

  ProfileService({SupabaseClient? client}) : _supabase = client ?? supabase;

  /// Fetches the profile for the given [userId], or current user if omitted.
  Future<UserProfile?> getProfile([String? userId]) async {
    final targetId = userId ?? _supabase.auth.currentUser?.id;
    if (targetId == null) return null;

    final response = await _supabase
        .from(SupabaseConstants.profilesTable)
        .select()
        .eq('id', targetId)
        .maybeSingle();

    if (response == null) {
      // If profile record doesn't exist yet, construct and upsert a default profile
      final user = _supabase.auth.currentUser;
      if (user != null && user.id == targetId) {
        final newProfile = UserProfile(
          id: user.id,
          email: user.email ?? '',
          fullName: user.userMetadata?['full_name'] as String?,
          avatarUrl: user.userMetadata?['avatar_url'] as String?,
          updatedAt: DateTime.now(),
        );
        await upsertProfile(newProfile);
        return newProfile;
      }
      return null;
    }

    return UserProfile.fromMap(response);
  }

  /// Inserts or updates the user profile record
  Future<UserProfile> upsertProfile(UserProfile profile) async {
    final response = await _supabase
        .from(SupabaseConstants.profilesTable)
        .upsert(profile.toMap())
        .select()
        .single();

    return UserProfile.fromMap(response);
  }
}
