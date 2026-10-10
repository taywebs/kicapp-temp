import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:demandium/common/widgets/dir_ui.dart';
import 'package:demandium/feature/auth/widgets/dir_auth_scaffold.dart';

class SignInScreen extends StatefulWidget {
  final bool exitFromApp;
  final String? fromPage;
  const SignInScreen({super.key, required this.exitFromApp, this.fromPage});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  var signInPhoneController = TextEditingController();
  var signInPasswordController = TextEditingController();

  final _passwordFocus = FocusNode();
  final _phoneFocus = FocusNode();

  bool _canExit = GetPlatform.isWeb ? true : false;
  final GlobalKey<FormState> customerSignInKey = GlobalKey<FormState>();

  @override
  void initState() {
    _initializeController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      onPopInvoked: () => _existFromApp(),
      child: GetBuilder<SplashController>(builder: (splashController) {
        return GetBuilder<AuthController>(builder: (authController) {
          final config = splashController.configModel.content;
          final otpLogin = config?.customerLogin?.loginOption?.otpLogin;
          final manualLogin = config?.customerLogin?.loginOption?.manualLogin ?? 1;
          final socialLogin = config?.customerLogin?.loginOption?.socialMediaLogin;

          final bool isOtpMode = authController.selectedLoginMedium == LoginMedium.otp ||
              (manualLogin == 0 && otpLogin == 1);
          final bool showForm = manualLogin == 1 || otpLogin == 1;
          final bool showPassword =
              manualLogin == 1 && authController.selectedLoginMedium == LoginMedium.manual;

          return DirAuthScaffold(
            title: 'welcome_back'.tr,
            subtitle: 'sign_in_subtitle'.tr,
            showBack: !widget.exitFromApp,
            child: Form(
              autovalidateMode: AutovalidateMode.disabled,
              key: customerSignInKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (showForm) ...<Widget>[
                    DirFieldLabel(isOtpMode ? 'phone'.tr : 'email_phone'.tr),
                    CustomTextField(
                      isShowBorder: true,
                      borderRadius: DirTokens.radius,
                      onCountryChanged: (CountryCode countryCode) =>
                          authController.countryDialCode = countryCode.dialCode!,
                      countryDialCode: authController.isNumberLogin || isOtpMode
                          ? authController.countryDialCode
                          : null,
                      hintText: isOtpMode
                          ? 'please_enter_phone_number'.tr
                          : 'enter_email_or_phone'.tr,
                      controller: signInPhoneController,
                      focusNode: _phoneFocus,
                      nextFocus: _passwordFocus,
                      capitalization: TextCapitalization.none,
                      onChanged: (String text) {
                        if (authController.selectedLoginMedium != LoginMedium.otp) {
                          final numberRegExp = RegExp(r'^[+]?[0-9]+$');

                          if (text.isEmpty && authController.isNumberLogin) {
                            authController.toggleIsNumberLogin();
                          }
                          if (text.startsWith(numberRegExp) &&
                              !authController.isNumberLogin &&
                              manualLogin == 1) {
                            authController.toggleIsNumberLogin();
                            final cursorPosition = signInPhoneController.selection.baseOffset;
                            signInPhoneController.text = text.replaceAll("+", "");
                            signInPhoneController.selection = TextSelection.fromPosition(
                                TextPosition(offset: cursorPosition));
                          }
                          final emailRegExp = RegExp(r'@');
                          if (text.contains(emailRegExp) &&
                              authController.isNumberLogin &&
                              manualLogin == 1) {
                            authController.toggleIsNumberLogin();
                          }

                          _phoneFocus.requestFocus();
                        }
                      },
                      onValidate: (String? value) {
                        if (otpLogin == 1 &&
                            manualLogin == 0 &&
                            PhoneVerificationHelper.getValidPhoneNumber(
                                    authController.countryDialCode +
                                        signInPhoneController.text.trim(),
                                    withCountryCode: true) ==
                                "") {
                          return "enter_valid_phone_number".tr;
                        }
                        if (authController.isNumberLogin &&
                            PhoneVerificationHelper.getValidPhoneNumber(
                                    authController.countryDialCode +
                                        signInPhoneController.text.trim(),
                                    withCountryCode: true) ==
                                "") {
                          return "enter_valid_phone_number".tr;
                        }
                        return (PhoneVerificationHelper.getValidPhoneNumber(
                                        authController.countryDialCode +
                                            signInPhoneController.text.trim(),
                                        withCountryCode: true) !=
                                    "" ||
                                GetUtils.isEmail(value ?? ""))
                            ? null
                            : 'enter_email_or_phone'.tr;
                      },
                    ),
                  ],

                  if (showPassword) ...<Widget>[
                    const SizedBox(height: 16),
                    DirFieldLabel('password'.tr),
                    CustomTextField(
                      isShowBorder: true,
                      borderRadius: DirTokens.radius,
                      hintText: '••••••••',
                      controller: signInPasswordController,
                      focusNode: _passwordFocus,
                      inputType: TextInputType.visiblePassword,
                      isPassword: true,
                      inputAction: TextInputAction.done,
                      onValidate: (String? value) => FormValidation().isValidPassword(value!.tr),
                    ),
                  ],

                  if (showForm) ...<Widget>[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: InkWell(
                            onTap: () => authController.toggleRememberMe(),
                            borderRadius: BorderRadius.circular(8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    activeColor: DirTokens.primary,
                                    value: authController.isActiveRememberMe,
                                    onChanged: (bool? isChecked) =>
                                        authController.toggleRememberMe(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text('remember_me'.tr,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 13, color: DirTokens.onSurfaceVariant)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (showPassword)
                          TextButton(
                            onPressed: () => Get.toNamed(RouteHelper.getSendOtpScreen()),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              minimumSize: const Size(0, 36),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text('forgot_password'.tr,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: DirTokens.secondary)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    DirButton(
                      label: isOtpMode ? 'get_otp'.tr : 'sign_in'.tr,
                      loading: authController.isLoading,
                      onPressed: () {
                        if (customerSignInKey.currentState!.validate()) {
                          _login(authController, manualLogin, otpLogin);
                        }
                      },
                    ),
                  ],

                  // Switch between password and one-time code
                  if (manualLogin == 1 && otpLogin == 1) ...<Widget>[
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: () => _toggleLoginMedium(authController),
                        child: Text(
                          authController.selectedLoginMedium == LoginMedium.manual
                              ? 'sign_in_with_otp'.tr
                              : 'sign_in_with_password'.tr,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: DirTokens.primary),
                        ),
                      ),
                    ),
                  ],

                  if (showForm && socialLogin == 1) ...<Widget>[
                    const SizedBox(height: 18),
                    const DirOrDivider(),
                  ],

                  if (socialLogin == 1) SocialLoginWidget(fromPage: widget.fromPage),

                  if (manualLogin == 1) ...<Widget>[
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          child: Text('${'do_not_have_an_account'.tr} ',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 13.5, color: DirTokens.onSurfaceVariant)),
                        ),
                        TextButton(
                          onPressed: () {
                            signInPhoneController.clear();
                            signInPasswordController.clear();
                            Get.toNamed(RouteHelper.getSignUpRoute());
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: const Size(0, 36),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text('sign_up_here'.tr,
                              style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: DirTokens.primary)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        });
      }),
    );
  }

  /// Swaps between the password form and the one-time-code form, restoring
  /// whatever the user last signed in with.
  void _toggleLoginMedium(AuthController authController) {
    final String phoneWithoutCountryCode =
        PhoneVerificationHelper.getValidPhoneNumber(authController.getUserNumber());
    final String countryCode =
        PhoneVerificationHelper.getCountryCode(authController.getUserNumber());

    if (authController.selectedLoginMedium == LoginMedium.otp) {
      authController.toggleSelectedLoginMedium(loginMedium: LoginMedium.manual);
      signInPhoneController.text = phoneWithoutCountryCode != ""
          ? phoneWithoutCountryCode
          : authController.getUserNumber();
      authController.toggleIsNumberLogin(value: countryCode != "");
      authController.initCountryCode(countryCode: countryCode != "" ? countryCode : null);
      signInPasswordController.text = authController.getUserPassword();

      if (signInPasswordController.text.isEmpty) {
        signInPhoneController.text = "";
        authController.toggleIsNumberLogin(value: false);
      }
    } else {
      authController.toggleSelectedLoginMedium(loginMedium: LoginMedium.otp);
      authController.toggleIsNumberLogin(value: true);
      signInPasswordController.clear();
      signInPhoneController.text = phoneWithoutCountryCode;
      authController.initCountryCode(countryCode: countryCode != "" ? countryCode : null);
    }
  }

  _initializeController() {
    var authController = Get.find<AuthController>();
    String phoneWithoutCountryCode =
        PhoneVerificationHelper.getValidPhoneNumber(Get.find<AuthController>().getUserNumber());
    String countryCode =
        PhoneVerificationHelper.getCountryCode(Get.find<AuthController>().getUserNumber());

    var config = Get.find<SplashController>().configModel.content;
    var manualLogin = config?.customerLogin?.loginOption?.manualLogin ?? 1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (countryCode != "" && phoneWithoutCountryCode != "") {
        authController.toggleIsNumberLogin(value: true);
      } else {
        authController.toggleIsNumberLogin(value: false);
      }
      authController.toggleSelectedLoginMedium(loginMedium: LoginMedium.manual);
      authController.initCountryCode(countryCode: countryCode != "" ? countryCode : null);

      signInPhoneController.text = phoneWithoutCountryCode != ""
          ? phoneWithoutCountryCode
          : authController.isNumberLogin
              ? ""
              : Get.find<AuthController>().getUserNumber();
      signInPasswordController.text = Get.find<AuthController>().getUserPassword();

      if (manualLogin == 1 && signInPasswordController.text.isEmpty) {
        signInPhoneController.text = "";
        authController.initCountryCode();
        authController.toggleIsNumberLogin(value: false);
      }
    });
    authController.toggleRememberMe(value: false, shouldUpdate: false);
  }

  Future<bool> _existFromApp() async {
    if (widget.exitFromApp) {
      if (_canExit) {
        if (GetPlatform.isAndroid) {
          SystemNavigator.pop();
        } else if (GetPlatform.isIOS) {
          exit(0);
        } else {
          Navigator.pushNamed(context, RouteHelper.getInitialRoute());
        }
        return Future.value(false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('back_press_again_to_exit'.tr,
              style: const TextStyle(color: Colors.white)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        ));
        _canExit = true;
        Timer(const Duration(seconds: 2), () {
          _canExit = false;
        });
        return Future.value(false);
      }
    } else {
      return true;
    }
  }

  void _login(AuthController authController, var manualLogin, var otpLogin) async {
    if (customerSignInKey.currentState!.validate()) {
      var config = Get.find<SplashController>().configModel.content;

      SendOtpType type =
          config?.firebaseOtpVerification == 1 ? SendOtpType.firebase : SendOtpType.verification;

      String phone = PhoneVerificationHelper.getValidPhoneNumber(
          authController.countryDialCode + signInPhoneController.text.trim(),
          withCountryCode: true);

      if ((authController.selectedLoginMedium == LoginMedium.otp) ||
          (manualLogin == 0 && otpLogin == 1)) {
        authController
            .sendVerificationCode(
                identity: phone, identityType: "phone", type: type, checkUser: 0)
            .then((status) {
          if (status != null) {
            if (status.isSuccess!) {
              Get.toNamed(RouteHelper.getVerificationRoute(
                identity: phone,
                identityType: "phone",
                fromPage: config?.firebaseOtpVerification == 1 ? "firebase-otp" : "otp-login",
                firebaseSession: type == SendOtpType.firebase ? status.message : null,
              ));
            } else {
              customSnackBar(status.message.toString().capitalizeFirst);
            }
          }
        });
      } else {
        authController.login(
            fromPage: widget.fromPage,
            emailPhone: phone != "" ? phone : signInPhoneController.text.trim(),
            password: signInPasswordController.text.trim(),
            type: phone != "" ? "phone" : "email");
      }
    }
  }
}
