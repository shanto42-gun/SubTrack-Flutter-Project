import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/subscription.dart';

/// Prominent summary card showing the total monthly commitment.
class SubscriptionSummaryCard extends StatelessWidget {
  const SubscriptionSummaryCard({super.key, required this.subscriptions});

  final List<Subscription> subscriptions;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final palette = context.palette;

    final activeSubscriptions = subscriptions.where((s) => s.isActive).toList();
    final double totalMonthly = activeSubscriptions.fold(
      0.0,
      (sum, item) => sum + item.monthlyCost,
    );
    final double totalYearly = totalMonthly * 12;

    // Determine upcoming subscription
    Subscription? nextUpcoming;
    for (final s in activeSubscriptions) {
      if (s.nextRenewalDate != null &&
          s.daysRemaining != null &&
          s.daysRemaining! >= 0) {
        if (nextUpcoming == null ||
            s.daysRemaining! < nextUpcoming.daysRemaining!) {
          nextUpcoming = s;
        }
      }
    }

    final currencyCode = activeSubscriptions.isNotEmpty
        ? activeSubscriptions.first.currency
        : 'USD';
    final currencyFormatter = NumberFormat.simpleCurrency(
      name: currencyCode,
      decimalDigits: 2,
    );

    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'MONTHLY COMMITMENT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: colors.textSecondary,
                ),
              ),
              AppBadge(
                label: '${activeSubscriptions.length} active',
                color: palette.primary,
                showDot: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Text(
                  currencyFormatter.format(totalMonthly),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.2,
                    height: 1.05,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '/ month',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Divider(height: 1, color: colors.divider),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: _SummaryStat(
                  label: 'Yearly Projection',
                  value: currencyFormatter.format(totalYearly),
                  icon: Icons.calendar_today_rounded,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 14),
                color: colors.divider,
              ),
              Expanded(
                child: _SummaryStat(
                  label: 'Next Renewal',
                  value: nextUpcoming != null
                      ? nextUpcoming.name
                      : 'None upcoming',
                  hint: nextUpcoming?.remainingTimeText,
                  icon: Icons.refresh_rounded,
                  accent: nextUpcoming != null ? palette.primary : null,
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    this.hint,
    this.icon,
    this.accent,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final String? hint;
  final IconData? icon;
  final Color? accent;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final palette = context.palette;
    final valueColor = accent ?? palette.textPrimary;

    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: alignEnd
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 13, color: colors.textSecondary),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: valueColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
        ),
        if (hint != null) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            hint!,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: colors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          ),
        ],
      ],
    );
  }
}
