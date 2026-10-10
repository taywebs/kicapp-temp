import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';


class ApiChecker {
  static void checkApi(Response response, {bool showDefaultToaster = true}) {


    if(response.statusCode == 401) {
      Get.find<AuthController>().clearSharedData(response: response);
      if(Get.currentRoute != RouteHelper.getInitialRoute()){
        Get.offAllNamed(RouteHelper.getInitialRoute());
        customSnackBar("${response.statusCode!}".tr);
      }
    }else if(response.statusCode == 500){
      customSnackBar("${response.statusCode!}".tr, showDefaultSnackBar: showDefaultToaster);
    }
    else if(response.statusCode == 400 && response.body != null && response.body is Map && response.body['errors'] != null){
      if(response.body['errors'] is List && response.body['errors'].isNotEmpty) {
        var firstError = response.body['errors'][0];
        if (firstError != null && firstError is Map && firstError['message'] != null) {
          customSnackBar("${firstError['message']}",showDefaultSnackBar: showDefaultToaster);
        } else {
          customSnackBar("Bad Request", showDefaultSnackBar: showDefaultToaster);
        }
      } else {
         customSnackBar("Bad Request", showDefaultSnackBar: showDefaultToaster);
      }
    }
    else if(response.statusCode == 429){
      customSnackBar("too_many_request".tr, showDefaultSnackBar: showDefaultToaster);
    }
    else{
      String? errorMessage;
      if (response.body != null && response.body is Map && response.body['message'] != null) {
        errorMessage = response.body['message'];
      } else {
        errorMessage = response.statusText;
      }
      customSnackBar("${errorMessage ?? 'An error occurred'}", showDefaultSnackBar: showDefaultToaster);
    }
  }
}