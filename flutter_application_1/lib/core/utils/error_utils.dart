import 'package:supabase_flutter/supabase_flutter.dart';

/// Utility class to map technical Supabase and network exceptions to user-friendly messages.
class ErrorUtils {
  ErrorUtils._();

  static String getErrorMessage(Object error) {
    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid credentials')) {
        return 'Incorrect email or password. Please try again.';
      }
      if (msg.contains('user already registered') ||
          msg.contains('already registered')) {
        return 'An account with this email already exists. Try signing in.';
      }
      if (msg.contains('email not confirmed')) {
        return 'Please confirm your email address before logging in.';
      }
      if (msg.contains('password should be at least')) {
        return error.message;
      }
      if (msg.contains('rate limit')) {
        return 'Too many attempts. Please wait a minute and try again.';
      }
      return error.message;
    } else if (error is PostgrestException) {
      // Database / Row Level Security / Constraint error
      if (error.code == '42P01') {
        return 'Database table does not exist. Please run the schema.sql in Supabase SQL editor.';
      }
      if (error.code == '42501') {
        return 'Permission denied by Row Level Security policy.';
      }
      return error.message.isNotEmpty
          ? error.message
          : 'Database operation failed.';
    }

    final stringRep = error.toString();
    if (stringRep.contains('SocketException') ||
        stringRep.contains('ClientException')) {
      return 'Network error: Please check your internet connection.';
    }

    return 'An unexpected error occurred: ${stringRep.replaceAll('Exception:', '').trim()}';
  }
}
