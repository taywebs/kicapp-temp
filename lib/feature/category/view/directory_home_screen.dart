import 'dart:ui';
import 'package:demandium/helper/route_helper.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';
import 'package:demandium/feature/category/controller/directory_controller.dart';
import 'package:demandium/feature/category/model/directory_model.dart';
import 'package:demandium/feature/category/view/directory_explore_screen.dart';
import 'package:demandium/feature/category/view/directory_details_screen.dart';
import 'package:demandium/feature/home/controller/banner_controller.dart';
import 'package:demandium/feature/category/controller/category_controller.dart';
import 'package:demandium/feature/category/widget/directory_transition_dialog.dart';

// Brand Colors
const Color _kPrimary = Color(0xFF1A1A1B);
const Color _kSecondary = Color(0xFFC5A059);
const Color _kTertiary = Color(0xFF0052CC);
const Color _kNeutral = Color(0xFFF4F7F9);

class DirectoryHomeScreen extends StatefulWidget {
  const DirectoryHomeScreen({super.key});

  @override
  State<DirectoryHomeScreen> createState() => _DirectoryHomeScreenState();
}

class _DirectoryHomeScreenState extends State<DirectoryHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  void initState() {
    super.initState();
    Get.find<DirectoryController>().getDirectoryList('1', '', true);
    Get.find<BannerController>().getBannerList(true);
    Get.find<CategoryController>().getCategoryList(true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    if (_searchController.text.trim().isEmpty) return;
    Get.to(() => DirectoryExploreScreen(
      categoryId: '',
      categoryName: 'Search: ${_searchController.text.trim()}',
      searchQuery: _searchController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kNeutral, // Light gray background matching the design
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ──── Header ────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => Get.toNamed(RouteHelper.getAccessLocationRoute('home')),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: _kPrimary, size: 24),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Your Location', style: robotoRegular.copyWith(fontSize: 11, color: Colors.grey[600])),
                              Text('Downtown Dubai', style: robotoBold.copyWith(fontSize: 13, color: _kPrimary)),
                            ],
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down_rounded, color: _kPrimary, size: 18),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                         Get.toNamed(RouteHelper.getNotificationRoute());
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.5),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                              ],
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(Icons.notifications_none_rounded, color: _kPrimary, size: 24),
                                Positioned(
                                  top: 1,
                                  right: 2,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 1.5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ──── Search Bar ────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  padding: const EdgeInsets.only(left: 14, right: 6),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, color: Colors.grey[400], size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search for KIC services, food,',
                            hintStyle: robotoRegular.copyWith(color: Colors.grey[400], fontSize: 13),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _performSearch(),
                        ),
                      ),
                      GestureDetector(
                        onTap: _performSearch,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('Find', style: robotoBold.copyWith(color: Colors.white, fontSize: 13)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ──── KIC Services (Asymmetric Grid) ────
              GestureDetector(
                onTap: () {
                  Get.dialog(DirectoryTransitionDialog(
                    isEnteringDirectory: false,
                    onConfirm: () => Get.offAllNamed(RouteHelper.getInitialRoute()),
                  ));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('KIC Services', style: robotoBold.copyWith(fontSize: 17, color: _kPrimary)),
                          Row(
                            children: [
                              Text('See all', style: robotoMedium.copyWith(color: Colors.grey[600], fontSize: 13)),
                              Icon(Icons.chevron_right_rounded, color: Colors.grey[600], size: 16),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        height: 240,
                  child: Row(
                    children: [
                      // Left large card
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: const DecorationImage(
                              image: NetworkImage('https://images.unsplash.com/photo-1581578731548-c64695cc6952?q=80&w=600&auto=format&fit=crop'), // Placeholder for cleaning
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            alignment: Alignment.bottomLeft,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Keep It Clean', style: robotoBold.copyWith(color: Colors.white, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('Professional Deep Cleaning', style: robotoRegular.copyWith(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Right column
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            // Top horizontal card
                            Expanded(
                              flex: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: const DecorationImage(
                                    image: NetworkImage('https://images.unsplash.com/photo-1582735689369-4fe89db7114c?q=80&w=600&auto=format&fit=crop'), // Placeholder laundry
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  alignment: Alignment.bottomLeft,
                                  child: Text('Laundry & Care', style: robotoBold.copyWith(color: Colors.white, fontSize: 13)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Bottom two square cards
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey[300],
                                        borderRadius: BorderRadius.circular(20),
                                        image: const DecorationImage(
                                          image: NetworkImage('https://images.unsplash.com/photo-1584820927498-cafe2c1c6a63?q=80&w=400&auto=format&fit=crop'), // Placeholder disinfect
                                          fit: BoxFit.cover,
                                          colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text('Disinfect', style: robotoBold.copyWith(color: Colors.white, fontSize: 12)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.auto_awesome, color: _kPrimary, size: 24),
                                          const SizedBox(height: 8),
                                          Text('Specialist', style: robotoBold.copyWith(color: _kPrimary, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

              // ──── Explore Categories ────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Explore Categories', style: robotoBold.copyWith(fontSize: 17, color: _kPrimary)),
              ),
              const SizedBox(height: 16),
              GetBuilder<CategoryController>(builder: (categoryController) {
                if (categoryController.categoryList == null) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: _kTertiary)),
                  );
                }
                List<CategoryModel> directoryCategories = categoryController.categoryList!
                    .where((c) => c.categoryType == 'directory_listing').toList();

                if (directoryCategories.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 0.82,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: directoryCategories.length > 8 ? 8 : directoryCategories.length,
                    itemBuilder: (context, index) {
                      CategoryModel category = directoryCategories[index];
                      
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => DirectoryExploreScreen(
                            categoryId: category.id ?? '',
                            categoryName: category.name ?? '',
                          ));
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 60, height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                                ],
                              ),
                              child: Center(
                                child: SizedBox(
                                  width: 32, height: 32,
                                  child: CustomImage(
                                    image: category.imageFullPath ?? '', 
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              category.name ?? '',
                              style: robotoMedium.copyWith(fontSize: 11, color: _kPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }),
              const SizedBox(height: 32),

              // ──── Curated for You ────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Curated for You', style: robotoBold.copyWith(fontSize: 17, color: _kPrimary)),
              ),
              const SizedBox(height: 16),
              GetBuilder<DirectoryController>(builder: (directoryController) {
                if (directoryController.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: _kTertiary)),
                  );
                }
                if (directoryController.directoryList == null || directoryController.directoryList!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text('No listings yet', style: robotoRegular.copyWith(color: Colors.grey[400])),
                    ),
                  );
                }

                return SizedBox(
                  height: 270,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: directoryController.directoryList!.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return _buildCuratedCard(directoryController.directoryList![index]);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCuratedCard(DirectoryModel directory) {
    String imageUrl = '';
    if (directory.imagesFullPath != null && directory.imagesFullPath!.isNotEmpty) {
      imageUrl = directory.imagesFullPath!.first;
    } else if (directory.coverImageFullPath != null && directory.coverImageFullPath!.isNotEmpty) {
      imageUrl = directory.coverImageFullPath!;
    }

    return GestureDetector(
      onTap: () {
        Get.to(() => DirectoryDetailsScreen(
          directoryId: directory.id ?? '',
          categoryName: directory.category?['name'] ?? 'Listing',
          initialModel: directory,
        ));
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: CustomImage(
                  image: imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          directory.title ?? '',
                          style: robotoBold.copyWith(fontSize: 15, color: _kPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _kNeutral,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              (directory.averageRating ?? 0).toStringAsFixed(1),
                              style: robotoMedium.copyWith(fontSize: 12, color: _kPrimary),
                            ),
                            const SizedBox(width: 3),
                            const Icon(Icons.star_rounded, size: 14, color: _kPrimary),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    directory.category?['name'] ?? 'Specialty',
                    style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Free Delivery', style: robotoMedium.copyWith(fontSize: 11, color: Colors.grey[700])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: CircleAvatar(radius: 2, backgroundColor: Colors.grey[400]),
                      ),
                      Text('15-20 min', style: robotoRegular.copyWith(fontSize: 11, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
