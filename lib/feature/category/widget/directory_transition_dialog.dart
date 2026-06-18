import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';

class DirectoryTransitionDialog extends StatelessWidget {
  final bool isEnteringDirectory;
  final Function() onConfirm;

  const DirectoryTransitionDialog({
    super.key,
    required this.isEnteringDirectory,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Icon
          Container(
            height: 64, width: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isEnteringDirectory
                    ? [const Color(0xFFFFD57A), const Color(0xFFC5A059)]
                    : [const Color(0xFF4A90D9), const Color(0xFF0052CC)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isEnteringDirectory ? const Color(0xFFC5A059) : const Color(0xFF0052CC)).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              isEnteringDirectory ? Icons.storefront_rounded : Icons.home_repair_service_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 24),
          // Title
          Text(
            'confirm_navigation'.tr,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge + 2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Subtitle
          Text(
            isEnteringDirectory
                ? 'you_will_be_redirected_to_directory_listing'.tr
                : 'you_will_be_redirected_to_services'.tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodySmall?.color,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          // Buttons
          Row(children: [
            Expanded(
              child: InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'no'.tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),
            Expanded(
              child: InkWell(
                onTap: () {
                  Get.back();
                  onConfirm();
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: isEnteringDirectory
                          ? [const Color(0xFF1A1A1B), const Color(0xFF2D2D2E)]
                          : [const Color(0xFF0052CC), const Color(0xFF4A90D9)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isEnteringDirectory ? const Color(0xFF1A1A1B) : const Color(0xFF0052CC)).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'yes'.tr,
                    style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
