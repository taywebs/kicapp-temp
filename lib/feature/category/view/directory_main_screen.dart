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
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            stops: [0.0, 0.6, 1.0],
            colors: [
              Color(0xFFFFFFFF), // Pure white
              Color(0xFFFDFBF7), // Extremely subtle hint of gold
              Color(0xFFF5EFE1), // Soft, elegant light gold tint
            ],
          ),
        ),
        child: _screens[_pageIndex],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: _kPrimary.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: _kNeutral,
                    width: 1.5,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFD57A) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isSelected ? solidIcon : outlineIcon,
              size: 24,
              color: isSelected ? _kPrimary : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: isSelected 
              ? robotoBold.copyWith(fontSize: 10, color: _kPrimary)
              : robotoRegular.copyWith(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
