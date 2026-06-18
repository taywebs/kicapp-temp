import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class ProviderCard extends StatelessWidget {
  final ProviderData provider;
  final String subCategoryId;
  const ProviderCard({super.key, required this.provider,
    required this.subCategoryId});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.toNamed(RouteHelper.getProviderServicesRoute(
        //  '3a1bcaaa-8690-47fd-8579-8b633558e9fd',
             provider.id!,
            provider.companyName ?? 'Provider'
          //  ,'dcba03e6-100d-417c-be1a-c6b56b2bf2e2'
           // widget.categoryId
            ,subCategoryId//'ab005cb4-d8a3-4249-a9aa-97d153f10720'

        ));
        // يمكنك إضافة الانتقال لصفحة المزود هنا
      // Get.toNamed(RouteHelper.getProviderDetailsRoute(provider.id!));
       // Get.find<ServiceController>().cleanSubCategory();
       // Get.toNamed(RouteHelper.allServiceScreenRoute(categoryModel!.id!.toString()));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: Get.isDarkMode ? null : [BoxShadow(color: Colors.grey[200]!, blurRadius: 5, spreadRadius: 1)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.radiusDefault)),
              child: CustomImage(
                image: provider.logoFullPath ?? '',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // معلومات المزود
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.companyName ?? 'unknown_provider'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                      color:Get.isDarkMode ? Colors.white:Theme.of(context).colorScheme.primary                 ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis
                  ),

                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  // التقييم
                  Row(
                    children: [
                      Icon(Icons.star, color: Theme.of(context).colorScheme.primary, size: 16),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(
                        (provider.avgRating ?? 0).toStringAsFixed(1),
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                              color:Get.isDarkMode ? Colors.white:Theme.of(context).colorScheme.primary                 ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(
                        '(${provider.ratingCount ?? 0})',
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                              color:Get.isDarkMode ? Colors.white:Theme.of(context).colorScheme.primary                 ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis
                      ),
                    ],
                  ),

                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),


                  if (provider.companyAddress != null)
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.6)),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Expanded(
                          child: Text(
                            provider.companyAddress   ?? '',
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                                  color:Get.isDarkMode ? Colors.white:Theme.of(context).colorScheme.primary                 ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),


                  if (provider.isActive != null)
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color:   Colors.green  ,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Text(
                            'available'.tr  ,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                                color:Get.isDarkMode ? Colors.white:Theme.of(context).colorScheme.primary                 ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}