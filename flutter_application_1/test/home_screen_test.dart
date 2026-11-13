import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_application_1/core/constants/supabase_constants.dart';
import 'package:flutter_application_1/core/theme/app_palette.dart';
import 'package:flutter_application_1/core/theme/app_theme.dart';
import 'package:flutter_application_1/core/theme/theme_controller.dart';
import 'package:flutter_application_1/models/subscription.dart';
import 'package:flutter_application_1/models/user_profile.dart';
import 'package:flutter_application_1/screens/home/home_screen.dart';
import 'package:flutter_application_1/screens/home/widgets/subscription_card.dart';
import 'package:flutter_application_1/screens/home/widgets/subscription_summary_card.dart';
import 'package:flutter_application_1/services/profile_service.dart';
import 'package:flutter_application_1/services/subscription_service.dart';

class _FakeSubscriptionService extends SubscriptionService {
  _FakeSubscriptionService(this.items);

  final List<Subscription> items;

  @override
  Future<List<Subscription>> getSubscriptions() async => items;

  @override
  Future<void> toggleSubscriptionStatus(String id, bool isActive) async {}
}

class _FakeProfileService extends ProfileService {
  _FakeProfileService() : super();

  @override
  Future<UserProfile?> getProfile([String? userId]) async => UserProfile(
    id: 'test-user',
    email: 'test@example.com',
    fullName: 'Test User',
  );
}

Subscription _sub({
  required String name,
  required double amount,
  String cycle = 'monthly',
  bool active = true,
  String category = 'Entertainment',
  DateTime? renewal,
}) {
  return Subscription(
    id: name,
    userId: 'test-user',
    name: name,
    category: category,
    amount: amount,
    billingCycle: cycle,
    startDate: DateTime.now().subtract(const Duration(days: 10)),
    nextRenewalDate: renewal ?? DateTime.now().add(const Duration(days: 10)),
    isActive: active,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: SupabaseConstants.supabaseUrl,
      publishableKey: SupabaseConstants.supabasePublishableKey,
    );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await themeController.init();
  });

  Widget wrap(Widget child) {
    return MaterialApp(theme: AppTheme.build(AppPalettes.blue), home: child);
  }

  testWidgets('renders a card for every subscription returned by the service', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        HomeScreen(
          service: _FakeSubscriptionService(<Subscription>[
            _sub(name: 'Netflix', amount: 15.49),
            _sub(name: 'Spotify', amount: 10.99, category: 'Music'),
            _sub(name: 'Paused service', amount: 5, active: false),
          ]),
          profileService: _FakeProfileService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final summary = tester.widget<SubscriptionSummaryCard>(
      find.byType(SubscriptionSummaryCard),
    );
    expect(summary.subscriptions.length, 3);

    for (final name in <String>['Netflix', 'Spotify']) {
      expect(
        find.descendant(
          of: find.byType(SubscriptionCard),
          matching: find.text(name),
        ),
        findsOneWidget,
      );
    }

    // The list is lazy, so scroll to reveal the remaining card.
    await tester.scrollUntilVisible(
      find.text('Paused service'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Paused service'), findsOneWidget);
  });

  testWidgets('summary card totals the active monthly commitment', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        HomeScreen(
          service: _FakeSubscriptionService(<Subscription>[
            _sub(name: 'Netflix', amount: 10),
            _sub(name: 'Yearly plan', amount: 120, cycle: 'yearly'),
            _sub(name: 'Paused', amount: 99, active: false),
          ]),
          profileService: _FakeProfileService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final summary = tester.widget<SubscriptionSummaryCard>(
      find.byType(SubscriptionSummaryCard),
    );
    // 10 monthly + (120 / 12) monthly-equivalent; the paused one is excluded.
    expect(summary.subscriptions.length, 3);
  });

  testWidgets('shows a polished empty state when there are no subscriptions', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        HomeScreen(
          service: _FakeSubscriptionService(<Subscription>[]),
          profileService: _FakeProfileService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No subscriptions yet'), findsOneWidget);
    expect(
      find.text('Add your recurring expenses to track renewals and costs.'),
      findsOneWidget,
    );
    expect(find.text('Add Subscription'), findsOneWidget);
    expect(find.byType(SubscriptionCard), findsNothing);
  });
}
