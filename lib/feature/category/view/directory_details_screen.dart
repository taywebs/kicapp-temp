import 'package:demandium/utils/core_export.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:demandium/feature/category/controller/directory_controller.dart';
import 'package:demandium/feature/category/model/directory_model.dart';
import 'package:demandium/feature/category/view/directory_review_screen.dart';
import 'package:demandium/feature/category/view/directory_all_reviews_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';

// ─── Elegant React-like Brand Colors ────────────────────────
const Color _kPrimary   = Color(0xFF1A1A1B);
const Color _kGold      = Color(0xFFC5A059);
const Color _kBlue      = Color(0xFF0052CC);
const Color _kNeutral   = Color(0xFFF7F9FC);
const Color _kGoldLight = Color(0xFFFDF8EE);

class DirectoryDetailsScreen extends StatefulWidget {
  final String directoryId;
  final String categoryName;
  final DirectoryModel? initialModel;

  const DirectoryDetailsScreen({
    super.key,
    required this.directoryId,
    required this.categoryName,
    this.initialModel,
  });

  @override
  State<DirectoryDetailsScreen> createState() => _DirectoryDetailsScreenState();
}

class _DirectoryDetailsScreenState extends State<DirectoryDetailsScreen> {
  // ─── Local Saved / Bookmark using SharedPreferences ───
  static const String _savedKey = 'saved_directory_listings';
  static const String _savedModelsKey = 'saved_directory_models';
  final SharedPreferences _prefs = Get.find();

  bool _isSaved(String id) {
    final List<String> saved = _prefs.getStringList(_savedKey) ?? [];
    return saved.contains(id);
  }

  void _toggleSave(DirectoryModel d) {
    final String id = d.id ?? '';
    if (id.isEmpty) return;
    
    final List<String> savedIds = List.from(_prefs.getStringList(_savedKey) ?? []);
    final List<String> savedModelsStr = List.from(_prefs.getStringList(_savedModelsKey) ?? []);
    
    if (savedIds.contains(id)) {
      savedIds.remove(id);
      savedModelsStr.removeWhere((str) {
        try {
          final Map map = jsonDecode(str);
          return map['id'] == id;
        } catch(e) { return false; }
      });
      customSnackBar('Removed from saved', type: ToasterMessageType.error);
    } else {
      savedIds.add(id);
      savedModelsStr.add(jsonEncode(d.toJson()));
      customSnackBar('Saved successfully!', type: ToasterMessageType.success);
    }
    
    _prefs.setStringList(_savedKey, savedIds.cast<String>());
    _prefs.setStringList(_savedModelsKey, savedModelsStr.cast<String>());
    setState(() {});
  }

  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Get.find<DirectoryController>().getDirectoryDetails(widget.directoryId, initialModel: widget.initialModel);
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: GetBuilder<DirectoryController>(builder: (ctrl) {
        if (ctrl.isLoading && ctrl.directoryDetails == null) {
          // If we have an initialModel, show it while loading
          if (widget.initialModel != null) {
            // Will continue rendering with initialModel below
          } else {
            return const Center(child: CircularProgressIndicator(color: _kGold));
          }
        }

        if (ctrl.directoryDetails == null && widget.initialModel == null) {
          return _buildError(ctrl);
        }

        final DirectoryModel d = ctrl.directoryDetails ?? widget.initialModel!;
        final double rating = d.averageRating ?? 0.0;
        final int reviewCount = ctrl.ratingInfo?['review_count'] ?? 0;
        final List<dynamic> reviews = ctrl.reviewsList ?? [];
        final Map _outerDynMap = (d.dynamicData is Map) ? (d.dynamicData as Map) : {};
        final bool hasFreeDelivery = _outerDynMap['free_delivery'] == 1 || _outerDynMap['free_delivery'] == true || _outerDynMap['free_delivery'] == '1';

        return Stack(
          children: [
            CustomScrollView(
              controller: _scrollCtrl,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 240,
                  pinned: true,
                  elevation: 0,
                  leading: _glassCircleBtn(Icons.arrow_back_ios_new_rounded, () => Get.back(), size: 18),
                  actions: [
                    _favoriteBtn(d),
                    const SizedBox(width: 12),
                  ],
                  flexibleSpace: LayoutBuilder(
                    builder: (context, constraints) {
                      final double top = constraints.biggest.height;
                      final double statusBarH = MediaQuery.of(context).padding.top;
                      final bool isCollapsed = top <= kToolbarHeight + statusBarH + 10;
                      final Map dynMap = (d.dynamicData is Map) ? (d.dynamicData as Map) : {};
                      final bool hasFreeDelivery = dynMap['free_delivery'] == 1 || dynMap['free_delivery'] == true || dynMap['free_delivery'] == '1';
                      final String bannerImg = d.galleryFullPaths.isNotEmpty 
                          ? d.galleryFullPaths.first 
                          : (d.coverImageFullPath ?? d.bannerUrl ?? '');
                      
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          // ─── Background: Banner image with dark overlay (always present) ───
                          if (bannerImg.isNotEmpty)
                            CustomImage(image: bannerImg, fit: BoxFit.cover)
                          else
                            Container(color: _kPrimary),
                          // Dark overlay - stronger when collapsed
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            color: isCollapsed 
                              ? Colors.black.withOpacity(0.8)
                              : Colors.black.withOpacity(0.3),
                          ),
                          // ─── When expanded: show gallery slider ───
                          if (!isCollapsed)
                            FlexibleSpaceBar(
                              background: _GallerySlider(directory: d),
                            ),
                          // ─── When collapsed: show name in glass card ───
                          if (isCollapsed)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: statusBarH),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                                      ),
                                      child: Text(
                                        d.title ?? '',
                                        style: robotoBold.copyWith(fontSize: 15, color: Colors.white),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),

                // ─── Main Content ───
                SliverToBoxAdapter(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: _kNeutral,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ─── space for floating badge ───
                            if (hasFreeDelivery) const SizedBox(height: 22),
                            // ─── Header: Premium Glass-like Card ───
                            Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 12))
                            ],
                          ),
                          child: Column(
                            children: [
                              // Avatar, Title, Location, Rating
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Avatar
                                    Container(
                                      height: 75,
                                      width: 75,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.white,
                                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: _buildAvatar(d),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            d.title ?? 'Unnamed',
                                            style: robotoBold.copyWith(fontSize: 22, color: _kPrimary, height: 1.2),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on_rounded, color: Colors.grey, size: 14),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  d.address ?? d.city ?? 'Location N/A',
                                                  style: robotoMedium.copyWith(fontSize: 13, color: Colors.grey[700]),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          // Rating and Review Count
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: _kGoldLight,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: _kGold.withOpacity(0.3)),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.star_rounded, color: _kGold, size: 14),
                                                    const SizedBox(width: 4),
                                                    Text(rating.toStringAsFixed(1), style: robotoBold.copyWith(fontSize: 13, color: _kGold)),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '$reviewCount ${reviewCount == 1 ? 'Review' : 'Reviews'}',
                                                style: robotoMedium.copyWith(fontSize: 13, color: Colors.grey[600]),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Divider
                              Container(
                                height: 1,
                                width: double.infinity,
                                color: Colors.grey.withOpacity(0.1),
                              ),
                              // Action Buttons
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 17),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _actionBtn(Icons.directions_rounded, 'Direction', const Color(0xFF2563EB), () => _launchMaps(d.latitude, d.longitude)),
                                    _actionBtn(Icons.phone_rounded, 'Call', const Color(0xFF059669), () => _launchUrl('tel:${d.phone ?? ''}')),
                                    _actionBtn(Icons.language_rounded, 'Website', const Color(0xFF4F46E5), () => _launchUrl(d.website ?? '')),
                                    _actionBtn(Icons.rate_review_rounded, 'Review', const Color(0xFFD97706), () => Get.to(() => DirectoryReviewScreen(directoryId: d.id!, directoryTitle: d.title ?? ''))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ─── Extract Dynamic Data ───
                        Builder(
                          builder: (context) {
                            final Map dynamicMap = (d.dynamicData is Map) ? (d.dynamicData as Map) : {};
                            final Map<String, List> menuTabs = {};
                            final Map<String, dynamic> otherDynamicFields = {};

                            for (var entry in dynamicMap.entries) {
                              final val = entry.value;
                              final keyLower = entry.key.toString().toLowerCase();

                              if (val is Map) {
                                // Check if it's a menu (values are Lists)
                                bool isMenu = (val.values.every((v) => v is List));
                                if (isMenu || keyLower == 'menu') {
                                  for (var menuEntry in val.entries) {
                                    if (menuEntry.value is List) {
                                      menuTabs[menuEntry.key.toString()] = menuEntry.value as List;
                                    }
                                  }
                                } else {
                                  otherDynamicFields[entry.key.toString()] = val;
                                }
                              } else if (val is List) {
                                menuTabs[entry.key.toString()] = val;
                              } else {
                                otherDynamicFields[entry.key.toString()] = val;
                              }
                            }

                            final String currency = dynamicMap['currency']?.toString() ?? '\$';
                            final bool hasFreeDelivery = dynamicMap['free_delivery'] == 1 || dynamicMap['free_delivery'] == true || dynamicMap['free_delivery'] == '1';
                            final bool hasOnlinePayment = dynamicMap['online_payment'] == 1 || dynamicMap['online_payment'] == true || dynamicMap['online_payment'] == '1';
                            final bool hasCashOnDelivery = dynamicMap['cash_on_delivery'] == 1 || dynamicMap['cash_on_delivery'] == true || dynamicMap['cash_on_delivery'] == '1';
                            // Exclude internal keys from display
                            final Set<String> _hiddenKeys = {'currency', 'free_delivery', 'online_payment', 'cash_on_delivery'};
                            otherDynamicFields.removeWhere((k, v) => _hiddenKeys.contains(k));

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 1. Menu Tabs
                                if (menuTabs.isNotEmpty)
                                  _MenuTabsSection(menuTabs: menuTabs, currency: currency),

                                // 1b. Free Delivery badge: now inside slider → removed from here

                                // 1c. Payment Methods Card
                                if (hasOnlinePayment || hasCashOnDelivery)
                                  _sectionCard(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _sectionTitle('Payment Methods'),
                                        const SizedBox(height: 16),
                                        if (hasOnlinePayment) ...[
                                          Row(
                                            children: [
                                              const Icon(Icons.credit_card_rounded, color: Color(0xFF4F46E5), size: 20),
                                              const SizedBox(width: 10),
                                              Text('Online Payment', style: robotoBold.copyWith(fontSize: 14, color: _kPrimary)),
                                              const Spacer(),
                                              // Payment card icons
                                              _paymentBadge('VISA', const Color(0xFF1A1F71)),
                                              const SizedBox(width: 6),
                                              _paymentBadge('MC', const Color(0xFFEB001B)),
                                              const SizedBox(width: 6),
                                              _paymentBadge('AMEX', const Color(0xFF007BC1)),
                                            ],
                                          ),
                                          if (hasCashOnDelivery) const SizedBox(height: 12),
                                        ],
                                        if (hasCashOnDelivery)
                                          Row(
                                            children: [
                                              const Icon(Icons.payments_rounded, color: Color(0xFF059669), size: 20),
                                              const SizedBox(width: 10),
                                              Text('Cash on Delivery', style: robotoBold.copyWith(fontSize: 14, color: _kPrimary)),
                                              const Spacer(),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF059669).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: const Color(0xFF059669).withOpacity(0.3)),
                                                ),
                                                child: Text('Available', style: robotoBold.copyWith(fontSize: 12, color: const Color(0xFF059669))),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),

                                // 2. Features & Amenities
                                if (d.features != null && d.features!.isNotEmpty)
                                  _sectionCard(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _sectionTitle('Features & Amenities'),
                                        const SizedBox(height: 16),
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 12,
                                          children: d.features!.map((feature) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(color: Colors.grey.shade200),
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.check_circle_rounded, size: 18, color: _kGold),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    feature.toString(),
                                                    style: robotoMedium.copyWith(fontSize: 14, color: _kPrimary),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),

                                // 3. Working hours / Other dynamic fields — no section title
                                if (otherDynamicFields.isNotEmpty)
                                  _sectionCard(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ...otherDynamicFields.entries.map((entry) {
                                          return _renderDynamicField(entry.key.toString(), entry.value);
                                        }).toList(),
                                      ],
                                    ),
                                  ),
                              ],
                            );
                          }
                        ),

                        // 5. About
                        if (d.description != null && d.description!.isNotEmpty)
                          _sectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitle('About ${d.title}'),
                                const SizedBox(height: 12),
                                Text(
                                  d.description!,
                                  style: robotoRegular.copyWith(fontSize: 15, color: Colors.grey[700], height: 1.6),
                                ),
                              ],
                            ),
                          ),


                        // ─── Reviews Section ───
                        _sectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _sectionTitle('Reviews'),
                                  if (reviewCount > 2)
                                    InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () => Get.to(() => DirectoryAllReviewsScreen(
                                        directoryId: d.id!,
                                        directoryTitle: d.title!,
                                      )),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        child: Text(
                                          'View All',
                                          style: robotoBold.copyWith(fontSize: 14, color: _kBlue),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200, width: 1),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          rating.toStringAsFixed(1),
                                          style: robotoBold.copyWith(fontSize: 48, color: _kPrimary, height: 1.0),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(5, (i) => Icon(
                                            i < rating.floor()
                                                ? Icons.star_rounded
                                                : (i < rating ? Icons.star_half_rounded : Icons.star_outline_rounded),
                                            color: _kGold,
                                            size: 20,
                                          )),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Based on $reviewCount reviews',
                                          style: robotoMedium.copyWith(fontSize: 13, color: Colors.grey[500]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (reviews.isNotEmpty)
                                Column(
                                  children: reviews.take(2).map((r) => _reviewTile(r)).toList(),
                                )
                              else
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Text(
                                      'No reviews yet',
                                      style: robotoMedium.copyWith(fontSize: 15, color: Colors.grey[400]),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100), // Bottom padding
                        ],
                      ),
                    ),
                  ], // Stack (SliverToBoxAdapter) children end
                ), // Stack end
              ), // SliverToBoxAdapter end
            ], // slivers end
          ), // CustomScrollView end
            // ─── Free Delivery Badge ───
            if (hasFreeDelivery)
              AnimatedBuilder(
                animation: _scrollCtrl,
                builder: (ctx, _) {
                  final double statusH = MediaQuery.of(ctx).padding.top;
                  final double scrollOff = _scrollCtrl.hasClients ? _scrollCtrl.offset : 0;
                  final double badgeTop = statusH + 240 - 22 - scrollOff;
                  // Hide badge once it scrolls off top
                  if (badgeTop < statusH - 30) return const SizedBox.shrink();
                  return Positioned(
                    top: badgeTop,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF00C853).withOpacity(0.92),
                                  const Color(0xFF00897B).withOpacity(0.92),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.2),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFF00C853).withOpacity(0.5), blurRadius: 16, offset: const Offset(0, 6)),
                                BoxShadow(color: const Color(0xFF00C853).withOpacity(0.2), blurRadius: 4, spreadRadius: 2, offset: const Offset(0, 1)),
                                const BoxShadow(color: Colors.white, blurRadius: 2, spreadRadius: -1, offset: Offset(0, -1)),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 15),
                                const SizedBox(width: 8),
                                Text('Free Delivery', style: robotoBold.copyWith(fontSize: 12, color: Colors.white, letterSpacing: 0.3)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ], // outer Stack children end
        ); // outer Stack end
    }),
  );
}

  // ─── Helper Widgets ───

  Widget _paymentBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Text(label, style: robotoBold.copyWith(fontSize: 10, color: Colors.white, letterSpacing: 0.5)),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
          const BoxShadow(
            color: Colors.white,
            blurRadius: 4,
            spreadRadius: -2,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: robotoBold.copyWith(fontSize: 18, color: _kPrimary),
    );
  }

  Widget _actionBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Column(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: color.withOpacity(0.22), width: 1.5),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.14), blurRadius: 12, offset: const Offset(0, 5)),
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                const BoxShadow(color: Colors.white, blurRadius: 3, spreadRadius: -1, offset: Offset(0, -2)),
              ],
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 5),
          Text(label, style: robotoBold.copyWith(fontSize: 10, color: _kPrimary.withOpacity(0.75))),
        ],
      ),
    );
  }

  Widget _glassCircleBtn(IconData icon, VoidCallback onTap, {double size = 20}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(0.25),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Icon(icon, color: Colors.white, size: size),
        ),
      ),
    );
  }

  Widget _favoriteBtn(DirectoryModel d) {
    final bool saved = _isSaved(d.id ?? '');
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 0),
      child: InkWell(
        onTap: () => _toggleSave(d),
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: saved ? Colors.white : Colors.black.withOpacity(0.25),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: saved ? [
              BoxShadow(color: _kGold.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
            ] : null,
          ),
          child: Icon(
            saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: saved ? _kGold : Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(DirectoryModel d) {
    // Cover Image / Logo is stored as 'thumbnail' in DB, returned as 'cover_image_full_path' in API
    final String? coverPath = d.coverImageFullPath;
    final String? logoPath = d.logoUrl;
    final String? thumbPath = d.thumbnail;
    
    if (coverPath != null && coverPath.isNotEmpty && !coverPath.contains('placeholder')) {
      return CustomImage(image: coverPath, fit: BoxFit.cover, placeholder: Images.placeholder);
    } else if (logoPath != null && logoPath.isNotEmpty) {
      return CustomImage(image: logoPath, fit: BoxFit.cover, placeholder: Images.placeholder);
    } else if (thumbPath != null && thumbPath.isNotEmpty) {
      return CustomImage(image: thumbPath, fit: BoxFit.cover, placeholder: Images.placeholder);
    }
    return const Icon(Icons.storefront_rounded, size: 40, color: Colors.grey);
  }

  Widget _renderDynamicField(String key, dynamic val) {
    if (val == null || val.toString().isEmpty) return const SizedBox();

    String formattedKey = key.split('_').map((word) => word.capitalizeFirst).join(' ');

    // ─── Handle Map (e.g. Working Hours) ───
    if (val is List) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formattedKey, style: robotoBold.copyWith(fontSize: 16, color: _kPrimary)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: val.map((e) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: _kGold, size: 16),
                      const SizedBox(width: 8),
                      Text(e.toString(), style: robotoMedium.copyWith(fontSize: 13, color: Colors.grey[800])),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    } else if (val is Map) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: _kGoldLight, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.access_time_filled_rounded, size: 18, color: _kGold),
                ),
                const SizedBox(width: 12),
                Text(formattedKey, style: robotoBold.copyWith(fontSize: 16, color: _kPrimary)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)],
              ),
              child: Column(
                children: val.entries.map((e) {
                  String day = e.key.toString();
                  var data = e.value;
                  if (data is Map) {
                    bool active = data['active'] == '1' || data['active'] == 1 || data['active'] == true;
                    String timeStr = active ? '${data['start'] ?? ''} - ${data['end'] ?? ''}' : 'Closed';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(day, style: robotoMedium.copyWith(fontSize: 15, color: _kPrimary)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: active ? _kNeutral : Colors.red.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(timeStr, style: robotoMedium.copyWith(fontSize: 13, color: active ? _kBlue : Colors.red)),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                }).toList(),
              ),
            ),
          ],
        ),
      );
    } else if (key.toLowerCase().contains('working')) {
      // If working hours came back as a string, display it safely
      return Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: _kGoldLight, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.access_time_filled_rounded, size: 18, color: _kGold),
                ),
                const SizedBox(width: 12),
                Text(formattedKey, style: robotoBold.copyWith(fontSize: 16, color: _kPrimary)),
              ],
            ),
            const SizedBox(height: 16),
            Text(val.toString(), style: robotoMedium.copyWith(fontSize: 14, color: Colors.grey[700])),
          ],
        ),
      );
    }

    // ─── Handle Standard Text ───
    String strVal = val.toString();
    if (strVal == '1' || strVal == '0') {
      strVal = strVal == '1' ? 'Yes' : 'No';
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _kNeutral, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.info_outline_rounded, size: 18, color: _kBlue),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formattedKey, style: robotoMedium.copyWith(fontSize: 13, color: Colors.grey[500])),
                const SizedBox(height: 4),
                Text(strVal, style: robotoBold.copyWith(fontSize: 15, color: _kPrimary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewTile(dynamic r) {
    String comment = r['review_comment'] ?? '';
    double rat = r['review_rating'] != null ? double.tryParse(r['review_rating'].toString()) ?? 0 : 0;
    String name = r['customer'] != null ? '${r['customer']['first_name']} ${r['customer']['last_name']}' : 'Anonymous';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: robotoBold.copyWith(fontSize: 15, color: _kPrimary)),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: _kGold, size: 14),
                  const SizedBox(width: 4),
                  Text(rat.toStringAsFixed(1), style: robotoBold.copyWith(fontSize: 13, color: _kGold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(comment, style: robotoRegular.copyWith(fontSize: 14, color: Colors.grey[600], height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildError(DirectoryController ctrl) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text('Failed to load details', style: robotoMedium.copyWith(fontSize: 16, color: _kPrimary)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ctrl.getDirectoryDetails(widget.directoryId),
            style: ElevatedButton.styleFrom(backgroundColor: _kPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: Text('Retry', style: robotoMedium.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    try {
      final Uri uri = Uri.parse(!url.startsWith('http') && !url.startsWith('tel:') ? 'https://$url' : url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        customSnackBar('Could not launch URL');
      }
    } catch (_) {
      customSnackBar('Invalid URL');
    }
  }

  Future<void> _launchMaps(String? lat, String? lng) async {
    if (lat == null || lng == null) return;
    final Uri uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      customSnackBar('Could not open maps');
    }
  }
}

class _GallerySlider extends StatefulWidget {
  final DirectoryModel directory;
  const _GallerySlider({required this.directory});

  @override
  State<_GallerySlider> createState() => _GallerySliderState();
}

class _GallerySliderState extends State<_GallerySlider> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> images = widget.directory.galleryFullPaths;
    
    // Fallback if no gallery images, use single cover
    if (images.isEmpty) {
      return _buildStaticCover(widget.directory.bannerUrl ?? '');
    }

    // If only one image in gallery, don't show slider, just static cover
    if (images.length == 1) {
      return _buildStaticCover(images[0]);
    }

    // Multiple images -> Slider
    return Stack(
      fit: StackFit.expand,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: double.infinity,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: images.map((img) {
            return Builder(
              builder: (BuildContext context) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: CustomImage(
                    image: img,
                    fit: BoxFit.cover,
                    placeholder: Images.placeholder,
                  ),
                );
              },
            );
          }).toList(),
        ),
        // Premium Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.transparent,
                Colors.black.withOpacity(0.4),
              ],
            ),
          ),
        ),
        // Dots Indicator
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: images.asMap().entries.map((entry) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.white)
                      .withOpacity(_currentIndex == entry.key ? 0.9 : 0.4),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  Widget _buildStaticCover(String url) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomImage(
          image: url,
          fit: BoxFit.cover,
          placeholder: Images.placeholder,
        ),
        // Premium Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.transparent,
                Colors.black.withOpacity(0.4),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuTabsSection extends StatefulWidget {
  final Map<String, List> menuTabs;
  final String currency;
  const _MenuTabsSection({required this.menuTabs, required this.currency});

  @override
  State<_MenuTabsSection> createState() => _MenuTabsSectionState();
}

class _MenuTabsSectionState extends State<_MenuTabsSection> {
  int _selectedIndex = 0;

  Widget _buildPriceText(String currency, String price, double fontSize, Color color) {
    if (currency == 'AED') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Custom UAE Dirham Symbol
          SizedBox(
            height: fontSize * 1.2,
            width: fontSize * 0.85,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text('D', style: robotoBold.copyWith(fontSize: fontSize, color: color, height: 1)),
                Positioned(
                  top: fontSize * 0.50,
                  left: 0,
                  right: fontSize * 0.15,
                  child: Container(height: fontSize * 0.1, color: color),
                ),
                Positioned(
                  top: fontSize * 0.70,
                  left: 0,
                  right: fontSize * 0.15,
                  child: Container(height: fontSize * 0.1, color: color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Text(price, style: robotoBold.copyWith(fontSize: fontSize, color: color)),
        ],
      );
    }
    return Text('$currency$price', style: robotoBold.copyWith(fontSize: fontSize, color: color));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.menuTabs.isEmpty) return const SizedBox();

    List<String> tabKeys = widget.menuTabs.keys.toList();
    List items = widget.menuTabs[tabKeys[_selectedIndex]] ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Tabs ───
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              itemCount: tabKeys.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                bool isSelected = _selectedIndex == index;
                String title = tabKeys[index].split('_').map((word) => word.capitalizeFirst).join(' ');
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: isSelected ? const Border(bottom: BorderSide(color: _kPrimary, width: 2.5)) : const Border(bottom: BorderSide(color: Colors.transparent, width: 2.5)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      title,
                      style: isSelected ? robotoBold.copyWith(
                        fontSize: 13,
                        color: _kPrimary,
                      ) : robotoMedium.copyWith(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // ─── Tab Content (Menu Items) ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: items.map((item) {
                if (item is Map) {
                  String title = item['title']?.toString() ?? '';
                  String desc = item['description']?.toString() ?? '';
                  String price = item['price']?.toString() ?? '';
                  String extras = item['extras']?.toString() ?? '';
                  String image = item['image']?.toString() ?? '';
                  String imageUrl = '';
                  String currency = widget.currency;
                  
                  if (image.isNotEmpty) {
                    // Backend now returns full URL - use directly if it starts with http
                    if (image.startsWith('http')) {
                      imageUrl = image;
                    } else {
                      imageUrl = '${AppConstants.baseUrl}/storage/directory/dynamic/$image';
                    }
                  }

                  // Pick a subtle gradient palette per item
                  final List<List<Color>> _gradients = [
                    [const Color(0xFFF8F4EF), const Color(0xFFEDE5D8)], // Warm ivory
                    [const Color(0xFFF0F4FA), const Color(0xFFDDE7F3)], // Cool sky
                    [const Color(0xFFF5F0F8), const Color(0xFFE8DCF0)], // Soft lavender
                    [const Color(0xFFEFF8F4), const Color(0xFFD8EDE3)], // Mint fresh
                    [const Color(0xFFFFF8F0), const Color(0xFFF0E0C8)], // Golden cream
                  ];
                  final gradientColors = _gradients[items.indexOf(item) % _gradients.length];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: GestureDetector(
                      onTap: () => _showItemModal(context, title, desc, price, extras, imageUrl, currency),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // ─── Main Card ───
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: gradientColors,
                              ),
                              border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.2),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 16, offset: const Offset(0, 6)),
                                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // ─── Subtle watermark icon behind content ───
                                if (image.isNotEmpty)
                                  Positioned(
                                    right: -8,
                                    bottom: -8,
                                    child: Opacity(
                                      opacity: 0.08,
                                      child: SizedBox(
                                        width: 90,
                                        height: 90,
                                        child: CustomImage(
                                          image: imageUrl,
                                          fit: BoxFit.contain,
                                          placeholder: Images.placeholder,
                                        ),
                                      ),
                                    ),
                                  ),
                                // ─── Card Content ───
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (image.isNotEmpty) ...[
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: SizedBox(
                                            width: 85,
                                            height: 85,
                                            child: CustomImage(
                                              image: imageUrl,
                                              fit: BoxFit.cover,
                                              placeholder: Images.placeholder,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                    ],
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(title, style: robotoBold.copyWith(fontSize: 15, color: _kPrimary)),
                                          if (desc.isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Text(desc, style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey[600], height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                                          ],
                                          if (extras.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                _AnimatedExtrasPill(
                                                  onTap: () => _showItemModal(context, title, desc, price, extras, imageUrl, currency),
                                                ),
                                              ],
                                            ),
                                          ],
                                          const SizedBox(height: 20), // Space for the floating price
                                        ],
                                      ),
                                    ),

                                  ],
                                ),
                              ],
                            ),
                          ),
                          // ─── Floating Price Badge (3D effect) ───
                          if (price.isNotEmpty)
                            Positioned(
                              bottom: -10,
                              left: image.isNotEmpty ? 115 : 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color(0xFFD4B872), Color(0xFFC5A059)],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFE0C880).withOpacity(0.5), width: 0.5),
                                  boxShadow: [
                                    BoxShadow(color: const Color(0xFFC5A059).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2)),
                                  ],
                                ),
                                child: _buildPriceText(currency, price, 13, Colors.white),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox();
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Premium Item Detail Modal ───
  void _showItemModal(BuildContext context, String title, String desc, String price, String extras, String imageUrl, String currency) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFDF8),
              Color(0xFFF8F4EE),
              Color(0xFFF0EBE0),
            ],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Drag Handle ───
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // ─── Close button ───
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  margin: const EdgeInsets.only(top: 8, right: 20),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kPrimary.withOpacity(0.06),
                    border: Border.all(color: Colors.grey.withOpacity(0.15)),
                  ),
                  child: const Icon(Icons.close_rounded, size: 18, color: _kPrimary),
                ),
              ),
            ),
            // ─── Image ───
            if (imageUrl.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE0D8C8).withOpacity(0.5), width: 1.2),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 6)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CustomImage(image: imageUrl, fit: BoxFit.cover, placeholder: Images.placeholder),
                ),
              ),
            // ─── Title ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                title,
                style: robotoBold.copyWith(fontSize: 22, color: _kPrimary, height: 1.2),
                textAlign: TextAlign.center,
              ),
            ),
            // ─── Description ───
            if (desc.isNotEmpty) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  desc,
                  style: robotoRegular.copyWith(fontSize: 14, color: Colors.grey[600], height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            // ─── Extras ───
            if (extras.isNotEmpty) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    Text('Available Extras', style: robotoBold.copyWith(fontSize: 14, color: _kPrimary.withOpacity(0.8))),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: extras.split(',').map((e) {
                        String eStr = e.trim();
                        // Try to highlight price if exists like "+$2"
                        List<String> parts = eStr.split(RegExp(r'(?=\+\$)'));
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE0D8C8), width: 1.2),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 3)),
                            ],
                          ),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: parts[0].trim(), style: robotoMedium.copyWith(fontSize: 13, color: _kPrimary)),
                                if (parts.length > 1)
                                  TextSpan(text: '  ${parts[1].trim()}', style: robotoBold.copyWith(fontSize: 13, color: const Color(0xFFC5A059))),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
            // ─── Price badge ───
            if (price.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFD4B872), Color(0xFFC5A059)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFFE0C880).withOpacity(0.6), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFC5A059).withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 5)),
                  ],
                ),
                child: _buildPriceText(currency, price, 20, Colors.white),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _AnimatedExtrasPill extends StatefulWidget {
  final VoidCallback onTap;
  const _AnimatedExtrasPill({required this.onTap});

  @override
  State<_AnimatedExtrasPill> createState() => _AnimatedExtrasPillState();
}

class _AnimatedExtrasPillState extends State<_AnimatedExtrasPill> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transformAlignment: Alignment.centerLeft,
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerLeft,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(left: 14),
              padding: const EdgeInsets.fromLTRB(18, 5, 12, 5),
              decoration: BoxDecoration(
                color: _isPressed ? Colors.white.withOpacity(0.9) : Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isPressed ? _kGold : Colors.white, 
                  width: 1.5
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isPressed ? _kGold.withOpacity(0.4) : Colors.black.withOpacity(0.03), 
                    blurRadius: _isPressed ? 12 : 4, 
                    offset: const Offset(0, 2)
                  ),
                ],
              ),
              child: Text(
                'Extras available', 
                style: robotoBold.copyWith(
                  fontSize: 11, 
                  color: _isPressed ? _kGold : _kPrimary.withOpacity(0.85)
                )
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isPressed ? _kGold : _kPrimary,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _isPressed ? _kGold.withOpacity(0.6) : _kPrimary.withOpacity(0.3), 
                    blurRadius: _isPressed ? 12 : 6, 
                    offset: const Offset(0, 3)
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
