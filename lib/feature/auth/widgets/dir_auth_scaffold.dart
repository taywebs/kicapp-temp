import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:demandium/utils/core_export.dart';
import 'package:demandium/common/widgets/dir_ui.dart';

/// Shell shared by sign in and sign up.
///
/// A navy brand header carrying the Easy to find mark, with a white sheet
/// riding over it that holds the form — the same navy/gold language as the
/// splash, so the app feels like one product from launch to login.
class DirAuthScaffold extends StatelessWidget {
  const DirAuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBack = true,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool showBack;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    final double topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: DirTokens.navy,
      body: Column(
        children: <Widget>[
          // ── brand header ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(24, topInset + 8, 24, 26),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[DirTokens.navyLight, DirTokens.navy],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 40,
                  child: showBack
                      ? Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                            onPressed: onBack ?? () => Get.back<void>(),
                            icon: Icon(
                              rtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
                Row(
                  children: <Widget>[
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: DirTokens.gold.withValues(alpha: 0.35)),
                      ),
                      child: const Icon(Icons.travel_explore_rounded,
                          color: DirTokens.gold, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppConstants.appName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.66),
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),

          // ── form sheet ──
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: DirTokens.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Label sitting above an outlined field.
class DirFieldLabel extends StatelessWidget {
  const DirFieldLabel(this.text, {super.key, this.required = true});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 2, bottom: 6),
      child: Row(
        children: <Widget>[
          Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: DirTokens.onSurfaceVariant,
            ),
          ),
          if (required)
            const Padding(
              padding: EdgeInsetsDirectional.only(start: 3),
              child: Text('*', style: TextStyle(fontSize: 12.5, color: DirTokens.error)),
            ),
        ],
      ),
    );
  }
}

/// Thin "or" divider between the form and the social buttons.
class DirOrDivider extends StatelessWidget {
  const DirOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(child: Divider(color: DirTokens.outlineVariant, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or'.tr,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DirTokens.onSurfaceVariant,
            ),
          ),
        ),
        const Expanded(child: Divider(color: DirTokens.outlineVariant, height: 1)),
      ],
    );
  }
}
