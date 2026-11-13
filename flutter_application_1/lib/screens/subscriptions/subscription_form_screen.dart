import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/error_utils.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_gradient_background.dart';
import '../../core/widgets/app_text_field.dart';
import '../../models/predefined_platform.dart';
import '../../models/subscription.dart';
import '../../services/auth_service.dart';
import '../../services/subscription_service.dart';

class SubscriptionFormScreen extends StatefulWidget {
  final Subscription? subscription;

  const SubscriptionFormScreen({super.key, this.subscription});

  bool get isEditing => subscription != null;

  @override
  State<SubscriptionFormScreen> createState() => _SubscriptionFormScreenState();
}

class _SubscriptionFormScreenState extends State<SubscriptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subscriptionService = SubscriptionService();
  final _authService = AuthService();

  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;

  late String _selectedCategory;
  late String _selectedCurrency;
  late String _selectedBillingCycle;
  late DateTime _startDate;
  DateTime? _nextRenewalDate;
  late bool _isActive;
  String? _selectedPredefinedPlatform;

  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _categories = [
    'Entertainment',
    'Streaming',
    'Music',
    'Productivity',
    'Software',
    'Cloud',
    'Fitness',
    'Utilities',
    'Education',
    'Gaming',
    'Other',
  ];

  final List<String> _currencies = [
    'USD',
    'EUR',
    'GBP',
    'CAD',
    'AUD',
    'INR',
    'JPY',
  ];
  final List<String> _billingCycles = [
    'monthly',
    'yearly',
    'quarterly',
    'weekly',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.subscription;
    _nameController = TextEditingController(text: item?.name ?? '');
    _amountController = TextEditingController(
      text: item != null ? item.amount.toStringAsFixed(2) : '',
    );
    _notesController = TextEditingController(text: item?.notes ?? '');

    _selectedCategory = item?.category ?? 'Entertainment';
    _selectedCurrency = item?.currency ?? 'USD';
    _selectedBillingCycle = item?.billingCycle ?? 'monthly';
    _startDate = item?.startDate ?? DateTime.now();
    _nextRenewalDate = item?.nextRenewalDate;
    _isActive = item?.isActive ?? true;

    if (item != null) {
      _selectedPredefinedPlatform = item.name;
    } else {
      _calculateDefaultRenewalDate();
    }
  }

  void _calculateDefaultRenewalDate() {
    final now = _startDate;
    switch (_selectedBillingCycle) {
      case 'yearly':
        _nextRenewalDate = DateTime(now.year + 1, now.month, now.day);
        break;
      case 'quarterly':
        _nextRenewalDate = DateTime(now.year, now.month + 3, now.day);
        break;
      case 'weekly':
        _nextRenewalDate = now.add(const Duration(days: 7));
        break;
      case 'monthly':
      default:
        _nextRenewalDate = DateTime(now.year, now.month + 1, now.day);
        break;
    }
  }

  void _onPlatformSelected(PredefinedPlatform platform) {
    setState(() {
      _selectedPredefinedPlatform = platform.name;
      _nameController.text = platform.name;
      _selectedCategory = platform.category;
      if (_amountController.text.isEmpty || _amountController.text == '0.00') {
        _amountController.text = platform.defaultAmount.toStringAsFixed(2);
      }
      _selectedBillingCycle = platform.defaultBillingCycle;
      _calculateDefaultRenewalDate();
    });
  }

  void _onSelectCustomPlatform() {
    setState(() {
      _selectedPredefinedPlatform = 'Custom';
      _nameController.clear();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _calculateDefaultRenewalDate();
      });
    }
  }

  Future<void> _pickRenewalDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _nextRenewalDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _nextRenewalDate = picked;
      });
    }
  }

  Future<void> _saveSubscription() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUserId = _authService.currentUserId;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to save.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final double amount =
          double.tryParse(_amountController.text.trim()) ?? 0.0;

      final subscription = Subscription(
        id: widget.subscription?.id,
        userId: currentUserId,
        name: _nameController.text.trim(),
        category: _selectedCategory,
        amount: amount,
        currency: _selectedCurrency,
        billingCycle: _selectedBillingCycle,
        startDate: _startDate,
        nextRenewalDate: _nextRenewalDate,
        isActive: _isActive,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      if (widget.isEditing) {
        await _subscriptionService.updateSubscription(subscription);
      } else {
        await _subscriptionService.createSubscription(subscription);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = ErrorUtils.getErrorMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmDelete() async {
    final colors = context.appColors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardSolid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete subscription?'),
        content: Text(
          'Remove "${widget.subscription?.name}"? This action cannot be undone.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: colors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.subscription?.id != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _subscriptionService.deleteSubscription(widget.subscription!.id!);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = ErrorUtils.getErrorMessage(e);
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.background,
      body: AppGradientBackground(
        style: AppGradientStyle.hero,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              // ---- Header ----
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                child: Row(
                  children: <Widget>[
                    AppIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Back',
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.isEditing
                                ? 'Edit Subscription'
                                : 'New Subscription',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                              color: palette.textPrimary,
                            ),
                          ),
                          Text(
                            widget.isEditing
                                ? 'Update the details below'
                                : 'Add a recurring expense',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: palette.textPrimary.withValues(
                                alpha: 0.72,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.isEditing)
                      AppIconButton(
                        icon: Icons.delete_outline_rounded,
                        tooltip: 'Delete',
                        foregroundColor: colors.danger,
                        onPressed: _isLoading ? null : _confirmDelete,
                      ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (_errorMessage != null) ...<Widget>[
                          AppMessageBanner(
                            message: _errorMessage!,
                            color: colors.danger,
                          ),
                          const SizedBox(height: 18),
                        ],

                        // 1. PRESET PLATFORM CHIPS
                        const AppSectionLabel(text: 'Popular presets'),
                        SizedBox(
                          height: 38,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _PresetChip(
                                  label: 'Custom',
                                  icon: Icons.edit_outlined,
                                  iconColor: palette.primary,
                                  isSelected:
                                      _selectedPredefinedPlatform == 'Custom',
                                  onTap: _onSelectCustomPlatform,
                                ),
                              ),
                              ...PredefinedPlatform.popularPlatforms.map((
                                platform,
                              ) {
                                final isSelected =
                                    _selectedPredefinedPlatform ==
                                    platform.name;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _PresetChip(
                                    label: platform.name,
                                    icon: platform.icon,
                                    iconColor: platform.color,
                                    isSelected: isSelected,
                                    onTap: () => _onPlatformSelected(platform),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Service name
                        AppTextField(
                          controller: _nameController,
                          label: 'Service name',
                          hintText: 'e.g. Netflix, Spotify, AWS',
                          prefixIcon: Icons.label_outline_rounded,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Price and Currency
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              flex: 3,
                              child: AppTextField(
                                controller: _amountController,
                                label: 'Amount',
                                hintText: '9.99',
                                prefixIcon: Icons.attach_money_rounded,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Enter price';
                                  }
                                  final parsed = double.tryParse(value.trim());
                                  if (parsed == null || parsed < 0) {
                                    return 'Valid price';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedCurrency,
                                decoration: const InputDecoration(
                                  labelText: 'Currency',
                                ),
                                borderRadius: BorderRadius.circular(16),
                                items: _currencies
                                    .map(
                                      (curr) => DropdownMenuItem<String>(
                                        value: curr,
                                        child: Text(
                                          curr,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedCurrency = val);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Category and Billing Cycle
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedCategory,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  prefixIcon: Icon(
                                    Icons.category_outlined,
                                    size: 20,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(16),
                                items: _categories
                                    .map(
                                      (cat) => DropdownMenuItem<String>(
                                        value: cat,
                                        child: Text(
                                          cat,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedCategory = val);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedBillingCycle,
                                decoration: const InputDecoration(
                                  labelText: 'Billing Cycle',
                                  prefixIcon: Icon(
                                    Icons.repeat_rounded,
                                    size: 20,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(16),
                                items: _billingCycles
                                    .map(
                                      (cycle) => DropdownMenuItem<String>(
                                        value: cycle,
                                        child: Text(
                                          cycle[0].toUpperCase() +
                                              cycle.substring(1),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedBillingCycle = val;
                                      _calculateDefaultRenewalDate();
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Schedule Dates
                        AppCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 17,
                                    color: colors.textSecondary,
                                  ),
                                  const SizedBox(width: 9),
                                  Text(
                                    'Start date',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: palette.textPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: _pickStartDate,
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      DateFormat(
                                        'MMM d, yyyy',
                                      ).format(_startDate),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: palette.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(height: 18, color: colors.divider),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.alarm_on_rounded,
                                    size: 17,
                                    color: palette.primary,
                                  ),
                                  const SizedBox(width: 9),
                                  Text(
                                    'Next renewal',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: palette.textPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: _pickRenewalDate,
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      _nextRenewalDate != null
                                          ? DateFormat(
                                              'MMM d, yyyy',
                                            ).format(_nextRenewalDate!)
                                          : 'Pick date',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: palette.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Active switch
                        AppCard(
                          padding: EdgeInsets.zero,
                          child: SwitchListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            secondary: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: palette.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.play_circle_outline_rounded,
                                size: 20,
                                color: palette.primary,
                              ),
                            ),
                            title: Text(
                              'Active status',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: palette.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              _isActive
                                  ? 'Counts toward expenses and alerts'
                                  : 'Paused / Inactive',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.textSecondary,
                              ),
                            ),
                            value: _isActive,
                            onChanged: (val) => setState(() => _isActive = val),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Notes
                        AppTextField(
                          controller: _notesController,
                          label: 'Notes (optional)',
                          hintText: 'Account hint, plan tier, notes...',
                          maxLines: 2,
                        ),
                        const SizedBox(height: 24),

                        // Submit
                        AppPrimaryButton(
                          label: widget.isEditing
                              ? 'Save Changes'
                              : 'Add Subscription',
                          icon: widget.isEditing
                              ? Icons.check_rounded
                              : Icons.add_rounded,
                          isLoading: _isLoading,
                          onPressed: _saveSubscription,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rounded preset chip used for popular platforms.
class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final palette = context.palette;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? palette.primary : colors.card,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? palette.primary : palette.border,
          ),
          boxShadow: isSelected ? colors.softShadow : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 14, color: isSelected ? Colors.white : iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
                color: isSelected ? Colors.white : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
