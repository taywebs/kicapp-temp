import 'dart:ui';
import 'package:demandium/helper/route_helper.dart';
import 'package:demandium/utils/core_export.dart';
import 'dart:ui' as dart_ui;
import 'package:get/get.dart';
import 'package:demandium/feature/category/controller/directory_controller.dart';
import 'package:demandium/feature/category/model/directory_model.dart';
import 'package:demandium/feature/category/view/directory_explore_screen.dart';
import 'package:demandium/feature/category/view/directory_details_screen.dart';
import 'package:demandium/feature/home/controller/banner_controller.dart';
import 'package:demandium/feature/category/controller/category_controller.dart';
import 'package:demandium/feature/category/widget/directory_transition_dialog.dart';
import 'package:demandium/feature/location/controller/location_controller.dart';

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
      backgroundColor: Colors.transparent, // Inherit gradient from main screen
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: const Color(0xFFE8E0D0), width: 0.8),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_rounded, color: _kSecondary, size: 15),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Your Location', style: robotoRegular.copyWith(fontSize: 9, color: Colors.grey[400])),
                                GetBuilder<LocationController>(builder: (locationController) {
                                  return SizedBox(
                                    width: 130,
                                    child: Text(
                                      locationController.getUserAddress()?.address ?? 'Select Location',
                                      style: robotoMedium.copyWith(fontSize: 12, color: _kPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }),
                              ],
                            ),
                            const SizedBox(width: 2),
                            Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[400], size: 16),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                         Get.toNamed(RouteHelper.getNotificationRoute());
                      },
                      child: Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white, Color(0xFFF0ECE4)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.9), width: 1),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 5)),
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 2, offset: const Offset(0, 1)),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Center(child: Icon(Icons.notifications_none_rounded, color: _kPrimary, size: 24)),
                            Positioned(
                              top: 10,
                              right: 11,
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
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
                                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 2, offset: const Offset(0, 1)),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(color: Colors.grey.withOpacity(0.25), width: 1.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Text('See all', style: robotoMedium.copyWith(color: _kPrimary.withOpacity(0.85), fontSize: 11)),
                                      const SizedBox(width: 2),
                                      Icon(Icons.chevron_right_rounded, color: _kPrimary.withOpacity(0.85), size: 14),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
                            border: Border.all(color: const Color(0xFFE0D8C8).withOpacity(0.5), width: 1.2),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 5)),
                            ],
                              image: const DecorationImage(
                                image: NetworkImage('https://images.unsplash.com/photo-1601362840469-51e4d8d58785?q=80&w=600&auto=format&fit=crop'),
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
                                  border: Border.all(color: const Color(0xFFE0D8C8).withOpacity(0.5), width: 1.2),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 5)),
                                  ],
                                  image: const DecorationImage(
                                    image: NetworkImage('https://images.unsplash.com/photo-1582735689369-4fe89db7114c?q=80&w=600&auto=format&fit=crop'),
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
                                        color: Colors.blueGrey[800],
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: const Color(0xFFE0D8C8).withOpacity(0.5), width: 1.2),
                                        boxShadow: [
                                          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 5)),
                                        ],
                                        image: const DecorationImage(
                                          image: NetworkImage('https://images.unsplash.com/photo-1520340356584-f9917d1eea6f?q=80&w=400&auto=format&fit=crop'),
                                          fit: BoxFit.cover,
                                          colorFilter: ColorFilter.mode(Colors.black38, BlendMode.darken),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text('Mobile Wash', style: robotoBold.copyWith(color: Colors.white, fontSize: 12)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: const Color(0xFFE0D8C8).withOpacity(0.5), width: 1.2),
                                        boxShadow: [
                                          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 5)),
                                        ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.ac_unit_rounded, color: _kSecondary, size: 24),
                                          const SizedBox(height: 8),
                                          Text('AC Repair', style: robotoBold.copyWith(color: _kPrimary, fontSize: 12)),
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
                      childAspectRatio: 0.70,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
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
                              width: 86, height: 86,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.white, Color(0xFFE5E7EB)], // 3D bevel effect
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08), 
                                    blurRadius: 12, 
                                    offset: const Offset(0, 6)
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03), 
                                    blurRadius: 2, 
                                    offset: const Offset(0, 2)
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1.0),
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 55, height: 55,
                                    child: CustomImage(
                                      image: category.imageFullPath ?? '', 
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category.name ?? '',
                              style: robotoMedium.copyWith(fontSize: 12, color: _kPrimary),
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
                  height: 310,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), // Added vertical padding for shadow
                    itemCount: directoryController.directoryList!.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return _buildCuratedCard(directoryController.directoryList![index]);
                    },
                  ),
                );
              }),
              const SizedBox(height: 36),

              // ──── Featured Listings ────
              _buildSectionHeader('Featured Listings'),
              const SizedBox(height: 16),
              _buildFeaturedListings(),
              const SizedBox(height: 36),

              // ──── Popular Businesses ────
              _buildSectionHeader('Popular Businesses'),
              const SizedBox(height: 16),
              _buildPopularBusinesses(),
              const SizedBox(height: 100), // Bottom padding for navbar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: robotoBold.copyWith(fontSize: 17, color: _kPrimary)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey.withOpacity(0.25), width: 1.0),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 2, offset: const Offset(0, 1)),
              ],
            ),
            child: Row(
              children: [
                Text('See all', style: robotoMedium.copyWith(color: _kPrimary.withOpacity(0.85), fontSize: 11)),
                const SizedBox(width: 2),
                Icon(Icons.chevron_right_rounded, color: _kPrimary.withOpacity(0.85), size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedListings() {
    return GetBuilder<DirectoryController>(builder: (ctrl) {
      final listings = ctrl.directoryList ?? [];
      if (listings.isEmpty) {
        return const SizedBox(height: 180);
      }
      // Show up to 5 featured listings
      final featured = listings.take(5).toList();
      return SizedBox(
        height: 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: featured.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final d = featured[index];
            final imgUrl = d.coverImageFullPath ?? d.bannerUrl ?? '';
            final categoryName = d.category?['name'] ?? 'Business';
            final rating = d.averageRating ?? 0.0;

            return GestureDetector(
              onTap: () => Get.to(() => DirectoryDetailsScreen(
                directoryId: d.id ?? '',
                categoryName: categoryName,
                initialModel: d,
              )),
              child: Container(
                width: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE0D8C8).withOpacity(0.5), width: 1),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 6)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      imgUrl.isNotEmpty
                        ? CustomImage(image: imgUrl, fit: BoxFit.cover)
                        : Container(color: const Color(0xFFF0F0F0), child: Icon(Icons.storefront_rounded, size: 50, color: Colors.grey[300])),
                      // Gradient overlay
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.3, 1.0],
                            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                          ),
                        ),
                      ),
                      // Category badge
                      Positioned(
                        top: 14, left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC5A059),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(categoryName, style: robotoBold.copyWith(color: Colors.white, fontSize: 11)),
                        ),
                      ),
                      // Rating badge
                      if (rating > 0)
                        Positioned(
                          top: 14, right: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, size: 13, color: Color(0xFFC5A059)),
                                const SizedBox(width: 3),
                                Text(rating.toStringAsFixed(1), style: robotoBold.copyWith(fontSize: 12, color: _kPrimary)),
                              ],
                            ),
                          ),
                        ),
                      // Title + location
                      Positioned(
                        bottom: 14, left: 14, right: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.title ?? 'Business', style: robotoBold.copyWith(color: Colors.white, fontSize: 17)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 12, color: Colors.white70),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Text(d.city ?? d.address ?? '', style: robotoRegular.copyWith(color: Colors.white70, fontSize: 12), overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildPopularBusinesses() {
    return GetBuilder<DirectoryController>(builder: (ctrl) {
      final listings = ctrl.directoryList ?? [];
      if (listings.isEmpty) {
        return const SizedBox(height: 120);
      }
      // Sort by rating and show top businesses
      final sorted = List<DirectoryModel>.from(listings)
        ..sort((a, b) => (b.averageRating ?? 0).compareTo(a.averageRating ?? 0));
      final top = sorted.take(6).toList();

      return SizedBox(
        height: 120,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: top.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final d = top[index];
            final imgUrl = d.coverImageFullPath ?? d.bannerUrl ?? '';
            final rating = d.averageRating ?? 0.0;

            return GestureDetector(
              onTap: () => Get.to(() => DirectoryDetailsScreen(
                directoryId: d.id ?? '',
                categoryName: d.category?['name'] ?? 'Business',
                initialModel: d,
              )),
              child: Container(
                width: 260,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE0D8C8).withOpacity(0.5), width: 1),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 5)),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 70, height: 70,
                        child: imgUrl.isNotEmpty
                          ? CustomImage(image: imgUrl, fit: BoxFit.cover)
                          : Container(color: const Color(0xFFF0F0F0), child: Icon(Icons.storefront_rounded, size: 30, color: Colors.grey[300])),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(d.title ?? 'Business', style: robotoBold.copyWith(fontSize: 14, color: _kPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 3),
                          Text(d.category?['name'] ?? '', style: robotoRegular.copyWith(fontSize: 11, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 14, color: Color(0xFFC5A059)),
                              const SizedBox(width: 3),
                              Text(rating > 0 ? rating.toStringAsFixed(1) : 'New', style: robotoMedium.copyWith(fontSize: 12, color: _kPrimary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _kNeutral,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: _kPrimary),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildCuratedCard(DirectoryModel directory) {
    String imageUrl = '';
    if (directory.imagesFullPath != null && directory.imagesFullPath!.isNotEmpty) {
      imageUrl = directory.imagesFullPath!.first;
    } else if (directory.coverImageFullPath != null && directory.coverImageFullPath!.isNotEmpty) {
      imageUrl = directory.coverImageFullPath!;
    } else if (directory.thumbnail != null && directory.thumbnail!.isNotEmpty) {
      imageUrl = directory.thumbnail!;
    }

    final Map dynMap = (directory.dynamicData is Map) ? (directory.dynamicData as Map) : {};
    final bool hasFreeDelivery = dynMap['free_delivery'] == 1 || dynMap['free_delivery'] == '1' || dynMap['free_delivery'] == true;
    final bool hasFastDelivery = dynMap['fast_delivery'] == 1 || dynMap['fast_delivery'] == '1' || dynMap['fast_delivery'] == true;
    final String deliveryTime = dynMap['delivery_time']?.toString() ?? '';

    return GestureDetector(
      onTap: () {
        Get.to(() => DirectoryDetailsScreen(
          directoryId: directory.id ?? '',
          categoryName: directory.category?['name'] ?? 'Listing',
          initialModel: directory,
        ));
      },
      child: Container(
        width: 290,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFFF9FAFB)],
          ),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            // Soft ambient shadow
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 12)),
            // Direct light shadow
            BoxShadow(color: const Color(0xFFC5A059).withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 4)),
            // Top highlight (Bevel effect)
            const BoxShadow(color: Colors.white, blurRadius: 4, offset: Offset(-2, -2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Glassmorphism Badges
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(22),
                      topRight: Radius.circular(22),
                    ),
                    child: CustomImage(
                      image: imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
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
                          style: robotoBold.copyWith(fontSize: 17, color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)]),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              (directory.averageRating ?? 0).toStringAsFixed(1),
                              style: robotoBold.copyWith(fontSize: 13, color: const Color(0xFFD97706)),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    directory.category?['name'] ?? 'Specialty',
                    style: robotoMedium.copyWith(fontSize: 14, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (deliveryTime.isNotEmpty || hasFastDelivery || hasFreeDelivery) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        if (deliveryTime.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer_rounded, size: 12, color: Colors.grey[500]),
                              const SizedBox(width: 2),
                              Text(
                                deliveryTime,
                                style: robotoMedium.copyWith(fontSize: 10, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        if (hasFastDelivery)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFFDE68A)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const _SpeedingIcon(icon: Icons.two_wheeler_rounded, color: Color(0xFFD97706)),
                                const SizedBox(width: 2),
                                Text('Fast Delivery', style: robotoBold.copyWith(fontSize: 9, color: Color(0xFFD97706))),
                              ],
                            ),
                          ),
                        if (hasFreeDelivery)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF86EFAC)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_shipping_rounded, size: 10, color: Color(0xFF059669)),
                                const SizedBox(width: 2),
                                Text('Free Delivery', style: robotoBold.copyWith(fontSize: 9, color: Color(0xFF059669))),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeedingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  const _SpeedingIcon({required this.icon, required this.color});

  @override
  State<_SpeedingIcon> createState() => _SpeedingIconState();
}

class _SpeedingIconState extends State<_SpeedingIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -1.5, end: 1.5).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: Icon(widget.icon, size: 14, color: widget.color),
        );
      },
    );
  }
}
