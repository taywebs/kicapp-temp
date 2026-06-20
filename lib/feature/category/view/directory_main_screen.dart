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
          height: 72, // Reduced to give a tighter look
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // White Background Bar
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  height: 56, // Reduced height
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _kPrimary.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              // Navigation Items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0, Icons.home_rounded, Icons.home_rounded, 'Home'),
                  _buildNavItem(1, Icons.explore_rounded, Icons.explore_rounded, 'Explore'),
                  _buildNavItem(2, Icons.bookmark_rounded, Icons.bookmark_rounded, 'Saved'),
                  _buildNavItem(3, Icons.person_rounded, Icons.person_rounded, 'Profile'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlineIcon, IconData solidIcon, String label) {
    bool isSelected = _pageIndex == index;

    return GestureDetector(
      onTap: () => _setPage(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        height: 72, // Matches total height
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            // Inactive Icon
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 0.0 : 1.0,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15), // Centered vertically in the 56px white bar
                child: Icon(outlineIcon, color: Colors.grey[700], size: 26), // Darker and slightly larger
              ),
            ),
            // Active Capsule (Floating with fake cutout)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              bottom: isSelected ? 26 : -40, // Lowered active capsule
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _kPrimary,
                    borderRadius: BorderRadius.circular(24),
                    // Fake cutout border to exactly match screen background bottom gradient
                    border: Border.all(color: const Color(0xFFF0E4CE), width: 6),
                    boxShadow: [
                      BoxShadow(
                        color: _kPrimary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(solidIcon, color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        label,
                        style: robotoBold.copyWith(fontSize: 11, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
