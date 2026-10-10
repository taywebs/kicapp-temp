import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:demandium/utils/core_export.dart';
import 'package:demandium/common/widgets/dir_ui.dart';
import 'package:demandium/feature/category/controller/directory_controller.dart';
import 'package:demandium/feature/category/model/directory_model.dart';
import 'package:demandium/feature/category/view/directory_details_screen.dart';

/// Saved tab: listings the user bookmarked anywhere in the Directory.
class DirectorySavedScreen extends StatelessWidget {
  const DirectorySavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DirTokens.background,
      appBar: DirAppBar(title: 'saved_listings'.tr, showBack: false),
      body: GetBuilder<DirectoryController>(
        builder: (DirectoryController controller) {
          final List<DirectoryModel> saved = controller.savedListings;

          if (saved.isEmpty) {
            return DirEmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'no_saved_listings'.tr,
              message: 'no_saved_listings_desc'.tr,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
            itemCount: saved.length,
            separatorBuilder: (BuildContext _, int __) => const SizedBox(height: 11),
            itemBuilder: (BuildContext context, int index) {
              final DirectoryModel listing = saved[index];
              return _SavedCard(
                listing: listing,
                onTap: () {
                  if (listing.id == null || listing.id!.isEmpty) return;
                  Get.to(() => DirectoryDetailsScreen(
                        directoryId: listing.id!,
                        categoryName: listing.category?['name']?.toString() ?? '',
                        initialModel: listing,
                      ));
                },
                onRemove: () => controller.toggleSavedWithFeedback(listing),
              );
            },
          );
        },
      ),
    );
  }
}

class _SavedCard extends StatelessWidget {
  const _SavedCard({
    required this.listing,
    required this.onTap,
    required this.onRemove,
  });

  final DirectoryModel listing;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final String subtitle =
        listing.category?['name']?.toString() ?? (listing.address ?? '');
    return Material(
      color: DirTokens.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DirTokens.radiusLarge),
        side: const BorderSide(color: DirTokens.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(DirTokens.radius),
                child: SizedBox(
                  width: 78,
                  height: 78,
                  child: CustomImage(image: listing.bannerUrl ?? '', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(listing.title ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: DirTokens.onSurface)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11.5, color: DirTokens.onSurfaceVariant)),
                    if (listing.averageRating != null) ...<Widget>[
                      const SizedBox(height: 6),
                      Text('${listing.averageRating!.toStringAsFixed(1)} ★',
                          style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: DirTokens.secondary)),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                tooltip: 'remove_from_saved'.tr,
                icon: const Icon(Icons.bookmark_rounded, color: DirTokens.secondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
