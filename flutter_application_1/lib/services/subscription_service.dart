import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants/supabase_constants.dart';
import '../models/subscription.dart';

class SubscriptionService {
  final SupabaseClient _supabase;

  SubscriptionService({SupabaseClient? client})
    : _supabase = client ?? supabase;

  String get _currentUserId {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw const AuthException(
        'User must be logged in to access subscriptions.',
      );
    }
    return user.id;
  }

  /// Fetches all subscriptions belonging to the current user
  Future<List<Subscription>> getSubscriptions() async {
    final userId = _currentUserId;

    final response = await _supabase
        .from(SupabaseConstants.subscriptionsTable)
        .select()
        .eq('user_id', userId)
        .order('is_active', ascending: false)
        .order('next_renewal_date', ascending: true, nullsFirst: false);

    final list = response as List<dynamic>;
    return list
        .map((item) => Subscription.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  /// Creates a new subscription for the logged-in user
  Future<Subscription> createSubscription(Subscription subscription) async {
    final userId = _currentUserId;

    // Ensure user_id matches authenticated user
    final data = subscription.copyWith(userId: userId).toMap();
    // Do not pass id on create to let PostgreSQL generate uuid
    data.remove('id');

    final response = await _supabase
        .from(SupabaseConstants.subscriptionsTable)
        .insert(data)
        .select()
        .single();

    return Subscription.fromMap(response);
  }

  /// Updates an existing subscription
  Future<Subscription> updateSubscription(Subscription subscription) async {
    final userId = _currentUserId;
    if (subscription.id == null || subscription.id!.isEmpty) {
      throw ArgumentError('Subscription ID is required for update.');
    }

    final data = subscription.copyWith(userId: userId).toMap();

    final response = await _supabase
        .from(SupabaseConstants.subscriptionsTable)
        .update(data)
        .eq('id', subscription.id!)
        .eq('user_id', userId)
        .select()
        .single();

    return Subscription.fromMap(response);
  }

  /// Deletes a subscription by ID
  Future<void> deleteSubscription(String id) async {
    final userId = _currentUserId;

    await _supabase
        .from(SupabaseConstants.subscriptionsTable)
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }

  /// Toggles the active status of a subscription
  Future<void> toggleSubscriptionStatus(String id, bool isActive) async {
    final userId = _currentUserId;

    await _supabase
        .from(SupabaseConstants.subscriptionsTable)
        .update({
          'is_active': isActive,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id)
        .eq('user_id', userId);
  }

  /// Prefix used to mark the demo records so they are easy to recognise
  /// and to remove again.
  static const String demoPrefix = Subscription.demoPrefix;

  /// Creates a set of demo subscriptions for the signed in user.
  ///
  /// The records are written to the user's own database, so they behave
  /// exactly like real subscriptions. Returns the number of records created;
  /// calling it again does nothing when demo data already exists.
  Future<int> seedDemoSubscriptions() async {
    final existing = await getSubscriptions();
    if (existing.any((s) => s.name.startsWith(demoPrefix))) return 0;

    final now = DateTime.now();
    final demos = <Subscription>[
      Subscription(
        userId: _currentUserId,
        name: '${demoPrefix}Netflix',
        category: 'Streaming',
        amount: 15.49,
        currency: 'USD',
        billingCycle: 'monthly',
        startDate: now.subtract(const Duration(days: 12)),
        nextRenewalDate: now.add(const Duration(days: 18)),
        notes: 'Standard plan',
      ),
      Subscription(
        userId: _currentUserId,
        name: '${demoPrefix}Spotify Premium',
        category: 'Music',
        amount: 10.99,
        currency: 'USD',
        billingCycle: 'monthly',
        startDate: now.subtract(const Duration(days: 25)),
        nextRenewalDate: now.add(const Duration(days: 5)),
        notes: 'Family plan',
      ),
      Subscription(
        userId: _currentUserId,
        name: '${demoPrefix}Amazon Web Services',
        category: 'Cloud',
        amount: 240.00,
        currency: 'USD',
        billingCycle: 'monthly',
        startDate: now.subtract(const Duration(days: 28)),
        nextRenewalDate: now.add(const Duration(days: 2)),
        notes: 'Compute + storage',
      ),
      Subscription(
        userId: _currentUserId,
        name: '${demoPrefix}Adobe Creative Cloud',
        category: 'Software',
        amount: 59.99,
        currency: 'USD',
        billingCycle: 'monthly',
        startDate: now.subtract(const Duration(days: 26)),
        nextRenewalDate: now.subtract(const Duration(days: 4)),
        notes: 'All apps',
      ),
      Subscription(
        userId: _currentUserId,
        name: '${demoPrefix}Equinox Gym',
        category: 'Fitness',
        amount: 189.00,
        currency: 'USD',
        billingCycle: 'yearly',
        startDate: now.subtract(const Duration(days: 40)),
        nextRenewalDate: now.add(const Duration(days: 60)),
        notes: 'Annual membership',
      ),
      Subscription(
        userId: _currentUserId,
        name: '${demoPrefix}Figma',
        category: 'Productivity',
        amount: 15.00,
        currency: 'USD',
        billingCycle: 'monthly',
        startDate: now.subtract(const Duration(days: 20)),
        nextRenewalDate: now.add(const Duration(days: 10)),
        isActive: false,
        notes: 'Paused demo record',
      ),
    ];

    for (final demo in demos) {
      await createSubscription(demo);
    }
    return demos.length;
  }

  /// Removes every demo subscription of the signed in user.
  ///
  /// Returns the number of records that were deleted.
  Future<int> clearDemoSubscriptions() async {
    final existing = await getSubscriptions();
    final demos = existing.where((s) => s.name.startsWith(demoPrefix)).toList();

    for (final demo in demos) {
      final id = demo.id;
      if (id != null && id.isNotEmpty) {
        await deleteSubscription(id);
      }
    }
    return demos.length;
  }
}
