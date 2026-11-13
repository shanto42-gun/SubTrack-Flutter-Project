class Subscription {
  /// Prefix used to mark demo records so they are easy to recognise.
  static const String demoPrefix = 'Demo ';

  final String? id;
  final String userId;
  final String name;
  final String category;
  final double amount;
  final String currency;
  final String billingCycle; // monthly, yearly, weekly, quarterly
  final DateTime startDate;
  final DateTime? nextRenewalDate;
  final bool isActive;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Subscription({
    this.id,
    required this.userId,
    required this.name,
    this.category = 'Entertainment',
    required this.amount,
    this.currency = 'USD',
    this.billingCycle = 'monthly',
    required this.startDate,
    this.nextRenewalDate,
    this.isActive = true,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Calculates the normalized monthly cost for analytics/dashboard
  double get monthlyCost {
    if (!isActive) return 0.0;
    switch (billingCycle.toLowerCase()) {
      case 'yearly':
        return amount / 12.0;
      case 'quarterly':
        return amount / 3.0;
      case 'weekly':
        return amount * 4.333;
      case 'monthly':
      default:
        return amount;
    }
  }

  /// Returns the number of days remaining until next renewal/expiry
  int? get daysRemaining {
    if (nextRenewalDate == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(
      nextRenewalDate!.year,
      nextRenewalDate!.month,
      nextRenewalDate!.day,
    );
    return target.difference(today).inDays;
  }

  /// Human readable live remaining / ending time text
  String get remainingTimeText {
    if (!isActive) return 'Paused';
    final days = daysRemaining;
    if (days == null) return 'No expiry set';
    if (days < 0) {
      final abs = days.abs();
      return abs == 1 ? 'Expired yesterday' : 'Expired $abs days ago';
    } else if (days == 0) {
      return 'Renews today';
    } else if (days == 1) {
      return 'Renews tomorrow';
    } else {
      return '$days days left';
    }
  }

  /// Progress fraction of the current cycle (0.0 to 1.0)
  double get cycleProgress {
    if (nextRenewalDate == null) return 0.0;
    final totalDays = nextRenewalDate!.difference(startDate).inDays;
    if (totalDays <= 0) return 1.0;
    final elapsedDays = DateTime.now().difference(startDate).inDays;
    return (elapsedDays / totalDays).clamp(0.0, 1.0);
  }

  factory Subscription.fromMap(Map<String, dynamic> map) {
    // Parse amount safely from double, int, or numeric string
    double parsedAmount = 0.0;
    final rawAmount = map['amount'];
    if (rawAmount is num) {
      parsedAmount = rawAmount.toDouble();
    } else if (rawAmount is String) {
      parsedAmount = double.tryParse(rawAmount) ?? 0.0;
    }

    return Subscription(
      id: map['id']?.toString(),
      userId: map['user_id']?.toString() ?? '',
      name: (map['name'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'Other',
      amount: parsedAmount,
      currency: (map['currency'] as String?) ?? 'USD',
      billingCycle: (map['billing_cycle'] as String?) ?? 'monthly',
      startDate: map['start_date'] != null
          ? DateTime.tryParse(map['start_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      nextRenewalDate: map['next_renewal_date'] != null
          ? DateTime.tryParse(map['next_renewal_date'].toString())
          : null,
      isActive: (map['is_active'] as bool?) ?? true,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'user_id': userId,
      'name': name.trim(),
      'category': category.trim(),
      'amount': amount,
      'currency': currency,
      'billing_cycle': billingCycle.toLowerCase(),
      'start_date': _formatDate(startDate),
      'is_active': isActive,
      'notes': notes?.trim(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    if (id != null) {
      map['id'] = id;
    }
    if (nextRenewalDate != null) {
      map['next_renewal_date'] = _formatDate(nextRenewalDate!);
    } else {
      map['next_renewal_date'] = null;
    }

    return map;
  }

  static String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Subscription copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    double? amount,
    String? currency,
    String? billingCycle,
    DateTime? startDate,
    DateTime? nextRenewalDate,
    bool? isActive,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      billingCycle: billingCycle ?? this.billingCycle,
      startDate: startDate ?? this.startDate,
      nextRenewalDate: nextRenewalDate ?? this.nextRenewalDate,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
