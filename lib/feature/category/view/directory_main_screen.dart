import 'dart:ui';
import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';
import 'package:demandium/feature/category/view/directory_home_screen.dart';
import 'package:demandium/feature/category/view/directory_explore_screen.dart';
import 'package:demandium/feature/category/view/directory_saved_screen.dart';
import 'package:demandium/feature/menu/menu_screen.dart';

// Brand Colors
const Color _kPrimary = Color(0xFF1A1A1B);
const Color _kSecondary = Color(0xFFC5A059);
const Color _kTertiary = Color(0xFF0052CC);
const Color _kNeutral = Color(0xFFF4F7F9);

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
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.initialIndex;
    _screens = [
      const DirectoryHomeScreen(),
      DirectoryExploreScreen(
        categoryId: widget.categoryId ?? '',
        categoryName: widget.categoryName ?? 'Explore',
      ),
      const DirectorySavedScreen(),
      const SizedBox(),
    ];
  }

  void _setPage(int pageIndex) {
    if (pageIndex == 3) {
      Get.bottomSheet(const MenuScreen(), backgroundColor: Colors.transparent, isScrollControlled: true);
    } else {
      setState(() {
        _pageIndex = pageIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.4, 0.8, 1.0],
            colors: [
              Color(0xFFFFFFFF), // Pure white
              Color(0xFFFDFCF9), // Very subtle shimmer
              Color(0xFFF7F1E6), // Elegant glow
              Color(0xFFF0E4CE), // Deepest gold glow
            ],
          ),
        ),
        child: _screens[_pageIndex],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _kPrimary.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _kNeutral.withOpacity(0.5),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _navItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
                    _navItem(1, Icons.explore_outlined, Icons.explore_rounded, 'Explore'),
                    _navItem(2, Icons.bookmark_outline_rounded, Icons.bookmark_rounded, 'Saved'),
                    _navItem(3, Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData outlineIcon, IconData solidIcon, String label) {
    bool isSelected = _pageIndex == index;

    return GestureDetector(
      onTap: () => _setPage(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: isSelected 
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _kPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _kPrimary.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? solidIcon : outlineIcon,
              size: 20,
              color: isSelected ? Colors.white : Colors.grey[400],
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: robotoBold.copyWith(fontSize: 12, color: Colors.white),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
