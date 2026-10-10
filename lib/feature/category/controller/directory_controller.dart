import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:demandium/feature/category/model/directory_model.dart';
import 'package:demandium/feature/category/repository/directory_repo.dart';

class DirectoryController extends GetxController implements GetxService {
  final DirectoryRepo directoryRepo;
  DirectoryController({required this.directoryRepo});

  // ───────────────────────── saved listings ─────────────────────────
  // One implementation for the whole feature: the details screen, the saved
  // tab and the bookmark on every card all read and write through here, so
  // they can never fall out of sync.

  static const String _savedIdsKey = 'saved_directory_listings';
  static const String _savedModelsKey = 'saved_directory_models';

  SharedPreferences get _prefs => Get.find<SharedPreferences>();

  List<String> get savedIds => _prefs.getStringList(_savedIdsKey) ?? <String>[];

  bool isSaved(String? id) => id != null && id.isNotEmpty && savedIds.contains(id);

  /// The saved listings, newest first.
  List<DirectoryModel> get savedListings {
    final List<String> raw = _prefs.getStringList(_savedModelsKey) ?? <String>[];
    final List<DirectoryModel> out = <DirectoryModel>[];
    for (final String item in raw) {
      try {
        final dynamic decoded = jsonDecode(item);
        if (decoded is Map<String, dynamic>) {
          out.add(DirectoryModel.fromJson(decoded));
        }
      } catch (_) {
        // A malformed entry is skipped instead of breaking the whole list.
      }
    }
    return out.reversed.toList();
  }

  /// Adds or removes [listing]; returns true when it ended up saved.
  bool toggleSaved(DirectoryModel listing) {
    final String id = listing.id ?? '';
    if (id.isEmpty) return false;

    final List<String> ids = List<String>.from(savedIds);
    final List<String> models =
        List<String>.from(_prefs.getStringList(_savedModelsKey) ?? <String>[]);

    final bool wasSaved = ids.contains(id);
    if (wasSaved) {
      ids.remove(id);
      models.removeWhere((String item) {
        try {
          final dynamic decoded = jsonDecode(item);
          return decoded is Map && decoded['id'] == id;
        } catch (_) {
          return false;
        }
      });
    } else {
      ids.add(id);
      models.add(jsonEncode(listing.toJson()));
    }

    _prefs.setStringList(_savedIdsKey, ids);
    _prefs.setStringList(_savedModelsKey, models);
    update();
    return !wasSaved;
  }

  /// Toggles and tells the user what happened.
  void toggleSavedWithFeedback(DirectoryModel listing) {
    final bool nowSaved = toggleSaved(listing);
    customSnackBar(
      nowSaved ? 'added_to_saved'.tr : 'remove_from_saved'.tr,
      type: nowSaved ? ToasterMessageType.success : ToasterMessageType.info,
    );
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<DirectoryModel>? _directoryList;
  List<DirectoryModel>? get directoryList => _directoryList;

  DirectoryModel? _directoryDetails;
  DirectoryModel? get directoryDetails => _directoryDetails;

  Future<void> getDirectoryList(String offset, String categoryId, bool reload, {String? searchQuery}) async {
    if (offset == '1' || reload) {
      _directoryList = null;
      _isLoading = true;
      update();
    }
    try {
      Response response = await directoryRepo.getDirectoryList(offset, categoryId, searchQuery: searchQuery);
      if (response.statusCode == 200) {
        if (offset == '1' || reload) {
          _directoryList = [];
        }
        response.body['content']['data'].forEach((directory) {
          _directoryList!.add(DirectoryModel.fromJson(directory));
        });
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getDirectoryList: $e');
      }
      _directoryList ??= <DirectoryModel>[];
    }
    _isLoading = false;
    update();
  }

  List<dynamic>? _reviewsList;
  List<dynamic>? get reviewsList => _reviewsList;

  Map<String, dynamic>? _ratingInfo;
  Map<String, dynamic>? get ratingInfo => _ratingInfo;

  Future<void> getDirectoryDetails(String id, {DirectoryModel? initialModel}) async {
    _directoryDetails = initialModel;
    _reviewsList = null;
    _ratingInfo = null;
    _isLoading = initialModel == null;
    update();

    try {
      Response response = await directoryRepo.getDirectoryDetails(id);
      if (response.statusCode == 200 && response.body['response_code'] == 'default_200') {
        _directoryDetails = DirectoryModel.fromJson(response.body['content']['directory']);
        _reviewsList = response.body['content']['reviews']['data'];
        _ratingInfo = response.body['content']['rating'];
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      // A network failure used to escape here and leave isLoading stuck at
      // true, so the details screen span forever with no retry.
      if (kDebugMode) {
        print('Error loading directory details: $e');
      }
      _directoryDetails ??= initialModel;
    } finally {
      _isLoading = false;
      update();
    }
  }

  /// Returns true only when the server accepted the review, so callers can
  /// decide whether to close the screen.
  Future<bool> submitDirectoryReview(String directoryId, int rating, String comment, String reviewerName) async {
    _isLoading = true;
    update();

    Map<String, dynamic> body = {
      'directory_listing_id': directoryId,
      'review_rating': rating.toString(),
      'review_comment': comment,
      'reviewer_name': reviewerName,
    };

    bool success = false;
    try {
      Response response = await directoryRepo.submitDirectoryReview(body);
      if (response.statusCode == 200) {
        success = true;
        customSnackBar('review_submitted_successfully'.tr, type: ToasterMessageType.success);
        getDirectoryDetails(directoryId); // Refresh details to show new review
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting directory review: $e');
      }
      customSnackBar('something_went_wrong'.tr);
    } finally {
      _isLoading = false;
      update();
    }
    return success;
  }
}
