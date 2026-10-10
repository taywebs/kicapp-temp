import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:demandium/feature/splash/widget/easy_to_find_splash_view.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBody? body;
  final String? route;
  const SplashScreen({super.key, this.body, this.route});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;

  /// The intro animation and the config request finish independently.
  /// Navigation waits for both, so the animation is never cut mid-way and a
  /// slow network never leaves the user on a finished splash.
  bool _introFinished = false;
  VoidCallback? _pendingNavigation;

  void _onIntroFinished() {
    _introFinished = true;
    _runPendingNavigation();
  }

  /// Queues [navigate] until the intro animation has finished.
  void _navigateWhenReady(VoidCallback navigate) {
    _pendingNavigation = navigate;
    _runPendingNavigation();
  }

  void _runPendingNavigation() {
    if (!_introFinished || _pendingNavigation == null || !mounted) return;
    final VoidCallback navigate = _pendingNavigation!;
    _pendingNavigation = null;
    navigate();
  }

  @override
  void initState() {
    super.initState();

    bool firstTime = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if(!firstTime) {
        bool isNotConnected = result.first != ConnectivityResult.wifi && result.first != ConnectivityResult.mobile;
        isNotConnected ? const SizedBox() : ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
        ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
          backgroundColor: isNotConnected ? Colors.red : Colors.green,
          duration: Duration(seconds: isNotConnected ? 6000 : 3),
          content: Text(
            isNotConnected ? 'no_connection'.tr : 'connected'.tr,
            textAlign: TextAlign.center,
          ),
        ));
        if(!isNotConnected) {
          _route();
        }
      }
      firstTime = false;
    });

    if( Get.find<SplashController>().getGuestId().isEmpty){
      var uuid = const Uuid().v1();
      Get.find<SplashController>().setGuestId(uuid);
    }

    Get.find<SplashController>().initSharedData();
    _route();

  }

  @override
  void dispose() {
    super.dispose();
    _onConnectivityChanged?.cancel();
  }

  void _route() {
    Get.find<SplashController>().getConfigData().then((isSuccess) async {

      if(Get.find<LocationController>().getUserAddress() != null){
        AddressModel addressModel = Get.find<LocationController>().getUserAddress()!;
        ZoneResponseModel responseModel = await Get.find<LocationController>().getZone(addressModel.latitude.toString(), addressModel.longitude.toString(), false);
        addressModel.availableServiceCountInZone = responseModel.totalServiceCount;
        Get.find<LocationController>().saveUserAddress(addressModel);
      }


      if(isSuccess) {
        _navigateWhenReady(() {

          if(_checkAvailableUpdate()) {
            Get.offNamed(RouteHelper.getUpdateRoute('update'));
          }
          else if(_checkMaintenanceModeActive() && !AppConstants.avoidMaintenanceMode){
            Get.offAllNamed(RouteHelper.getMaintenanceRoute());
          }
          else {
            if(widget.body != null) {
              _notificationRoute();
            }
            else {
              // Easy to find goes straight from the splash into the Directory:
              // no language picker and no onboarding on first launch. The
              // language stays changeable from the Directory settings.
              Get.offNamed(RouteHelper.getInitialRoute());
            }
          }
        });
      }else{

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      backgroundColor: const Color(0xFF020A16),
      body: GetBuilder<SplashController>(builder: (splashController) {
        PriceConverter.getCurrency();
        return splashController.hasConnection
            ? EasyToFindSplashView(onAnimationDone: _onIntroFinished)
            : NoInternetScreen(child: SplashScreen(body: widget.body));
      }),
    );
  }

  bool _checkAvailableUpdate (){
    ConfigModel? configModel = Get.find<SplashController>().configModel;
    final localVersion = Version.parse(AppConstants.appVersion);
    final serverVersion = Version.parse(GetPlatform.isAndroid
        ? configModel.content?.minimumVersion?.minVersionForAndroid ?? ""
        :  configModel.content?.minimumVersion?.minVersionForIos ?? ""
    );
    return localVersion.compareTo(serverVersion) == -1;
  }

  bool _checkMaintenanceModeActive(){
    final ConfigModel configModel = Get.find<SplashController>().configModel;
    return (configModel.content?.maintenanceMode?.maintenanceStatus == 1 && configModel.content?.maintenanceMode?.selectedMaintenanceSystem?.mobileApp == 1);
  }

  void _notificationRoute(){

    String notificationType = widget.body?.notificationType??"";

    switch(notificationType) {

      case "chatting": {
        Get.toNamed(RouteHelper.getInboxScreenRoute(fromNotification: "fromNotification"));
      } break;

      case "bidding": {
        Get.toNamed(RouteHelper.getMyPostScreen(fromNotification: "fromNotification"));
      } break;

      case "booking" || 'booking_ignored': {
        if( widget.body!.bookingId!=null&& widget.body!.bookingId!=""){
          if(widget.body?.bookingType == "repeat" && widget.body?.repeatBookingType == "single"){
            Get.toNamed(RouteHelper.getBookingDetailsScreen( subBookingId : widget.body!.bookingId!,fromPage: 'fromNotification'));
          }else if(widget.body?.bookingType == "repeat" && widget.body?.repeatBookingType != "single"){
            Get.toNamed(RouteHelper.getRepeatBookingDetailsScreen( bookingId : widget.body!.bookingId, fromPage : "fromNotification"));
          }else{
            Get.toNamed(RouteHelper.getBookingDetailsScreen( bookingID:widget.body!.bookingId!,fromPage: 'fromNotification'));
          }
        }else{
          Get.toNamed(RouteHelper.getMainRoute(""));
        }
      } break;

      case "privacy_policy": {
        Get.toNamed(RouteHelper.getHtmlRoute("privacy-policy"));
      } break;

      case "terms_and_conditions": {
        Get.toNamed(RouteHelper.getHtmlRoute("terms-and-condition"));
      } break;

      case "wallet": {
        Get.toNamed(RouteHelper.getMyWalletScreen(fromNotification: "fromNotification"));
      } break;

      case "loyalty_point": {
        Get.toNamed(RouteHelper.getLoyaltyPointScreen(fromNotification: "fromNotification"));
      } break;

      default: {
        Get.toNamed(RouteHelper.getNotificationRoute());
      } break;
    }
  }
}
