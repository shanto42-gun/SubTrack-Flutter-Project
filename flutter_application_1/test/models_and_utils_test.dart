import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/subscription.dart';
import 'package:flutter_application_1/models/user_profile.dart';
import 'package:flutter_application_1/core/utils/error_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('Subscription Model Tests', () {
    test('Calculates monthly cost correctly for different billing cycles', () {
      final monthlySub = Subscription(
        userId: 'user-123',
        name: 'Netflix',
        amount: 15.0,
        billingCycle: 'monthly',
        startDate: DateTime(2026, 1, 1),
      );
      expect(monthlySub.monthlyCost, equals(15.0));

      final yearlySub = Subscription(
        userId: 'user-123',
        name: 'Amazon Prime',
        amount: 120.0,
        billingCycle: 'yearly',
        startDate: DateTime(2026, 1, 1),
      );
      expect(yearlySub.monthlyCost, equals(10.0));

      final quarterlySub = Subscription(
        userId: 'user-123',
        name: 'Gym',
        amount: 90.0,
        billingCycle: 'quarterly',
        startDate: DateTime(2026, 1, 1),
      );
      expect(quarterlySub.monthlyCost, equals(30.0));

      final inactiveSub = monthlySub.copyWith(isActive: false);
      expect(inactiveSub.monthlyCost, equals(0.0));
    });

    test('Serializes to map and deserializes correctly', () {
      final sub = Subscription(
        id: 'sub-uuid-1',
        userId: 'user-123',
        name: 'Spotify',
        category: 'Music',
        amount: 9.99,
        currency: 'USD',
        billingCycle: 'monthly',
        startDate: DateTime(2026, 5, 10),
        nextRenewalDate: DateTime(2026, 6, 10),
        isActive: true,
        notes: 'Family plan',
      );

      final map = sub.toMap();
      expect(map['name'], equals('Spotify'));
      expect(map['user_id'], equals('user-123'));
      expect(map['amount'], equals(9.99));
      expect(map['start_date'], equals('2026-05-10'));
      expect(map['next_renewal_date'], equals('2026-06-10'));

      final fromMap = Subscription.fromMap(map);
      expect(fromMap.id, equals('sub-uuid-1'));
      expect(fromMap.name, equals('Spotify'));
      expect(fromMap.amount, equals(9.99));
      expect(fromMap.category, equals('Music'));
      expect(fromMap.isActive, isTrue);
    });

    test('Handles numeric strings in amount deserialization', () {
      final map = {
        'id': 'sub-2',
        'user_id': 'u1',
        'name': 'Cloud Storage',
        'amount': '19.99', // string from PostgreSQL numeric
        'start_date': '2026-01-01',
      };
      final sub = Subscription.fromMap(map);
      expect(sub.amount, equals(19.99));
    });

    test('Computes days remaining and live remaining time text correctly', () {
      final today = DateTime.now();
      final inTenDays = today.add(const Duration(days: 10));
      final sub = Subscription(
        userId: 'u1',
        name: 'Disney+',
        amount: 12.0,
        startDate: today,
        nextRenewalDate: inTenDays,
      );

      expect(sub.daysRemaining, inInclusiveRange(9, 10));
      expect(sub.remainingTimeText, contains('days left'));

      final pausedSub = sub.copyWith(isActive: false);
      expect(pausedSub.remainingTimeText, equals('Paused'));
    });
  });

  group('UserProfile Model Tests', () {
    test('Serializes and deserializes user profile', () {
      final profile = UserProfile(
        id: 'user-abc',
        email: 'test@example.com',
        fullName: 'Jane Doe',
      );

      final map = profile.toMap();
      expect(map['id'], equals('user-abc'));
      expect(map['email'], equals('test@example.com'));
      expect(map['full_name'], equals('Jane Doe'));

      final deserialized = UserProfile.fromMap(map);
      expect(deserialized.id, equals('user-abc'));
      expect(deserialized.fullName, equals('Jane Doe'));
    });
  });

  group('ErrorUtils Tests', () {
    test('Translates common AuthExceptions to friendly text', () {
      const err = AuthException('Invalid login credentials');
      final message = ErrorUtils.getErrorMessage(err);
      expect(message, contains('Incorrect email or password'));

      const duplicateErr = AuthException('User already registered');
      expect(
        ErrorUtils.getErrorMessage(duplicateErr),
        contains('already exists'),
      );
    });

    test('Translates PostgrestExceptions to friendly text', () {
      const dbErr = PostgrestException(
        message: 'Relation does not exist',
        code: '42P01',
      );
      expect(ErrorUtils.getErrorMessage(dbErr), contains('schema.sql'));
    });
  });
}
