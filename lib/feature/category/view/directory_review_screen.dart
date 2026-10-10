import 'package:demandium/utils/core_export.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demandium/feature/category/controller/directory_controller.dart';
import 'package:demandium/common/widgets/dir_ui.dart';
import 'package:demandium/helper/route_helper.dart';

// ─── Brand Colors ──────────────────────────────────────────────
const Color _kPrimary   = Color(0xFF1A1A1B);
const Color _kGold      = Color(0xFFC5A059);
const Color _kGoldLight = Color(0xFFFDF6E8);
const Color _kNeutral   = Color(0xFFF4F7F9);

class DirectoryReviewScreen extends StatefulWidget {
  final String directoryId;
  final String directoryTitle;

  const DirectoryReviewScreen({
    super.key,
    required this.directoryId,
    required this.directoryTitle,
  });

  @override
  State<DirectoryReviewScreen> createState() => _DirectoryReviewScreenState();
}

class _DirectoryReviewScreenState extends State<DirectoryReviewScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  List<String> get _ratingLabels => <String>[
        '',
        'rating_terrible'.tr,
        'rating_poor'.tr,
        'rating_average'.tr,
        'rating_good'.tr,
        'rating_excellent'.tr,
      ];

  @override
  void dispose() {
    _commentController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /// Shown when a guest tries to review.
  void _promptSignIn() {
    Get.dialog<void>(
      DirThemed(
        child: AlertDialog(
          title: Text('login_required'.tr),
          content: Text('login_required_to_review'.tr),
          actions: <Widget>[
            TextButton(onPressed: () => Get.back<void>(), child: Text('cancel'.tr)),
            ElevatedButton(
              onPressed: () {
                Get.back<void>();
                Get.toNamed(RouteHelper.getSignInRoute());
              },
              child: Text('sign_in'.tr),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kNeutral,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: _kPrimary),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('write_a_review'.tr, style: robotoBold.copyWith(fontSize: 16, color: _kPrimary)),
            Text(widget.directoryTitle, style: robotoRegular.copyWith(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
        centerTitle: false,
      ),
      body: GetBuilder<DirectoryController>(builder: (ctrl) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Rating stars card ───
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'overall_experience'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: 11,
                              color: Colors.grey[500],
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (i) {
                              return GestureDetector(
                                onTap: () => setState(() => _rating = i + 1),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Icon(
                                    i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                    color: i < _rating ? _kGold : Colors.grey[350],
                                    size: 42,
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 12),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              _rating > 0 ? _ratingLabels[_rating] : 'tap_to_rate'.tr,
                              key: ValueKey(_rating),
                              style: robotoMedium.copyWith(
                                fontSize: 14,
                                color: _rating > 0 ? _kGold : Colors.grey[400],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    
                    // ─── Reviewer Name ───
                    Text(
                      'your_name'.tr,
                      style: robotoBold.copyWith(fontSize: 14, color: _kPrimary),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: robotoRegular.copyWith(fontSize: 14, color: _kPrimary),
                        decoration: InputDecoration(
                          hintText: 'your_name_hint'.tr,
                          hintStyle: robotoRegular.copyWith(
                            fontSize: 13,
                            color: Colors.grey[400],
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: _kGold, width: 1.5),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ─── Review text ───
                    Text(
                      'your_review'.tr,
                      style: robotoBold.copyWith(fontSize: 14, color: _kPrimary),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                      ),
                      child: TextField(
                        controller: _commentController,
                        maxLines: 6,
                        style: robotoRegular.copyWith(fontSize: 14, color: _kPrimary),
                        decoration: InputDecoration(
                          hintText: 'your_review_hint'.tr,
                          hintStyle: robotoRegular.copyWith(
                            fontSize: 13,
                            color: Colors.grey[400],
                          ),
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: _kGold, width: 1.5),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ─── Tips ───
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _kGoldLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _kGold.withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline, color: _kGold, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your review helps others find great places. Be honest and helpful!',
                              style: robotoRegular.copyWith(fontSize: 12, color: const Color(0xFF8B6914)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Submit bar ───
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -4))],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: ctrl.isLoading
                      ? null
                      : () {
                          // A guest used to get the server's raw
                          // "Unauthenticated." message; ask them to sign in.
                          if (!Get.find<AuthController>().isLoggedIn()) {
                            _promptSignIn();
                            return;
                          }
                          if (_rating == 0) {
                            customSnackBar('please_select_rating'.tr, type: ToasterMessageType.error);
                            return;
                          }
                          if (_commentController.text.trim().isEmpty) {
                            customSnackBar('please_write_a_review'.tr, type: ToasterMessageType.error);
                            return;
                          }
                          if (_nameController.text.trim().isEmpty) {
                            customSnackBar('please_enter_your_name'.tr, type: ToasterMessageType.error);
                            return;
                          }
                          ctrl.submitDirectoryReview(
                            widget.directoryId,
                            _rating,
                            _commentController.text.trim(),
                            _nameController.text.trim(),
                          ).then((bool success) {
                            if (success) Get.back();
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kPrimary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: ctrl.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.rate_review_outlined, size: 18),
                            const SizedBox(width: 8),
                            Text('submit_review'.tr, style: robotoBold.copyWith(fontSize: 15, color: Colors.white)),
                          ],
                        ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
