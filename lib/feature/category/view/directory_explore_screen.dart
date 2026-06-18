import 'dart:ui';
import 'package:demandium/utils/core_export.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demandium/feature/category/controller/directory_controller.dart';
import 'package:demandium/feature/category/model/directory_model.dart';
import 'package:demandium/feature/category/view/directory_details_screen.dart';

// ─── Brand Colors ──────────────────────────────────────────
const Color _kPrimary   = Color(0xFF1A1A1B);
const Color _kGold      = Color(0xFFC5A059);
const Color _kGoldLight = Color(0xFFFFF8E7);
const Color _kBlue      = Color(0xFF0052CC);
const Color _kBg        = Color(0xFFF4F6FA);

class DirectoryExploreScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String? searchQuery;

  const DirectoryExploreScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    this.searchQuery,
  });

  @override
  State<DirectoryExploreScreen> createState() => _DirectoryExploreScreenState();
}

class _DirectoryExploreScreenState extends State<DirectoryExploreScreen>
    with TickerProviderStateMixin {
  String _selectedFilter = 'All';
  bool _isSearching = false;
  final TextEditingController _searchCtrl = TextEditingController();
  late AnimationController _headerAnimCtrl;
  late Animation<double> _headerFade;

  static const List<Map<String, dynamic>> _filters = [
    {'label': 'All',           'icon': Icons.apps_rounded},
    {'label': 'Top Rated',     'icon': Icons.star_rounded},
    {'label': 'Nearest',       'icon': Icons.near_me_rounded},
    {'label': 'Open Now',      'icon': Icons.schedule_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _headerAnimCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600),
    )..forward();
    _headerFade = CurvedAnimation(parent: _headerAnimCtrl, curve: Curves.easeOut);

    Future.microtask(() {
      Get.find<DirectoryController>().getDirectoryList('1', widget.categoryId, true, searchQuery: widget.searchQuery);
    });
  }

  @override
  void dispose() {
    _headerAnimCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isNotEmpty) {
      setState(() => _isSearching = false);
      Get.find<DirectoryController>().getDirectoryList('1', widget.categoryId, true, searchQuery: query.trim());
    }
  }

  // ─── Check if listing has working_hours data in dynamic_data ───
  static bool _hasWorkingHoursData(DirectoryModel d) {
    if (d.dynamicData == null || d.dynamicData is! Map) return false;
    final Map<String, dynamic> data = Map<String, dynamic>.from(d.dynamicData as Map);
    for (final val in data.values) {
      if (val is Map) {
        final keys = val.keys.map((k) => k.toString().toLowerCase()).toList();
        if (keys.any((k) => ['monday','tuesday','wednesday','thursday','friday','saturday','sunday'].contains(k))) {
          return true;
        }
      }
    }
    return false;
  }

  // ─── Check if a listing is currently open based on working_hours in dynamic_data ───
  static bool isCurrentlyOpen(DirectoryModel d) {
    if (d.dynamicData == null || d.dynamicData is! Map) return false;
    final Map<String, dynamic> data = Map<String, dynamic>.from(d.dynamicData as Map);

    // Find the working_hours field (key may vary based on admin schema label)
    Map<String, dynamic>? hours;
    for (final val in data.values) {
      if (val is Map) {
        // Check if the map has day keys like Monday, Tuesday...
        final keys = val.keys.map((k) => k.toString().toLowerCase()).toList();
        if (keys.any((k) => ['monday','tuesday','wednesday','thursday','friday','saturday','sunday'].contains(k))) {
          hours = Map<String, dynamic>.from(val as Map);
          break;
        }
      }
    }
    if (hours == null) return false;

    final now = DateTime.now();
    // DateTime weekday: 1=Mon ... 7=Sun
    const dayNames = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    final todayName = dayNames[now.weekday - 1];

    // Try to find today's schedule (case-insensitive)
    Map<String, dynamic>? todaySchedule;
    for (final entry in hours.entries) {
      if (entry.key.toLowerCase() == todayName.toLowerCase()) {
        if (entry.value is Map) {
          todaySchedule = Map<String, dynamic>.from(entry.value as Map);
        }
        break;
      }
    }
    if (todaySchedule == null) return false;

    final active = todaySchedule['active'];
    if (active == null || active == 0 || active == '0' || active == false) return false;

    final startStr = todaySchedule['start']?.toString() ?? '';
    final endStr   = todaySchedule['end']?.toString() ?? '';
    if (startStr.isEmpty || endStr.isEmpty) return false;

    try {
      final startParts = startStr.split(':');
      final endParts   = endStr.split(':');
      final startMin = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMin   = int.parse(endParts[0])   * 60 + int.parse(endParts[1]);
      final nowMin   = now.hour * 60 + now.minute;

      if (endMin > startMin) {
        return nowMin >= startMin && nowMin < endMin;
      } else {
        // Overnight shift
        return nowMin >= startMin || nowMin < endMin;
      }
    } catch (_) {
      return false;
    }
  }

  List<DirectoryModel> _getFiltered(List<DirectoryModel> all) {
    switch (_selectedFilter) {
      case 'Top Rated':
        final sorted = List<DirectoryModel>.from(all);
        sorted.sort((a, b) => (b.averageRating ?? 0).compareTo(a.averageRating ?? 0));
        return sorted;
      case 'Open Now':
        return all.where((d) => isCurrentlyOpen(d)).toList();
      case 'Nearest':
        // Sort by nearest — if no GPS available, fall back to original order
        final withLocation = all.where((d) => d.latitude != null && d.longitude != null).toList();
        final withoutLocation = all.where((d) => d.latitude == null || d.longitude == null).toList();
        return [...withLocation, ...withoutLocation];
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.3, 0.7, 1.0],
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFCFAF6),
              Color(0xFFF6F0E4),
              Color(0xFFF0E8D6),
            ],
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                // AppBar placeholder
                SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
                // Filter Row
                FadeTransition(opacity: _headerFade, child: _buildFilterRow()),
                // List
                Expanded(
                  child: GetBuilder<DirectoryController>(builder: (ctrl) {
                    if (ctrl.isLoading) return _buildShimmer();

                    final all = ctrl.directoryList ?? [];
                    final filtered = _getFiltered(all);

                    if (filtered.isEmpty) return _buildEmptyState();

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) => _AnimatedCard(
                        index: index,
                        child: _buildCard(context, filtered[index]),
                      ),
                    );
                  }),
                ),
              ],
            ),
            // ─── Search Overlay ───
            if (_isSearching)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _isSearching = false),
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                    child: SafeArea(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: GestureDetector(
                            onTap: () {}, // Prevent closing when tapping input
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(color: _kGold.withOpacity(0.15), blurRadius: 30, offset: const Offset(0, 8)),
                                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2)),
                                ],
                                border: Border.all(color: _kGold.withOpacity(0.3), width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.search_rounded, color: _kGold, size: 22),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchCtrl,
                                      autofocus: true,
                                      style: robotoMedium.copyWith(fontSize: 14, color: _kPrimary),
                                      decoration: InputDecoration(
                                        hintText: 'Search in ${widget.categoryName}...',
                                        hintStyle: robotoRegular.copyWith(color: Colors.grey[400], fontSize: 14),
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                      onSubmitted: _onSearch,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _searchCtrl.clear();
                                      setState(() => _isSearching = false);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.close_rounded, size: 16, color: Colors.grey[600]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.92),
                  const Color(0xFFFAF7F0).withOpacity(0.92),
                ],
              ),
              border: const Border(
                bottom: BorderSide(color: Color(0xFFE8E0D0), width: 0.5),
              ),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, Color(0xFFF0ECE4)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3)),
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 2, offset: const Offset(0, 1)),
                    ],
                    border: Border.all(color: Colors.white.withOpacity(0.9)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: _kPrimary, size: 16),
                ),
              ),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.categoryName.isNotEmpty ? widget.categoryName : 'Explore',
                    style: robotoBold.copyWith(fontSize: 18, color: _kPrimary, letterSpacing: -0.3),
                  ),
                  const SizedBox(height: 2),
                  GetBuilder<LocationController>(builder: (lc) {
                    final addr = lc.getUserAddress()?.address ?? 'Select Location';
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _kGoldLight.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_rounded, size: 10, color: _kGold),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              addr,
                              style: robotoMedium.copyWith(fontSize: 10, color: Color(0xFF8B7A5E)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
              actions: [
                GestureDetector(
                  onTap: () => setState(() => _isSearching = true),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Color(0xFFF0ECE4)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3)),
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 2, offset: const Offset(0, 1)),
                      ],
                      border: Border.all(color: Colors.white.withOpacity(0.9)),
                    ),
                    child: const Icon(Icons.search_rounded, color: _kPrimary, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _filters.map((f) {
            final bool active = _selectedFilter == f['label'];
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = f['label']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: active ? _kPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: active ? _kPrimary : Colors.grey.shade200,
                    width: 1,
                  ),
                  boxShadow: active
                      ? [BoxShadow(color: _kPrimary.withOpacity(0.25), blurRadius: 12, offset: const Offset(0, 4))]
                      : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      f['icon'] as IconData,
                      size: 14,
                      color: active ? _kGold : Colors.grey[500],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      f['label'],
                      style: (active ? robotoBold : robotoMedium).copyWith(
                        fontSize: 12,
                        color: active ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, DirectoryModel d) {
    final double rating = d.averageRating ?? 0.0;
    final String imgUrl = d.coverImageFullPath ?? d.bannerUrl ?? '';
    // Compute open/closed status once for this listing
    final bool hasWorkingHours = _hasWorkingHoursData(d);
    final bool isOpen = hasWorkingHours ? isCurrentlyOpen(d) : false;

    return GestureDetector(
      onTap: () => Get.to(
        () => DirectoryDetailsScreen(
          directoryId: d.id!,
          categoryName: widget.categoryName,
          initialModel: d,
        ),
        transition: Transition.fadeIn,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE0D8C8).withOpacity(0.6), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: const Color(0xFFC5A059).withOpacity(0.06),
              blurRadius: 30,
              spreadRadius: -4,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Hero Image ───────────────────────────────────
              Stack(
                children: [
                  SizedBox(
                    height: 185,
                    width: double.infinity,
                    child: imgUrl.isEmpty
                        ? Container(
                            color: const Color(0xFFF0F0F0),
                            child: Icon(Icons.storefront_rounded, size: 60, color: Colors.grey[300]),
                          )
                        : CustomImage(
                            image: imgUrl,
                            fit: BoxFit.cover,
                            placeholder: Images.placeholder,
                          ),
                  ),
                  // Bottom gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.4, 1.0],
                          colors: [Colors.transparent, _kPrimary.withOpacity(0.7)],
                        ),
                      ),
                    ),
                  ),
                  // Open/Closed status badge - top left
                  Positioned(
                    top: 14,
                    left: 14,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: hasWorkingHours
                                ? (isOpen
                                    ? const Color(0xFF27AE60).withOpacity(0.85)
                                    : const Color(0xFFE74C3C).withOpacity(0.85))
                                : Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasWorkingHours) ...[
                                Container(
                                  width: 7, height: 7,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isOpen ? 'Open' : 'Closed',
                                  style: robotoBold.copyWith(fontSize: 11, color: Colors.white),
                                ),
                              ] else ...[
                                const Icon(Icons.local_cafe_rounded, size: 11, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  widget.categoryName,
                                  style: robotoMedium.copyWith(fontSize: 11, color: Colors.white),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Heart button - top right
                  Positioned(
                    top: 12,
                    right: 12,
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: const Icon(Icons.favorite_border_rounded, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  // Title over image bottom-left
                  Positioned(
                    bottom: 14,
                    left: 16,
                    right: 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          d.title ?? 'Unnamed',
                          style: robotoBold.copyWith(
                            fontSize: 17,
                            color: Colors.white,
                            height: 1.2,
                            shadows: [Shadow(color: Colors.black.withOpacity(0.4), blurRadius: 8)],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 12, color: Colors.white70),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                d.city ?? d.address ?? 'Location N/A',
                                style: robotoRegular.copyWith(fontSize: 11, color: Colors.white70),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Rating badge - bottom right
                  Positioned(
                    bottom: 12,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD060), _kGold],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: _kGold.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 13, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            rating > 0 ? rating.toStringAsFixed(1) : 'New',
                            style: robotoBold.copyWith(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ─── Card Footer ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  children: [
                    // Verified badge
                    _buildBadge(
                      Icons.verified_rounded,
                      'Verified',
                      const Color(0xFF27AE60),
                      const Color(0xFFE9F7EF),
                    ),
                    const SizedBox(width: 8),
                    // Phone/Open status (if available)
                    if (d.phone != null && d.phone!.isNotEmpty)
                      _buildBadge(
                        Icons.phone_rounded,
                        d.phone!,
                        _kBlue,
                        const Color(0xFFE8F0FF),
                      ),
                    const Spacer(),
                    // CTA Arrow
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _kPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: robotoMedium.copyWith(fontSize: 11, color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      itemCount: 4,
      itemBuilder: (_, i) => _ShimmerCard(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [_kGoldLight, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(Icons.search_off_rounded, size: 50, color: _kGold.withOpacity(0.6)),
          ),
          const SizedBox(height: 24),
          Text('No listings found', style: robotoBold.copyWith(fontSize: 18, color: _kPrimary)),
          const SizedBox(height: 8),
          Text(
            'Try a different filter or check back later.',
            style: robotoRegular.copyWith(fontSize: 13, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Animated Card Wrapper ────────────────────────────────────
class _AnimatedCard extends StatefulWidget {
  final int index;
  final Widget child;
  const _AnimatedCard({required this.index, required this.child});

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + widget.index * 80),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.index * 60), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(position: _slideAnim, child: widget.child),
    );
  }
}

// ─── Shimmer Placeholder Card ────────────────────────────────
class _ShimmerCard extends StatefulWidget {
  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final c = Color.lerp(const Color(0xFFEEEEEE), const Color(0xFFF8F8F8), _anim.value)!;
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Column(
            children: [
              Container(height: 185, decoration: BoxDecoration(color: c, borderRadius: const BorderRadius.vertical(top: Radius.circular(22)))),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(width: 70, height: 22, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(6))),
                    const SizedBox(width: 8),
                    Container(width: 50, height: 22, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(6))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
