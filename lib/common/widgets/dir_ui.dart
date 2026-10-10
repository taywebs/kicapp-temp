import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Design tokens for the Directory surface ("Easy to find").
/// Every Directory screen paints from here, so the whole feature can be
/// re-themed from one place.
class DirTokens {
  DirTokens._();

  static const Color background = Color(0xFFF7FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFF1F4F6);
  static const Color surfaceHigh = Color(0xFFE5E9EB);
  static const Color primary = Color(0xFF000000);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF181C1E);
  static const Color onSurfaceVariant = Color(0xFF46474A);
  static const Color outlineVariant = Color(0xFFC7C6CA);
  static const Color secondary = Color(0xFF775A19);
  static const Color secondaryContainer = Color(0xFFFED488);
  static const Color onSecondaryContainer = Color(0xFF785A1A);
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF137A4B);

  /// Brand marks shared with the splash screen.
  static const Color navy = Color(0xFF06172F);
  static const Color navyDeep = Color(0xFF020A16);
  static const Color navyLight = Color(0xFF0B2348);
  static const Color gold = Color(0xFFFFC342);

  static const double radius = 12;
  static const double radiusLarge = 16;
}

/// A Material theme built from [DirTokens].
///
/// Wrapping an existing screen in [DirThemed] re-skins every themed widget it
/// uses (buttons, inputs, app bars, dialogs) without touching that screen's
/// code — this is how Demandium screens opened from the Directory take on the
/// Directory look.
ThemeData dirThemeData() {
  const ColorScheme scheme = ColorScheme.light(
    primary: DirTokens.primary,
    onPrimary: DirTokens.onPrimary,
    secondary: DirTokens.secondary,
    onSecondary: DirTokens.onPrimary,
    secondaryContainer: DirTokens.secondaryContainer,
    onSecondaryContainer: DirTokens.onSecondaryContainer,
    surface: DirTokens.background,
    onSurface: DirTokens.onSurface,
    error: DirTokens.error,
    onError: DirTokens.onPrimary,
  );

  return ThemeData(
    useMaterial3: false,
    fontFamily: 'Roboto',
    brightness: Brightness.light,
    colorScheme: scheme,
    primaryColor: DirTokens.primary,
    primaryColorLight: DirTokens.surfaceLow,
    scaffoldBackgroundColor: DirTokens.background,
    cardColor: DirTokens.surface,
    canvasColor: DirTokens.background,
    dividerColor: DirTokens.outlineVariant,
    shadowColor: const Color(0x14000000),
    hintColor: const Color(0xFF8A8F96),
    disabledColor: const Color(0xFFB9BDC2),
    appBarTheme: const AppBarTheme(
      backgroundColor: DirTokens.surfaceLow,
      foregroundColor: DirTokens.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: DirTokens.onSurface),
      titleTextStyle: TextStyle(
        color: DirTokens.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontFamily: 'Roboto',
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DirTokens.primary,
        foregroundColor: DirTokens.onPrimary,
        disabledBackgroundColor: DirTokens.surfaceHigh,
        elevation: 0,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DirTokens.radius)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: DirTokens.secondary),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: DirTokens.onSurface,
        minimumSize: const Size(0, 52),
        side: const BorderSide(color: DirTokens.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DirTokens.radius)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DirTokens.surface,
      hintStyle: const TextStyle(color: Color(0xFF8A8F96), fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DirTokens.radius),
        borderSide: const BorderSide(color: DirTokens.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DirTokens.radius),
        borderSide: const BorderSide(color: DirTokens.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DirTokens.radius),
        borderSide: const BorderSide(color: DirTokens.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DirTokens.radius),
        borderSide: const BorderSide(color: DirTokens.error),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> states) =>
            states.contains(WidgetState.selected) ? DirTokens.primary : Colors.transparent,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: DirTokens.surface,
      surfaceTintColor: Colors.transparent,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: DirTokens.primary),
  );
}

/// Applies the Directory look to any subtree.
class DirThemed extends StatelessWidget {
  const DirThemed({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Theme(data: dirThemeData(), child: child);
}

/// Opens [page] with the Directory look applied.
Future<T?>? dirTo<T>(Widget page) => Get.to<T>(() => DirThemed(child: page));

/// App bar shared by the Directory's inner screens.
class DirAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DirAppBar({super.key, required this.title, this.showBack = true, this.actions});

  final String title;
  final bool showBack;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: DirTokens.surfaceLow,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              icon: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_forward_rounded
                    : Icons.arrow_back_rounded,
                color: DirTokens.onSurface,
              ),
              onPressed: () => Get.back<void>(),
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: DirTokens.onSurface,
        ),
      ),
      actions: actions,
    );
  }
}

/// Primary action button of the Directory.
class DirButton extends StatelessWidget {
  const DirButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.outlined = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool outlined;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final Widget content = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: DirTokens.onPrimary),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[icon!, const SizedBox(width: 8)],
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ],
          );

    if (outlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: DirTokens.onSurface,
            minimumSize: const Size(0, 52),
            side: const BorderSide(color: DirTokens.outlineVariant),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DirTokens.radius)),
          ),
          child: content,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: DirTokens.primary,
          foregroundColor: DirTokens.onPrimary,
          disabledBackgroundColor: DirTokens.surfaceHigh,
          elevation: 0,
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DirTokens.radius)),
        ),
        child: content,
      ),
    );
  }
}

/// Labelled text field of the Directory.
class DirField extends StatelessWidget {
  const DirField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
    this.prefix,
    this.focusNode,
    this.textInputAction,
    this.onSubmitted,
    this.validator,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  final Widget? prefix;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 2, bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: DirTokens.onSurfaceVariant,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onSubmitted,
          validator: validator,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 15, color: DirTokens.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefix,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}

/// Empty / error state used across the Directory.
class DirEmptyState extends StatelessWidget {
  const DirEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(color: DirTokens.surfaceHigh, shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: DirTokens.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w700, color: DirTokens.onSurface),
            ),
            if (message != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: DirTokens.onSurfaceVariant),
              ),
            ],
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                child: DirButton(label: actionLabel!, onPressed: onAction),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
