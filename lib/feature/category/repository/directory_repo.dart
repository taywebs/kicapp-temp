import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';

class DirectoryRepo {
  final ApiClient apiClient;
  DirectoryRepo({required this.apiClient});

  Future<Response> getDirectoryList(String offset, String categoryId, {String? searchQuery}) async {
    String url = '/api/v1/customer/directory/list?offset=$offset&limit=10&category_id=$categoryId';
    if (searchQuery != null && searchQuery.isNotEmpty) {
      url += '&search=${Uri.encodeComponent(searchQuery)}';
    }
    return await apiClient.getData(url);
  }

  Future<Response> getDirectoryDetails(String id) async {
    return await apiClient.getData('/api/v1/customer/directory/details/$id');
  }

  Future<Response> submitDirectoryReview(Map<String, dynamic> body) async {
    return await apiClient.postData('/api/v1/customer/review/directory-submit', body);
  }
}
