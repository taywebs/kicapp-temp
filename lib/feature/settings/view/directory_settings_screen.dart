import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:demandium/utils/core_export.dart';
import 'package:demandium/helper/route_helper.dart';
import 'package:demandium/common/widgets/dir_ui.dart';

/// Settings list for the Directory tab bar.
///
/// Vertical Settings-List pattern: grouped cards, one row per option with an
/// icon, a title, a short description and a trailing chevron. Direction-aware,
/// so the whole screen mirrors correctly in Arabic.
class DirectorySettingsScreen extends StatelessWidget {
  const DirectorySettingsScreen({super.key});

  bool get _isLoggedIn => Get.find<AuthController>().isLoggedIn();

  ConfigContent? get _config => Get.find<SplashController>().configModel.content;

  /// Opens a screen wearing the Directory look, so nothing inside the
  /// Directory settings shows the Demandium palette.
  void _open(Widget page) => dirTo<void>(page);

  /// Screens that must stay behind a login.
  void _openGuarded(bool loggedIn, Widget page) {
    if (!loggedIn) {
      _askToSignIn();
      return;
    }
    dirTo<void>(page);
  }

  void _askToSignIn() {
    Get.dialog<void>(
      DirThemed(
        child: AlertDialog(
          title: Text('login_required'.tr),
          content: Text('login_required_desc'.tr),
          actions: <Widget>[
            TextButton(onPressed: () => Get.back<void>(), child: Text('cancel'.tr)),
            ElevatedButton(
              onPressed: () {
                Get.back<void>();
                Get.toNamed(RouteHelper.getSignInRoute());
              },
              child: Text('sign_in'.tr),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    if (!_isLoggedIn) {
      Get.toNamed(RouteHelper.getSignInRoute());
      return;
    }
    Get.dialog(
      ConfirmationDialog(
        icon: Images.logoutIcon,
        title: 'are_you_sure_to_logout'.tr,
        description: 'if_you_logged_out_your_cart_will_be_removed'.tr,
        onYesPressed: () {
          Get.find<AuthController>().clearSharedData();
          Get.find<AuthController>().logOut();
          Get.find<AuthController>().googleLogout();
          Get.find<AuthController>().signOutWithFacebook();
          Get.find<LocationController>().updateSelectedAddress(null);
          Get.offAllNamed(RouteHelper.getInitialRoute());
        },
      ),
      useSafeArea: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool loggedIn = _isLoggedIn;

    return Scaffold(
      backgroundColor: DirTokens.background,
      appBar: AppBar(
        backgroundColor: DirTokens.surfaceLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('settings'.tr,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700, color: DirTokens.onSurface)),
      ),
      body: GetBuilder<ThemeController>(
        builder: (ThemeController themeController) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: <Widget>[
            _AccountHeader(loggedIn: loggedIn),
            const SizedBox(height: 20),

            _SettingsGroup(
              title: 'account'.tr,
              rows: <SettingsRow>[
                SettingsRow(
                  icon: Icons.person_outline_rounded,
                  title: 'profile'.tr,
                  subtitle: 'manage_your_personal_information'.tr,
                  onTap: () => _openGuarded(loggedIn, const ProfileScreen()),
                ),
                SettingsRow(
                  icon: Icons.location_on_outlined,
                  title: 'address'.tr,
                  subtitle: 'saved_delivery_locations'.tr,
                  onTap: () => _openGuarded(
                      loggedIn, const AddressScreen(fromPage: 'fromProfileScreen')),
                ),
                SettingsRow(
                  icon: Icons.notifications_none_rounded,
                  title: 'notification'.tr,
                  subtitle: 'offers_and_booking_updates'.tr,
                  onTap: () => _open(const NotificationScreen()),
                ),
              ],
            ),

            _SettingsGroup(
              title: 'preferences'.tr,
              rows: <SettingsRow>[
                SettingsRow(
                  icon: Icons.translate_rounded,
                  title: 'language'.tr,
                  subtitle: 'choose_your_app_language'.tr,
                  onTap: () => Get.bottomSheet<void>(
                    const DirThemed(child: ChooseLanguageBottomSheet()),
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                  ),
                ),
                SettingsRow(
                  icon: Icons.dark_mode_outlined,
                  title: 'dark_mode'.tr,
                  subtitle: 'easier_on_the_eyes_at_night'.tr,
                  trailing: Switch.adaptive(
                    value: themeController.darkTheme,
                    activeTrackColor: DirTokens.secondaryContainer,
                    onChanged: (bool _) => themeController.toggleTheme(),
                  ),
                  onTap: themeController.toggleTheme,
                ),
                SettingsRow(
                  icon: Icons.tune_rounded,
                  title: 'general_settings'.tr,
                  subtitle: 'app_preferences_and_account_actions'.tr,
                  onTap: () => _open(const SettingScreen()),
                ),
              ],
            ),

            _SettingsGroup(
              title: 'support'.tr,
              rows: <SettingsRow>[
                SettingsRow(
                  icon: Icons.headset_mic_outlined,
                  title: 'help_&_support'.tr,
                  subtitle: 'contact_our_team'.tr,
                  onTap: () => _open(SupportScreen()),
                ),
                if (_config?.referEarnStatus == 1)
                  SettingsRow(
                    icon: Icons.card_giftcard_outlined,
                    title: 'refer_and_earn'.tr,
                    subtitle: 'invite_friends_and_get_rewards'.tr,
                    onTap: () =>
                        _openGuarded(loggedIn, const ReferAndEarnScreen()),
                  ),
                SettingsRow(
                  icon: Icons.map_outlined,
                  title: 'service_area'.tr,
                  subtitle: 'where_we_currently_operate'.tr,
                  onTap: () => _open(const ServiceAreaScreen()),
                ),
              ],
            ),

            _SettingsGroup(
              title: 'legal'.tr,
              rows: <SettingsRow>[
                SettingsRow(
                  icon: Icons.info_outline_rounded,
                  title: 'about_us'.tr,
                  subtitle: 'who_we_are'.tr,
                  onTap: () => _open(const HtmlViewerScreen(htmlType: HtmlType.aboutUs)),
                ),
                SettingsRow(
                  icon: Icons.privacy_tip_outlined,
                  title: 'privacy_policy'.tr,
                  subtitle: 'how_we_handle_your_data'.tr,
                  onTap: () => _open(const HtmlViewerScreen(htmlType: HtmlType.privacyPolicy)),
                ),
                if ((_config?.termsAndConditions ?? '') != '')
                  SettingsRow(
                    icon: Icons.description_outlined,
                    title: 'terms_and_conditions'.tr,
                    subtitle: 'rules_of_using_the_app'.tr,
                    onTap: () =>
                        _open(const HtmlViewerScreen(htmlType: HtmlType.termsAndCondition)),
                  ),
                if ((_config?.refundPolicy ?? '') != '')
                  SettingsRow(
                    icon: Icons.replay_outlined,
                    title: 'refund_policy'.tr,
                    subtitle: 'when_refunds_apply'.tr,
                    onTap: () => _open(const HtmlViewerScreen(htmlType: HtmlType.refundPolicy)),
                  ),
                if ((_config?.cancellationPolicy ?? '') != '')
                  SettingsRow(
                    icon: Icons.cancel_outlined,
                    title: 'cancellation_policy'.tr,
                    subtitle: 'cancelling_a_booking'.tr,
                    onTap: () =>
                        _open(const HtmlViewerScreen(htmlType: HtmlType.cancellationPolicy)),
                  ),
              ],
            ),

            _SettingsGroup(
              rows: <SettingsRow>[
                SettingsRow(
                  icon: loggedIn ? Icons.logout_rounded : Icons.login_rounded,
                  title: loggedIn ? 'logout'.tr : 'sign_in'.tr,
                  subtitle: loggedIn
                      ? 'sign_out_of_this_device'.tr
                      : 'access_your_bookings_and_favorites'.tr,
                  destructive: loggedIn,
                  onTap: _confirmLogout,
                ),
              ],
            ),

            const SizedBox(height: 8),
            Center(
              child: Text(
                '${AppConstants.appName}  v${AppConstants.appVersion}',
                style: const TextStyle(fontSize: 12, color: DirTokens.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One option in the settings list.
class SettingsRow {
  const SettingsRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool destructive;
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.rows, this.title});

  final String? title;
  final List<SettingsRow> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (title != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
              child: Text(
                title!.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: DirTokens.onSurfaceVariant,
                ),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: DirTokens.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DirTokens.outlineVariant),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                children: List<Widget>.generate(rows.length * 2 - 1, (int i) {
                  if (i.isOdd) {
                    return const Divider(
                      height: 1,
                      thickness: 1,
                      indent: 60,
                      color: Color(0xFFEDEFF1),
                    );
                  }
                  return _SettingsTile(row: rows[i ~/ 2]);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.row});

  final SettingsRow row;

  @override
  Widget build(BuildContext context) {
    final Color foreground = row.destructive ? const Color(0xFFBA1A1A) : DirTokens.onSurface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: row.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: row.destructive ? const Color(0x14BA1A1A) : DirTokens.surfaceHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(row.icon, size: 20, color: foreground),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      row.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600, color: foreground),
                    ),
                    if (row.subtitle != null && row.subtitle!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          row.subtitle!,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 12, color: DirTokens.onSurfaceVariant),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              row.trailing ??
                  Icon(
                    // Mirrors automatically for Arabic.
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    color: DirTokens.onSurfaceVariant,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.loggedIn});

  final bool loggedIn;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(
      builder: (UserController userController) {
        final String name = loggedIn
            ? '${userController.userInfoModel?.fName ?? ''} ${userController.userInfoModel?.lName ?? ''}'.trim()
            : 'guest'.tr;
        final String? photo = userController.userInfoModel?.imageFullPath;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DirTokens.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: DirTokens.outlineVariant),
          ),
          child: Row(
            children: <Widget>[
              ClipOval(
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: CustomImage(image: photo ?? '', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name.isEmpty ? 'guest'.tr : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700, color: DirTokens.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      loggedIn
                          ? (userController.userInfoModel?.email ?? '')
                          : 'sign_in_to_sync_your_data'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: DirTokens.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => loggedIn
                    ? Get.toNamed(RouteHelper.getEditProfileRoute())
                    : Get.toNamed(RouteHelper.getSignInRoute()),
                child: Text(loggedIn ? 'edit'.tr : 'sign_in'.tr,
                    style: const TextStyle(
                        color: DirTokens.secondary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      },
    );
  }
}
