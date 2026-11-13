import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/utils/error_utils.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_content.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final ProfileService? profileService;

  const SettingsScreen({super.key, this.profileService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  late final ProfileService _profileService =
      widget.profileService ?? ProfileService();

  final _fullNameController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _profileService.getProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _fullNameController.text = profile?.fullName ?? '';
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

  Future<void> _saveProfile() async {
    final currentUserId = _authService.currentUserId;
    if (currentUserId == null) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final updated = UserProfile(
        id: currentUserId,
        email: _authService.currentUserEmail ?? '',
        fullName: _fullNameController.text.trim(),
        avatarUrl: _userProfile?.avatarUrl,
        updatedAt: DateTime.now(),
      );

      final saved = await _profileService.upsertProfile(updated);
      if (mounted) {
        setState(() {
          _userProfile = saved;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated'),
            behavior: SnackBarBehavior.floating,
          ),
        );
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
          _isSaving = false;
        });
      }
    }
  }

  void _showPrivacyPolicy(BuildContext context) {
    final colors = context.appColors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.cardSolid,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.85,
        minChildSize: 0.45,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: ListView(
            controller: scrollController,
            children: <Widget>[
              Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Updated November 2026',
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Text(
                '1. Complete Data Ownership\n'
                'Your subscription records, renewals, and amounts are stored exclusively in your own private Supabase database.\n\n'
                '2. Row Level Security (RLS)\n'
                'Database-level RLS policies strictly guarantee that only your authenticated user ID can read or mutate your data.\n\n'
                '3. No Ads or Tracking\n'
                'SubTrack does not track personal analytics, sell profile details, or share financial data with any third parties.\n\n'
                '4. Secure Sessions\n'
                'Authentication credentials and tokens are encrypted securely using standard TLS and JWT signatures.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: colors.textPrimary.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutApp(BuildContext context) {
    final colors = context.appColors;
    final palette = context.palette;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.cardSolid,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[palette.secondary, palette.primary],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.track_changes_rounded,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'SubTrack',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Version 1.0.0',
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Text(
                'A clean, minimalist subscription tracker built for Android and Web. Manage recurring expenses, renewal dates, and reminders without distractions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSignOut() async {
    final userEmail = _authService.currentUserEmail ?? 'your account';
    final colors = context.appColors;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardSolid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign out?'),
        content: Text('Are you sure you want to sign out of $userEmail?'),
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
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final palette = context.palette;
    final userEmail = _authService.currentUserEmail ?? 'No email';
    final userId = _authService.currentUserId ?? 'Unknown';

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

    final initial =
        (_fullNameController.text.isNotEmpty
                ? _fullNameController.text[0]
                : userEmail.isNotEmpty
                ? userEmail[0]
                : 'U')
            .toUpperCase();

    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        // Provides the Material ancestor that list tiles and text fields
        // require, so the screen can be hosted anywhere.
        return Material(
          type: MaterialType.transparency,
          child: AppContent(
            maxWidth: 680,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 132),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // ---- Header ----
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          color: palette.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Personalise your SubTrack experience',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: palette.textPrimary.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  if (_errorMessage != null) ...<Widget>[
                    AppMessageBanner(
                      message: _errorMessage!,
                      color: colors.danger,
                    ),
                    const SizedBox(height: 18),
                  ],

                  // ---- 1. Profile ----
                  const AppSectionLabel(text: 'Profile'),
                  AppCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: <Color>[
                                    palette.secondary,
                                    palette.primary,
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: colors.softShadow,
                              ),
                              child: Center(
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    _userProfile?.fullName != null &&
                                            _userProfile!.fullName!.isNotEmpty
                                        ? _userProfile!.fullName!
                                        : 'Subscriber',
                                    style: TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                      color: palette.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    userEmail,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: colors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(height: 1, color: colors.divider),
                        const SizedBox(height: 16),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: TextFormField(
                                controller: _fullNameController,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'Display name',
                                  prefixIcon: const Icon(
                                    Icons.person_outline_rounded,
                                    size: 19,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              height: 46,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(84, 46),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(fontSize: 13.5),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 15,
                                        height: 15,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Save'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---- 2. Appearance / themes ----
                  const AppSectionLabel(text: 'Appearance'),
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Theme',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: palette.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Pick the look that matches your style. Your choice is saved automatically.',
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final columns = constraints.maxWidth > 520 ? 3 : 2;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: AppPalettes.all.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: columns,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.95,
                                  ),
                              itemBuilder: (context, index) {
                                final option = AppPalettes.all[index];
                                final isSelected =
                                    themeController.themeId == option.id;
                                return _ThemeOption(
                                  palette: option,
                                  isSelected: isSelected,
                                  onTap: () =>
                                      themeController.setTheme(option.id),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---- 3. Preferences ----
                  const AppSectionLabel(text: 'Preferences'),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 6,
                      ),
                      secondary: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: palette.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.notifications_active_outlined,
                          size: 19,
                          color: palette.primary,
                        ),
                      ),
                      title: Text(
                        'Renewal reminders',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: palette.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Alert before upcoming subscription renewals',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: colors.textSecondary,
                        ),
                      ),
                      value: themeController.notificationsEnabled,
                      onChanged: (val) =>
                          themeController.setNotificationsEnabled(val),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---- 4. System & privacy ----
                  const AppSectionLabel(text: 'System & Privacy'),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                          ),
                          leading: _TileIcon(
                            icon: Icons.privacy_tip_outlined,
                            color: palette.primary,
                          ),
                          title: Text(
                            'Privacy policy',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: palette.textPrimary,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: colors.textSecondary,
                          ),
                          onTap: () => _showPrivacyPolicy(context),
                        ),
                        Divider(height: 1, color: colors.divider),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                          ),
                          leading: _TileIcon(
                            icon: Icons.info_outline_rounded,
                            color: palette.secondary,
                          ),
                          title: Text(
                            'About SubTrack',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: palette.textPrimary,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: colors.textSecondary,
                          ),
                          onTap: () => _showAboutApp(context),
                        ),
                        Divider(height: 1, color: colors.divider),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                          ),
                          leading: _TileIcon(
                            icon: Icons.badge_outlined,
                            color: colors.textSecondary,
                          ),
                          title: Text(
                            'Account identifier',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: palette.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            userId,
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              color: colors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 17),
                            tooltip: 'Copy ID',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: userId));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Copied to clipboard'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),

                  // ---- 5. Sign out ----
                  AppSecondaryButton(
                    label: 'Sign Out',
                    icon: Icons.logout_rounded,
                    foregroundColor: colors.danger,
                    onPressed: _confirmSignOut,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'SubTrack v1.0.0',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: colors.textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Small rounded icon container used in list tiles.
class _TileIcon extends StatelessWidget {
  const _TileIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

/// Theme preview tile used in the appearance section.
class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.palette,
    required this.isSelected,
    required this.onTap,
  });

  final AppPalette palette;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${palette.name} theme',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.palette.primary.withValues(alpha: 0.07)
                : colors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? colors.palette.primary
                  : colors.palette.border,
              width: isSelected ? 1.8 : 1,
            ),
            boxShadow: isSelected ? colors.softShadow : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <Color>[
                              palette.gradientTop,
                              palette.gradientMid,
                              palette.gradientBottom,
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: palette.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 9),
              Text(
                palette.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: colors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                isSelected ? 'Selected' : palette.tagline,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? colors.palette.primary
                      : colors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
