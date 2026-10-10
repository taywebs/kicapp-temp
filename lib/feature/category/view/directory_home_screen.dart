import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:demandium/utils/core_export.dart';
import 'package:demandium/helper/route_helper.dart';
import 'package:demandium/common/widgets/dir_ui.dart';
import 'package:demandium/feature/category/controller/directory_controller.dart';
import 'package:demandium/feature/category/model/directory_model.dart';
import 'package:demandium/feature/category/view/directory_details_screen.dart';
import 'package:demandium/feature/category/view/directory_explore_screen.dart';

/// Home tab of the Directory.
///
/// Two bands of content:
///  - "KIC Services": the bookable service categories. Any tap here hands the
///    user over to the Demandium service app.
///  - "Explore Categories" + "Curated for You": directory listings, which stay
///    inside the Directory.
class DirectoryHomeScreen extends StatefulWidget {
  const DirectoryHomeScreen({super.key});

  @override
  State<DirectoryHomeScreen> createState() => _DirectoryHomeScreenState();
}

class _DirectoryHomeScreenState extends State<DirectoryHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Get.find<DirectoryController>().getDirectoryList('1', '', true);
    Get.find<CategoryController>().getCategoryList(true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final String query = _searchController.text.trim();
    if (query.isEmpty) return;
    Get.to(() => DirectoryExploreScreen(
          categoryId: '',
          categoryName: query,
          searchQuery: query,
        ));
  }

  /// Straight into the Demandium service app — no confirmation dialog.
  void _openServiceApp() => Get.toNamed(RouteHelper.getMainRoute('home'));

  void _openCategory(CategoryModel category) {
    Get.to(() => DirectoryExploreScreen(
          categoryId: category.id ?? '',
          categoryName: category.name ?? '',
        ));
  }

  void _openListing(DirectoryModel listing) {
    if (listing.id == null || listing.id!.isEmpty) return;
    Get.to(() => DirectoryDetailsScreen(
          directoryId: listing.id!,
          categoryName: listing.category?['name']?.toString() ?? '',
          initialModel: listing,
        ));
  }

  List<CategoryModel> _serviceCategories(CategoryController c) =>
      (c.categoryList ?? <CategoryModel>[])
          .where((CategoryModel e) => e.categoryType != 'directory_listing')
          .toList();

  List<CategoryModel> _directoryCategories(CategoryController c) =>
      (c.categoryList ?? <CategoryModel>[])
          .where((CategoryModel e) => e.categoryType == 'directory_listing')
          .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DirTokens.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: DirTokens.primary,
          onRefresh: () async {
            await Get.find<CategoryController>().getCategoryList(true);
            await Get.find<DirectoryController>().getDirectoryList('1', '', true);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              SliverToBoxAdapter(
                child: _TopBar(
                  onLocationTap: () => Get.toNamed(RouteHelper.getAccessLocationRoute('home')),
                ),
              ),
              SliverToBoxAdapter(
                child: _SearchBar(controller: _searchController, onSubmit: _performSearch),
              ),
              SliverToBoxAdapter(
                child: GetBuilder<CategoryController>(
                  builder: (CategoryController categoryController) {
                    final bool loading = categoryController.categoryList == null;
                    final List<CategoryModel> services = _serviceCategories(categoryController);
                    final List<CategoryModel> directories = _directoryCategories(categoryController);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (loading || services.isNotEmpty) ...<Widget>[
                          _SectionHeader(
                            title: 'kic_services'.tr,
                            actionLabel: 'see_all'.tr,
                            onAction: _openServiceApp,
                          ),
                          _ServicesBento(
                            categories: services,
                            isLoading: loading,
                            onTap: (_) => _openServiceApp(),
                          ),
                          const SizedBox(height: 22),
                        ],
                        if (loading || directories.isNotEmpty) ...<Widget>[
                          _SectionHeader(title: 'explore_categories'.tr),
                          _CategoryGrid(
                            categories: directories,
                            isLoading: loading,
                            onTap: _openCategory,
                            onMoreTap: () => Get.to(() => DirectoryExploreScreen(
                                  categoryId: '',
                                  categoryName: 'explore'.tr,
                                )),
                          ),
                          const SizedBox(height: 22),
                        ],
                      ],
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: GetBuilder<DirectoryController>(
                  builder: (DirectoryController directoryController) {
                    final List<DirectoryModel> listings =
                        directoryController.directoryList ?? <DirectoryModel>[];
                    if (directoryController.isLoading && listings.isEmpty) {
                      return const _CuratedSkeleton();
                    }
                    if (listings.isEmpty) return const SizedBox.shrink();
                    final int count = listings.length > 10 ? 10 : listings.length;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _SectionHeader(title: 'curated_for_you'.tr),
                        SizedBox(
                          height: 244,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            itemCount: count,
                            separatorBuilder: (BuildContext _, int __) => const SizedBox(width: 14),
                            itemBuilder: (BuildContext context, int index) => _CuratedCard(
                              listing: listings[index],
                              onTap: () => _openListing(listings[index]),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── top bar ───────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onLocationTap});

  final VoidCallback onLocationTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      color: DirTokens.surfaceLow,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: <Widget>[
          Expanded(
            child: InkWell(
              onTap: onLocationTap,
              borderRadius: BorderRadius.circular(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.location_on_outlined, size: 18, color: DirTokens.primary),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('your_location'.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11,
                                height: 1.2,
                                fontWeight: FontWeight.w600,
                                color: DirTokens.onSurfaceVariant)),
                        GetBuilder<LocationController>(
                          builder: (LocationController locationController) => Text(
                            locationController.getUserAddress()?.address ?? 'select_location'.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12.5,
                                height: 1.3,
                                fontWeight: FontWeight.w700,
                                color: DirTokens.onSurface),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              AppConstants.appName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w700, color: DirTokens.primary),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => Get.toNamed(RouteHelper.getSearchResultRoute()),
              icon: const Icon(Icons.search, size: 22, color: DirTokens.primary),
              tooltip: 'search'.tr,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── search ───────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onSubmit});

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[DirTokens.surfaceLow, DirTokens.background],
        ),
      ),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: DirTokens.surface,
          borderRadius: BorderRadius.circular(DirTokens.radius),
          border: Border.all(color: DirTokens.outlineVariant),
        ),
        child: Row(
          children: <Widget>[
            const SizedBox(width: 12),
            const Icon(Icons.search, size: 20, color: DirTokens.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.search,
                onSubmitted: (String _) => onSubmit(),
                style: const TextStyle(fontSize: 14, color: DirTokens.onSurface),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'search_hint'.tr,
                  hintMaxLines: 1,
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF8A8F96)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(7),
              child: SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DirTokens.primary,
                    foregroundColor: DirTokens.onPrimary,
                    elevation: 0,
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('find'.tr,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── section header ───────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700, color: DirTokens.onSurface)),
          ),
          if (actionLabel != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(actionLabel!,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600, color: DirTokens.secondary)),
                    Icon(rtl ? Icons.chevron_left : Icons.chevron_right,
                        size: 17, color: DirTokens.secondary),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────── KIC services ───────────────────────────

/// Adapts to however many service categories the dashboard defines:
/// one fills the width, two split it, three or more use the bento layout.
class _ServicesBento extends StatelessWidget {
  const _ServicesBento({
    required this.categories,
    required this.isLoading,
    required this.onTap,
  });

  final List<CategoryModel> categories;
  final bool isLoading;
  final void Function(CategoryModel category) onTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: SizedBox(height: 180, child: _BlockSkeleton()),
      );
    }
    if (categories.isEmpty) return const SizedBox.shrink();

    final Widget specialist = _SpecialistTile(onTap: () => onTap(categories.first));

    if (categories.length == 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: SizedBox(
          height: 168,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: _BentoTile(
                  category: categories[0],
                  titleSize: 17,
                  onTap: () => onTap(categories[0]),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(child: specialist),
            ],
          ),
        ),
      );
    }

    if (categories.length == 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: SizedBox(
          height: 168,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: _BentoTile(
                  category: categories[0],
                  titleSize: 15,
                  onTap: () => onTap(categories[0]),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: _BentoTile(
                  category: categories[1],
                  titleSize: 15,
                  onTap: () => onTap(categories[1]),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(child: specialist),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: SizedBox(
        height: 286,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: _BentoTile(
                category: categories[0],
                titleSize: 18,
                subtitle: categories[0].description,
                onTap: () => onTap(categories[0]),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: _BentoTile(
                      category: categories[1],
                      titleSize: 13,
                      onTap: () => onTap(categories[1]),
                    ),
                  ),
                  const SizedBox(height: 11),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          child: _BentoTile(
                            category: categories[2],
                            titleSize: 11,
                            centerTitle: true,
                            onTap: () => onTap(categories[2]),
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(child: specialist),
                      ],
                    ),
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

class _BentoTile extends StatelessWidget {
  const _BentoTile({
    required this.category,
    required this.titleSize,
    required this.onTap,
    this.subtitle,
    this.centerTitle = false,
  });

  final CategoryModel category;
  final String? subtitle;
  final double titleSize;
  final bool centerTitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String title = category.name ?? '';
    return Material(
      color: DirTokens.surfaceHigh,
      borderRadius: BorderRadius.circular(DirTokens.radiusLarge),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CustomImage(image: category.imageFullPath ?? '', fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: <Color>[Color(0xCC000000), Color(0x00000000)],
                  stops: <double>[0, 0.7],
                ),
              ),
            ),
            if (centerTitle)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white, fontSize: titleSize, fontWeight: FontWeight.w700)),
                ),
              )
            else
              PositionedDirectional(
                start: 12,
                end: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white, fontSize: titleSize, fontWeight: FontWeight.w700)),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(subtitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 12)),
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

class _SpecialistTile extends StatelessWidget {
  const _SpecialistTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DirTokens.surface,
      borderRadius: BorderRadius.circular(DirTokens.radiusLarge),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.auto_awesome_outlined, size: 28, color: DirTokens.primary),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text('specialist'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11.5, fontWeight: FontWeight.w700, color: DirTokens.primary)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── categories ───────────────────────────

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.categories,
    required this.isLoading,
    required this.onTap,
    required this.onMoreTap,
  });

  final List<CategoryModel> categories;
  final bool isLoading;
  final void Function(CategoryModel category) onTap;
  final VoidCallback onMoreTap;

  /// Glyphs for the known directory categories; anything else falls back to a
  /// storefront icon, so a category added later still renders.
  static IconData iconFor(String? name) {
    final String n = (name ?? '').toLowerCase();
    if (n.contains('coffe') || n.contains('قهو')) return Icons.local_cafe_outlined;
    if (n.contains('dining') || n.contains('restaurant') || n.contains('مطعم') || n.contains('مطاعم')) {
      return Icons.restaurant_outlined;
    }
    if (n.contains('activit') || n.contains('نشاط')) return Icons.sports_handball_outlined;
    if (n.contains('grocer') || n.contains('بقال') || n.contains('تسوق')) {
      return Icons.shopping_basket_outlined;
    }
    if (n.contains('pharm') || n.contains('صيدل')) return Icons.medical_services_outlined;
    if (n.contains('clinic') || n.contains('عياد') || n.contains('طب')) {
      return Icons.local_hospital_outlined;
    }
    if (n.contains('elite') || n.contains('نخبة') || n.contains('مميز')) {
      return Icons.workspace_premium_outlined;
    }
    if (n.contains('wash') || n.contains('سيار')) return Icons.local_car_wash_outlined;
    return Icons.storefront_outlined;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: SizedBox(height: 170, child: _BlockSkeleton()),
      );
    }
    if (categories.isEmpty) return const SizedBox.shrink();

    final bool needsMore = categories.length > 7;
    final List<CategoryModel> shown = needsMore ? categories.sublist(0, 7) : categories;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: shown.length + (needsMore ? 1 : 0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 11,
          mainAxisSpacing: 11,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (BuildContext context, int index) {
          final bool isMore = index == shown.length;
          return _CategoryTile(
            label: isMore ? 'more'.tr : (shown[index].name ?? ''),
            icon: isMore ? Icons.grid_view_outlined : iconFor(shown[index].name),
            highlighted: !isMore && index == shown.length - 1,
            onTap: isMore ? onMoreTap : () => onTap(shown[index]),
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.icon,
    required this.highlighted,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Material(
            color: highlighted ? DirTokens.secondaryContainer : DirTokens.surfaceHigh,
            borderRadius: BorderRadius.circular(DirTokens.radiusLarge),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: AspectRatio(
                aspectRatio: 1,
                child: Icon(icon,
                    size: 26,
                    color: highlighted ? DirTokens.onSecondaryContainer : DirTokens.primary),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 11.5, fontWeight: FontWeight.w600, color: DirTokens.onSurfaceVariant)),
      ],
    );
  }
}

// ─────────────────────────── curated ───────────────────────────

class _CuratedCard extends StatelessWidget {
  const _CuratedCard({required this.listing, required this.onTap});

  final DirectoryModel listing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String subtitle =
        listing.category?['name']?.toString() ?? (listing.description ?? '');
    return SizedBox(
      width: 252,
      child: Material(
        color: DirTokens.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DirTokens.radiusLarge),
          side: const BorderSide(color: DirTokens.outlineVariant),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(DirTokens.radius),
                  child: SizedBox(
                    height: 142,
                    width: double.infinity,
                    child: CustomImage(image: listing.bannerUrl ?? '', fit: BoxFit.cover),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(7, 10, 7, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text(listing.title ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: DirTokens.onSurface)),
                          ),
                          if (listing.averageRating != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: DirTokens.surfaceHigh,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text('${listing.averageRating!.toStringAsFixed(1)} ★',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: DirTokens.onSurface)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11.5, color: DirTokens.onSurfaceVariant)),
                      const SizedBox(height: 7),
                      Row(
                        children: <Widget>[
                          if (listing.city != null && listing.city!.isNotEmpty) ...<Widget>[
                            Flexible(
                              child: Text(listing.city!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: DirTokens.secondary)),
                            ),
                            const _Dot(),
                          ],
                          Expanded(
                            child: Text(listing.address ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 11.5, color: DirTokens.onSurfaceVariant)),
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
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) => Container(
        width: 3,
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: const BoxDecoration(color: DirTokens.outlineVariant, shape: BoxShape.circle),
      );
}

// ─────────────────────────── skeletons ───────────────────────────

class _BlockSkeleton extends StatelessWidget {
  const _BlockSkeleton();

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: DirTokens.surfaceHigh,
          borderRadius: BorderRadius.circular(DirTokens.radiusLarge),
        ),
      );
}

class _CuratedSkeleton extends StatelessWidget {
  const _CuratedSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionHeader(title: 'curated_for_you'.tr),
        SizedBox(
          height: 244,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: 2,
            separatorBuilder: (BuildContext _, int __) => const SizedBox(width: 14),
            itemBuilder: (BuildContext _, int __) =>
                const SizedBox(width: 252, child: _BlockSkeleton()),
          ),
        ),
      ],
    );
  }
}
