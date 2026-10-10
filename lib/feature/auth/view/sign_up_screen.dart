import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:demandium/common/widgets/dir_ui.dart';
import 'package:demandium/feature/auth/widgets/dir_auth_scaffold.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailController = TextEditingController();
  var phoneController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  late final GlobalKey<FormState> customerSignUpKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    Get.find<AuthController>().initCountryCode();
    Get.find<AuthController>().toggleTerms(value: false, shouldUpdate: false);
  }

  @override
  void dispose() {
    super.dispose();
    _clearControllerValue();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          AuthController authController = Get.find();
          authController.acceptTerms == true
              ? authController.toggleTerms()
              : authController.acceptTerms;
          return;
        }
      },
      child: GetBuilder<AuthController>(
        builder: (AuthController authController) {
          final config = Get.find<SplashController>().configModel.content;
          final socialLogin = config?.customerLogin?.loginOption?.socialMediaLogin;

          return DirAuthScaffold(
            title: 'create_account'.tr,
            subtitle: 'sign_up_subtitle'.tr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Form(
                  key: customerSignUpKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // ── name row ──
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                DirFieldLabel('first_name'.tr),
                                CustomTextField(
                                  isShowBorder: true,
                                  borderRadius: DirTokens.radius,
                                  hintText: 'enter_your_first_name'.tr,
                                  controller: firstNameController,
                                  isAutoFocus: false,
                                  focusNode: _firstNameFocus,
                                  nextFocus: _lastNameFocus,
                                  inputType: TextInputType.name,
                                  capitalization: TextCapitalization.words,
                                  onValidate: (String? value) =>
                                      FormValidation().isValidFirstName(value!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                DirFieldLabel('last_name'.tr),
                                CustomTextField(
                                  isShowBorder: true,
                                  borderRadius: DirTokens.radius,
                                  hintText: 'enter_your_last_name'.tr,
                                  controller: lastNameController,
                                  focusNode: _lastNameFocus,
                                  nextFocus: _emailFocus,
                                  inputType: TextInputType.name,
                                  capitalization: TextCapitalization.words,
                                  onValidate: (String? value) =>
                                      FormValidation().isValidLastName(value!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      DirFieldLabel('email_address'.tr),
                      CustomTextField(
                        isShowBorder: true,
                        borderRadius: DirTokens.radius,
                        hintText: 'enter_email_address'.tr,
                        controller: emailController,
                        focusNode: _emailFocus,
                        nextFocus: _phoneFocus,
                        inputType: TextInputType.emailAddress,
                        onValidate: (String? value) => FormValidation().isValidEmail(value),
                      ),
                      const SizedBox(height: 16),

                      DirFieldLabel('phone'.tr),
                      CustomTextField(
                        isShowBorder: true,
                        borderRadius: DirTokens.radius,
                        onCountryChanged: (CountryCode countryCode) {
                          authController.countryDialCode = countryCode.dialCode!;
                        },
                        countryDialCode: authController.countryDialCode,
                        hintText: 'enter_phone_number'.tr,
                        controller: phoneController,
                        focusNode: _phoneFocus,
                        nextFocus: _passwordFocus,
                        inputType: TextInputType.phone,
                        isRequired: false,
                        onValidate: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'enter_phone_number'.tr;
                          }
                          return FormValidation()
                              .isValidPhone(authController.countryDialCode + value, fromAuthPage: true);
                        },
                      ),
                      const SizedBox(height: 16),

                      DirFieldLabel('password'.tr),
                      CustomTextField(
                        isShowBorder: true,
                        borderRadius: DirTokens.radius,
                        hintText: '••••••••',
                        controller: passwordController,
                        focusNode: _passwordFocus,
                        nextFocus: _confirmPasswordFocus,
                        inputType: TextInputType.visiblePassword,
                        isPassword: true,
                        onValidate: (String? value) => FormValidation().isValidPassword(value!),
                      ),
                      const SizedBox(height: 16),

                      DirFieldLabel('confirm_password'.tr),
                      CustomTextField(
                        isShowBorder: true,
                        borderRadius: DirTokens.radius,
                        hintText: '••••••••',
                        controller: confirmPasswordController,
                        focusNode: _confirmPasswordFocus,
                        inputType: TextInputType.visiblePassword,
                        inputAction: TextInputAction.done,
                        isPassword: true,
                        onValidate: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'this_field_can_not_empty'.tr;
                          }
                          return FormValidation().isValidConfirmPassword(
                            passwordController.text,
                            confirmPasswordController.text,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                ConditionCheckBox(
                  checkBoxValue: authController.acceptTerms,
                  onTap: (bool? value) {
                    if (customerSignUpKey.currentState?.validate() == true) {
                      authController.toggleTerms(value: true);
                    } else {
                      authController.toggleTerms(value: false);
                    }
                  },
                ),

                const SizedBox(height: 18),
                DirButton(
                  label: 'sign_up'.tr,
                  loading: authController.isLoading,
                  onPressed: authController.acceptTerms &&
                          customerSignUpKey.currentState?.validate() == true
                      ? () => _register(authController)
                      : null,
                ),

                if (socialLogin == 1) ...<Widget>[
                  const SizedBox(height: 18),
                  const DirOrDivider(),
                  const SocialLoginWidget(fromPage: RouteHelper.home),
                ],

                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Text('${'already_have_an_account'.tr} ',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 13.5, color: DirTokens.onSurfaceVariant)),
                    ),
                    TextButton(
                      onPressed: () => Get.toNamed(RouteHelper.getSignInRoute()),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: const Size(0, 36),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('sign_in_here'.tr,
                          style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: DirTokens.primary)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _register(AuthController authController) async {
    if (customerSignUpKey.currentState!.validate()) {
      String numberWithCountryCode = PhoneVerificationHelper.getValidPhoneNumber(
          authController.countryDialCode + phoneController.value.text,
          withCountryCode: true);

      final SignUpBody signUpBody = SignUpBody(
        fName: firstNameController.value.text.trim(),
        lName: lastNameController.value.text.trim(),
        email: emailController.value.text.trim(),
        phone: numberWithCountryCode.trim(),
        password: passwordController.value.text.trim(),
        confirmPassword: confirmPasswordController.value.text.trim(),
      );

      authController.registration(signUpBody: signUpBody);
    }
  }

  _clearControllerValue() {
    firstNameController.text = "";
    lastNameController.text = "";
    emailController.text = "";
    phoneController.text = "";
    passwordController.text = "";
    confirmPasswordController.text = "";
  }
}
