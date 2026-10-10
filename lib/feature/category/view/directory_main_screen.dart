import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:demandium/utils/core_export.dart';
import 'package:demandium/common/widgets/dir_ui.dart';
import 'package:demandium/feature/category/view/directory_home_screen.dart';
import 'package:demandium/feature/category/view/directory_explore_screen.dart';
import 'package:demandium/feature/category/view/directory_saved_screen.dart';
import 'package:demandium/feature/settings/view/directory_settings_screen.dart';

/// Shell of the Directory app: the first screen "Easy to find" opens on.
class DirectoryMainScreen extends StatefulWidget {
  final int initialIndex;
  final String? categoryId;
  final String? categoryName;

  const DirectoryMainScreen({
    super.key,
    this.initialIndex = 0,
    this.categoryId,
    this.categoryName,
  });

  @override
  State<DirectoryMainScreen> createState() => _DirectoryMainScreenState();
}

class _DirectoryMainScreenState extends State<DirectoryMainScreen> {
  int _pageIndex = 0;
  late final List<Widget> _screens;
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.initialIndex;
    _screens = <Widget>[
      const DirectoryHomeScreen(),
      DirectoryExploreScreen(
        categoryId: widget.categoryId ?? '',
        categoryName: widget.categoryName ?? 'explore'.tr,
      ),
      const DirectorySavedScreen(),
      const DirectorySettingsScreen(),
    ];
  }

  void _setPage(int index) {
    if (index == _pageIndex) return;
    setState(() => _pageIndex = index);
  }

  /// Home is the app's root: tabs fall back to Home, then a double press exits.
  Future<bool> _onWillPop() async {
    if (_pageIndex != 0) {
      setState(() => _pageIndex = 0);
      return false;
    }
    final DateTime now = DateTime.now();
    if (_lastBackPressed == null || now.difference(_lastBackPressed!) > const Duration(seconds: 2)) {
      _lastBackPressed = now;
      customSnackBar('back_press_again_to_exit'.tr, type: ToasterMessageType.info);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        if (await _onWillPop()) {
          // Root of the app: leave to the OS instead of popping an empty stack.
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: DirTokens.background,
        // IndexedStack keeps each tab alive: no refetch and no lost scroll
        // position when switching tabs.
        body: IndexedStack(index: _pageIndex, children: _screens),
        bottomNavigationBar: _DirectoryNavBar(
          currentIndex: _pageIndex,
          onTap: _setPage,
        ),
      ),
    );
  }
}

class _DirectoryNavBar extends StatelessWidget {
  const _DirectoryNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_NavItem> _items = <_NavItem>[
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'home'),
    _NavItem(Icons.explore_outlined, Icons.explore_rounded, 'explore'),
    _NavItem(Icons.bookmark_outline_rounded, Icons.bookmark_rounded, 'saved'),
    _NavItem(Icons.settings_outlined, Icons.settings_rounded, 'settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DirTokens.surface,
        border: Border(top: BorderSide(color: DirTokens.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List<Widget>.generate(_items.length, (int index) {
              final _NavItem item = _items[index];
              final bool selected = index == currentIndex;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  borderRadius: BorderRadius.circular(999),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: selected ? DirTokens.secondaryContainer : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Icon(
                          selected ? item.activeIcon : item.icon,
                          size: 24,
                          color: selected ? DirTokens.onSecondaryContainer : DirTokens.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label.tr,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? DirTokens.onSecondaryContainer : DirTokens.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.activeIcon, this.label);
  final IconData icon;
  final IconData activeIcon;
  final String label;
}
