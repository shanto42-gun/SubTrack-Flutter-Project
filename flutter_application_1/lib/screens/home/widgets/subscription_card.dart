import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../models/subscription.dart';

class SubscriptionCard extends StatefulWidget {
  final Subscription subscription;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onDelete;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    required this.onTap,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  State<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<SubscriptionCard> {
  bool _isPressed = false;

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'entertainment':
      case 'streaming':
        return Icons.movie_outlined;
      case 'music':
        return Icons.music_note_outlined;
      case 'productivity':
      case 'software':
        return Icons.terminal_outlined;
      case 'cloud':
        return Icons.cloud_outlined;
      case 'fitness':
      case 'health':
        return Icons.fitness_center_outlined;
      case 'utilities':
        return Icons.bolt_outlined;
      case 'education':
        return Icons.school_outlined;
      case 'gaming':
        return Icons.sports_esports_outlined;
      default:
        return Icons.credit_card_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'entertainment':
      case 'streaming':
        return const Color(0xFF8B5CF6);
      case 'music':
        return const Color(0xFFEC4899);
      case 'productivity':
      case 'software':
        return const Color(0xFF3B82F6);
      case 'cloud':
        return const Color(0xFF06B6D4);
      case 'fitness':
      case 'health':
        return const Color(0xFF10B981);
      case 'utilities':
        return const Color(0xFFF59E0B);
      case 'education':
        return const Color(0xFF6366F1);
      case 'gaming':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFF6B7280);
    }
  }

  /// Status colour for the renewal countdown.
  ///
  /// Red for overdue, orange for imminent renewals, blue for the normal
  /// window and green for subscriptions that are comfortably running.
  Color _getStatusColor(int? days, bool isActive, BuildContext context) {
    final colors = context.appColors;
    if (!isActive) return colors.textSecondary;
    if (days == null) return colors.textSecondary;
    if (days < 0) return colors.danger;
    if (days <= 3) return colors.warning;
    if (days <= 7) return colors.palette.primary;
    return colors.success;
  }

  void _showActionBottomSheet(BuildContext context) {
    final colors = context.appColors;
    final palette = context.palette;
    final currencyFormatter = NumberFormat.simpleCurrency(
      name: widget.subscription.currency,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardSolid,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.subscription.name,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: palette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${currencyFormatter.format(widget.subscription.amount)} / ${widget.subscription.billingCycle} • ${widget.subscription.category}',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: colors.divider),
              const SizedBox(height: 6),

              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: palette.textPrimary,
                ),
                title: Text(
                  'Edit details',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  widget.onTap();
                },
              ),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  widget.subscription.isActive
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline,
                  size: 20,
                  color: widget.subscription.isActive
                      ? colors.warning
                      : colors.success,
                ),
                title: Text(
                  widget.subscription.isActive
                      ? 'Pause subscription'
                      : 'Activate subscription',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: palette.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  widget.onToggleActive(!widget.subscription.isActive);
                },
              ),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: colors.danger,
                ),
                title: Text(
                  'Delete subscription',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.danger,
                  ),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  widget.onDelete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final palette = context.palette;
    final categoryColor = _getCategoryColor(widget.subscription.category);
    final currencyFormatter = NumberFormat.simpleCurrency(
      name: widget.subscription.currency,
      decimalDigits: 2,
    );

    final daysRemaining = widget.subscription.daysRemaining;
    final statusColor = _getStatusColor(
      daysRemaining,
      widget.subscription.isActive,
      context,
    );
    final isActive = widget.subscription.isActive;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedScale(
        scale: _isPressed ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutCubic,
        child: AppCard(
          padding: const EdgeInsets.all(16),
          radius: 20,
          onTap: widget.onTap,
          onLongPress: () => _showActionBottomSheet(context),
          onHighlightChanged: (value) {
            if (mounted) setState(() => _isPressed = value);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  // Circular icon background
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: categoryColor.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Icon(
                      _getCategoryIcon(widget.subscription.category),
                      color: categoryColor,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name & category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                widget.subscription.name,
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                  height: 1.25,
                                  decoration: isActive
                                      ? TextDecoration.none
                                      : TextDecoration.lineThrough,
                                  color: isActive
                                      ? palette.textPrimary
                                      : colors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!isActive) ...<Widget>[
                              const SizedBox(width: 6),
                              AppBadge(
                                label: 'Paused',
                                color: colors.textSecondary,
                              ),
                            ],
                            if (widget.subscription.name.startsWith(
                              Subscription.demoPrefix,
                            )) ...<Widget>[
                              const SizedBox(width: 6),
                              AppBadge(label: 'Demo', color: palette.primary),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.subscription.category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Amount & billing cycle
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        currencyFormatter.format(widget.subscription.amount),
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: isActive
                              ? palette.textPrimary
                              : colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '/${widget.subscription.billingCycle}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),
              Divider(height: 1, color: colors.divider),
              const SizedBox(height: 12),

              // Status pill + renewal date
              Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.subscription.remainingTimeText,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.1,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (widget.subscription.nextRenewalDate != null)
                    Flexible(
                      child: Text(
                        'Renews ${DateFormat('MMM d, yyyy').format(widget.subscription.nextRenewalDate!)}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                ],
              ),

              // Cycle progress
              if (isActive &&
                  widget.subscription.nextRenewalDate != null) ...<Widget>[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: widget.subscription.cycleProgress,
                    minHeight: 4,
                    backgroundColor: colors.mutedSurface,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
