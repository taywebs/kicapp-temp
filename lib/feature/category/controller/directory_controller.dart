import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:demandium/feature/category/model/directory_model.dart';
import 'package:demandium/feature/category/repository/directory_repo.dart';

class DirectoryController extends GetxController implements GetxService {
  final DirectoryRepo directoryRepo;
  DirectoryController({required this.directoryRepo});

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
      print('Error in getDirectoryList: $e');
      if (_directoryList == null) _directoryList = [];
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

    Response response = await directoryRepo.getDirectoryDetails(id);
    if (response.statusCode == 200 && response.body['response_code'] == 'default_200') {
      try {
        _directoryDetails = DirectoryModel.fromJson(response.body['content']['directory']);
        _reviewsList = response.body['content']['reviews']['data'];
        _ratingInfo = response.body['content']['rating'];
      } catch (e) {
        print('Error parsing directory details: $e');
        _directoryDetails = null;
      }
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> submitDirectoryReview(String directoryId, int rating, String comment, String reviewerName) async {
    _isLoading = true;
    update();

    Map<String, dynamic> body = {
      'directory_listing_id': directoryId,
      'review_rating': rating.toString(),
      'review_comment': comment,
      'reviewer_name': reviewerName,
    };

    Response response = await directoryRepo.submitDirectoryReview(body);
    if (response.statusCode == 200) {
      customSnackBar('Review submitted successfully', type: ToasterMessageType.success);
      getDirectoryDetails(directoryId); // Refresh details to show new review
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }
}
