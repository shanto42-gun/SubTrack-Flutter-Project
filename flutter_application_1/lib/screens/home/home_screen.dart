import 'package:flutter/material.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/error_utils.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_content.dart';
import '../../core/widgets/app_gradient_background.dart';
import '../../core/widgets/app_logo.dart';
import '../../models/subscription.dart';
import '../../services/profile_service.dart';
import '../../services/subscription_service.dart';
import '../settings/settings_screen.dart';
import '../subscriptions/subscription_form_screen.dart';
import 'widgets/subscription_card.dart';
import 'widgets/subscription_summary_card.dart';

class HomeScreen extends StatefulWidget {
  final SubscriptionService? service;
  final ProfileService? profileService;

  const HomeScreen({super.key, this.service, this.profileService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final SubscriptionService _subscriptionService =
      widget.service ?? SubscriptionService();

  int _currentTabIndex = 0;
  List<Subscription> _subscriptions = [];
  bool _isLoading = true;
  bool _isBusy = false;
  String? _errorMessage;
  String _selectedCategoryFilter = 'All';

  /// Whether the current list contains the demo records.
  bool get _hasDemoData => _subscriptions.any(
    (s) => s.name.startsWith(SubscriptionService.demoPrefix),
  );

  @override
  void initState() {
    super.initState();
    _fetchSubscriptions();
  }

  Future<void> _fetchSubscriptions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await _subscriptionService.getSubscriptions();
      if (mounted) {
        setState(() {
          _subscriptions = list;
          _isLoading = false;
        });
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

  Future<void> _handleToggleActive(Subscription item, bool newStatus) async {
    if (item.id == null) return;

    setState(() {
      final index = _subscriptions.indexWhere((s) => s.id == item.id);
      if (index != -1) {
        _subscriptions[index] = item.copyWith(isActive: newStatus);
      }
    });

    try {
      await _subscriptionService.toggleSubscriptionStatus(item.id!, newStatus);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${ErrorUtils.getErrorMessage(e)}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchSubscriptions();
      }
    }
  }

  Future<void> _handleDelete(Subscription item) async {
    if (item.id == null) return;

    final colors = context.appColors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardSolid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete subscription?'),
        content: Text(
          'Are you sure you want to remove "${item.name}"? This action cannot be undone.',
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

    if (confirmed == true) {
      try {
        await _subscriptionService.deleteSubscription(item.id!);
        setState(() {
          _subscriptions.removeWhere((s) => s.id == item.id);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${item.name}" deleted'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Delete failed: ${ErrorUtils.getErrorMessage(e)}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _openAddSubscription() async {
    final result = await Navigator.of(context).push<bool>(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, animation, secondaryAnimation) =>
            const SubscriptionFormScreen(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
    if (result == true) {
      _fetchSubscriptions();
    }
  }

  Future<void> _openEditSubscription(Subscription item) async {
    final result = await Navigator.of(context).push<bool>(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, animation, secondaryAnimation) =>
            SubscriptionFormScreen(subscription: item),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
      ),
    );
    if (result == true) {
      _fetchSubscriptions();
    }
  }

  Future<void> _seedDemoData() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);

    try {
      final created = await _subscriptionService.seedDemoSubscriptions();
      await _fetchSubscriptions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              created > 0
                  ? 'Added $created demo subscriptions'
                  : 'Demo subscriptions are already on your account',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not add demo data: ${ErrorUtils.getErrorMessage(e)}',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _clearDemoData() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);

    try {
      final removed = await _subscriptionService.clearDemoSubscriptions();
      await _fetchSubscriptions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              removed > 0
                  ? 'Removed $removed demo subscriptions'
                  : 'There was no demo data to remove',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not remove demo data: ${ErrorUtils.getErrorMessage(e)}',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  void _handleMenuAction(String value) {
    switch (value) {
      case 'seed':
        _seedDemoData();
        break;
      case 'clear':
        _clearDemoData();
        break;
    }
  }

  List<Subscription> get _filteredSubscriptions {
    if (_selectedCategoryFilter == 'All') {
      return _subscriptions;
    }
    return _subscriptions
        .where(
          (s) =>
              s.category.toLowerCase() == _selectedCategoryFilter.toLowerCase(),
        )
        .toList();
  }

  List<String> get _availableCategories {
    final Set<String> categories = <String>{'All'};
    for (final s in _subscriptions) {
      if (s.category.isNotEmpty) {
        categories.add(s.category);
      }
    }
    return categories.toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final palette = context.palette;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: palette.background,
      extendBody: true,
      body: AppGradientBackground(
        style: AppGradientStyle.hero,
        child: SafeArea(
          bottom: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeIn,
            child: _currentTabIndex == 0
                ? _buildHomeBody()
                : SettingsScreen(
                    key: const ValueKey<String>('settings'),
                    profileService: widget.profileService,
                  ),
          ),
        ),
      ),
      floatingActionButton: _currentTabIndex == 0 && _subscriptions.isNotEmpty
          ? _buildAddButton(palette)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(14, 0, 14, 12 + bottomInset),
        child: AppContent(
          maxWidth: 460,
          heightFactor: 1,
          child: Container(
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: palette.border.withValues(alpha: 0.9)),
              boxShadow: colors.cardShadow,
            ),
            clipBehavior: Clip.antiAlias,
            child: NavigationBar(
              selectedIndex: _currentTabIndex,
              backgroundColor: Colors.transparent,
              onDestinationSelected: (index) {
                setState(() {
                  _currentTabIndex = index;
                });
              },
              destinations: const <NavigationDestination>[
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.tune_outlined),
                  selectedIcon: Icon(Icons.tune_rounded),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(AppPalette palette) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: <Color>[palette.secondary, palette.primary, palette.deep],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.40),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: _openAddSubscription,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.add_rounded, size: 21, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'New Subscription',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeBody() {
    final colors = context.appColors;
    final palette = context.palette;

    if (_isLoading) {
      return Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            valueColor: AlwaysStoppedAnimation<Color>(palette.primary),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return AppContent(
        maxWidth: 680,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
          children: <Widget>[
            Icon(Icons.cloud_off_rounded, size: 46, color: colors.danger),
            const SizedBox(height: 14),
            Text(
              'Failed to load subscriptions',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            AppPrimaryButton(
              label: 'Try Again',
              icon: Icons.refresh_rounded,
              height: 50,
              onPressed: _fetchSubscriptions,
            ),
          ],
        ),
      );
    }

    final filteredList = _filteredSubscriptions;

    return AppContent(
      maxWidth: 680,
      child: RefreshIndicator(
        onRefresh: _fetchSubscriptions,
        color: palette.primary,
        backgroundColor: colors.cardSolid,
        displacement: 28,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 132),
          children: <Widget>[
            // ---- Header ----
            Row(
              children: <Widget>[
                const AppLogo(size: 42, subtitle: 'Subscription tracker'),
                const Spacer(),
                AppIconButton(
                  icon: Icons.refresh_rounded,
                  tooltip: 'Refresh',
                  onPressed: _fetchSubscriptions,
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: 'More options',
                  padding: EdgeInsets.zero,
                  position: PopupMenuPosition.under,
                  offset: const Offset(0, 8),
                  onSelected: _handleMenuAction,
                  itemBuilder: (context) => <PopupMenuEntry<String>>[
                    if (!_hasDemoData)
                      PopupMenuItem<String>(
                        value: 'seed',
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 18,
                              color: context.palette.primary,
                            ),
                            const SizedBox(width: 10),
                            const Text('Add demo data'),
                          ],
                        ),
                      )
                    else
                      PopupMenuItem<String>(
                        value: 'clear',
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.cleaning_services_rounded,
                              size: 18,
                              color: context.palette.primary,
                            ),
                            const SizedBox(width: 10),
                            const Text('Remove demo data'),
                          ],
                        ),
                      ),
                  ],
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colors.card,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: palette.border.withValues(alpha: 0.8),
                      ),
                    ),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      size: 20,
                      color: palette.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ---- Monthly commitment ----
            SubscriptionSummaryCard(subscriptions: _subscriptions),
            const SizedBox(height: 20),

            // ---- Category filters ----
            if (_availableCategories.length > 1) ...<Widget>[
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableCategories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _availableCategories[index];
                    final isSelected = _selectedCategoryFilter == cat;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCategoryFilter = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? palette.primary : colors.card,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: isSelected
                                ? palette.primary
                                : palette.border.withValues(alpha: 0.9),
                          ),
                          boxShadow: isSelected ? colors.softShadow : null,
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              letterSpacing: -0.1,
                              color: isSelected
                                  ? Colors.white
                                  : colors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ---- Section header ----
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Subscriptions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: palette.textPrimary,
                  ),
                ),
                AppBadge(
                  label: '${filteredList.length} total',
                  color: palette.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ---- List or empty state ----
            if (filteredList.isEmpty)
              _buildEmptyState()
            else
              for (final item in filteredList)
                SubscriptionCard(
                  subscription: item,
                  onTap: () => _openEditSubscription(item),
                  onToggleActive: (val) => _handleToggleActive(item, val),
                  onDelete: () => _handleDelete(item),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colors = context.appColors;
    final palette = context.palette;
    final isFiltered = _selectedCategoryFilter != 'All';

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
      child: Column(
        children: <Widget>[
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  palette.light.withValues(alpha: 0.9),
                  palette.primary.withValues(alpha: 0.18),
                ],
              ),
            ),
            child: Center(
              child: Icon(
                isFiltered
                    ? Icons.filter_alt_off_rounded
                    : Icons.receipt_long_outlined,
                size: 36,
                color: palette.primary,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            isFiltered
                ? 'No items in "$_selectedCategoryFilter"'
                : 'No subscriptions yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isFiltered
                ? 'Try switching filters or add a new subscription.'
                : 'Add your recurring expenses to track renewals and costs.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: colors.textSecondary,
            ),
          ),
          if (!isFiltered) ...<Widget>[
            const SizedBox(height: 22),
            AppPrimaryButton(
              label: 'Add Subscription',
              icon: Icons.add_rounded,
              height: 50,
              onPressed: _openAddSubscription,
            ),
            const SizedBox(height: 10),
            AppSecondaryButton(
              label: 'Try demo data',
              icon: Icons.auto_awesome_rounded,
              height: 48,
              onPressed: _isBusy ? null : _seedDemoData,
            ),
          ],
        ],
      ),
    );
  }
}
