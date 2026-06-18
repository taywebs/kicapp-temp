import 'dart:ui';
import 'dart:convert';
import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:demandium/feature/category/controller/directory_controller.dart';
import 'package:demandium/feature/category/model/directory_model.dart';
import 'package:demandium/feature/category/view/directory_details_screen.dart';

const Color _kPrimary  = Color(0xFF1A1A1B);
const Color _kGold     = Color(0xFFC5A059);
const Color _kBg       = Color(0xFFF4F7F9);
const Color _kBlue     = Color(0xFF0052CC);

class DirectorySavedScreen extends StatefulWidget {
  const DirectorySavedScreen({super.key});

  @override
  State<DirectorySavedScreen> createState() => _DirectorySavedScreenState();
}

class _DirectorySavedScreenState extends State<DirectorySavedScreen> {
  static const String _savedKey = 'saved_directory_listings';
  static const String _savedModelsKey = 'saved_directory_models';
  final SharedPreferences _prefs = Get.find();
  List<DirectoryModel> _savedListings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    setState(() => _isLoading = true);
    
    final List<String> savedModelsStr = _prefs.getStringList(_savedModelsKey) ?? [];
    
    if (savedModelsStr.isEmpty) {
      if (mounted) setState(() { _savedListings = []; _isLoading = false; });
      return;
    }

    List<DirectoryModel> loaded = [];
    for (String str in savedModelsStr) {
      try {
        final Map<String, dynamic> json = jsonDecode(str);
        final model = DirectoryModel.fromJson(json);
        loaded.add(model);
      } catch (e) {
        // ignore invalid json
      }
    }

    if (mounted) setState(() { _savedListings = loaded; _isLoading = false; });
  }

  void _unsave(DirectoryModel d) {
    final List<String> savedIds = List.from(_prefs.getStringList(_savedKey) ?? []);
    final List<String> savedModelsStr = List.from(_prefs.getStringList(_savedModelsKey) ?? []);
    
    savedIds.remove(d.id);
    savedModelsStr.removeWhere((str) {
      try {
        final Map map = jsonDecode(str);
        return map['id'] == d.id;
      } catch(e) { return false; }
    });
    
    _prefs.setStringList(_savedKey, savedIds.cast<String>());
    _prefs.setStringList(_savedModelsKey, savedModelsStr.cast<String>());
    
    setState(() => _savedListings.removeWhere((x) => x.id == d.id));
    customSnackBar('Removed from saved', type: ToasterMessageType.error);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: Text('Saved', style: robotoBold.copyWith(color: _kPrimary, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade100),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _kGold, strokeWidth: 2))
          : _savedListings.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  color: _kGold,
                  onRefresh: _loadSaved,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    itemCount: _savedListings.length,
                    itemBuilder: (context, index) {
                      return _buildCard(_savedListings[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildCard(DirectoryModel d) {
    final String imgUrl = d.coverImageFullPath ?? d.bannerUrl ?? '';
    final double rating = d.averageRating ?? 0.0;

    return GestureDetector(
      onTap: () {
        Get.to(() => DirectoryDetailsScreen(
          directoryId: d.id ?? '',
          categoryName: d.category?['name'] ?? '',
          initialModel: d,
        ))?.then((_) => _loadSaved()); // Refresh when coming back
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: SizedBox(
                width: 110,
                height: 110,
                child: imgUrl.isEmpty
                    ? Container(
                        color: const Color(0xFFF0F0F0),
                        child: Icon(Icons.storefront_rounded, size: 40, color: Colors.grey[300]),
                      )
                    : CustomImage(image: imgUrl, fit: BoxFit.cover, placeholder: Images.placeholder),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.title ?? 'Unnamed',
                      style: robotoBold.copyWith(fontSize: 15, color: _kPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      d.category?['name'] ?? d.address ?? '',
                      style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: _kGold),
                        const SizedBox(width: 4),
                        Text(rating.toStringAsFixed(1), style: robotoBold.copyWith(fontSize: 13, color: _kGold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Remove button
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => _unsave(d),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3F3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bookmark_remove_rounded, size: 20, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20)],
            ),
            child: const Icon(Icons.bookmark_border_rounded, size: 60, color: _kGold),
          ),
          const SizedBox(height: 24),
          Text(
            'No saved listings yet',
            style: robotoBold.copyWith(fontSize: 18, color: _kPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the bookmark on any listing to save it.',
            style: robotoRegular.copyWith(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
