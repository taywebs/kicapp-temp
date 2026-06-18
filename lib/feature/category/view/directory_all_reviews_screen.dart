import 'package:demandium/utils/core_export.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demandium/feature/category/controller/directory_controller.dart';

const Color _kPrimary   = Color(0xFF1A1A1B);
const Color _kGold      = Color(0xFFC5A059);
const Color _kGoldLight = Color(0xFFFDF6E8);
const Color _kNeutral   = Color(0xFFF4F7F9);

class DirectoryAllReviewsScreen extends StatelessWidget {
  final String directoryId;
  final String directoryTitle;

  const DirectoryAllReviewsScreen({
    super.key,
    required this.directoryId,
    required this.directoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kNeutral,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _kPrimary),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reviews', style: robotoBold.copyWith(fontSize: 16, color: _kPrimary)),
            Text(directoryTitle, style: robotoRegular.copyWith(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
      body: GetBuilder<DirectoryController>(builder: (ctrl) {
        final List<dynamic> reviews = ctrl.reviewsList ?? [];
        final double avgRating = double.tryParse(ctrl.ratingInfo?['average_rating']?.toString() ?? '0') ?? 0;
        final int reviewCount = ctrl.ratingInfo?['review_count'] ?? reviews.length;

        if (reviews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('No reviews yet', style: robotoBold.copyWith(fontSize: 18, color: Colors.grey[600])),
                const SizedBox(height: 8),
                Text('Be the first to review!', style: robotoRegular.copyWith(fontSize: 13, color: Colors.grey[500])),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ─── Summary banner ───
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: _kGoldLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kGold.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        avgRating.toStringAsFixed(1),
                        style: robotoBold.copyWith(fontSize: 52, color: _kGold, height: 1),
                      ),
                      Row(
                        children: List.generate(5, (i) => Icon(
                          i < avgRating.floor()
                              ? Icons.star
                              : (i < avgRating ? Icons.star_half : Icons.star_border),
                          color: _kGold, size: 20,
                        )),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$reviewCount reviews',
                        style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ─── Review list ───
            ...reviews.map((rev) => _buildReviewCard(context, rev)),
          ],
        );
      }),
    );
  }

  Widget _buildReviewCard(BuildContext context, dynamic rev) {
    String name = 'User';
    String comment = '';
    String date = '';
    double rating = 0;

    try {
      if (rev['customer'] != null) {
        name = '${rev['customer']['first_name'] ?? ''} ${rev['customer']['last_name'] ?? ''}'.trim();
        if (name.isEmpty) name = 'Anonymous';
      }
      comment = rev['review_comment']?.toString() ?? '';
      date = rev['created_at']?.toString().substring(0, 10) ?? '';
      rating = double.tryParse(rev['review_rating']?.toString() ?? '0') ?? 0;
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _kGold.withOpacity(0.12),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: robotoBold.copyWith(fontSize: 16, color: _kGold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: robotoBold.copyWith(fontSize: 14, color: _kPrimary)),
                      if (date.isNotEmpty)
                        Text(date, style: robotoRegular.copyWith(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < rating.round() ? Icons.star : Icons.star_border,
                  color: _kGold, size: 15,
                )),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _kNeutral,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '"$comment"',
                style: robotoRegular.copyWith(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                  height: 1.55,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
