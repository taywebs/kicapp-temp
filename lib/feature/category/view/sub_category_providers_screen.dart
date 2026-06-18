import 'package:demandium/feature/category/view/provider_card.dart';
import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class SubCategoryProvidersScreen extends StatefulWidget {
  final String subCategoryId;
  final String subCategoryName;

  const SubCategoryProvidersScreen({
    super.key,
    required this.subCategoryId,
    required this.subCategoryName,
  });

  @override
  State<SubCategoryProvidersScreen> createState() => _SubCategoryProvidersScreenState();

}

class _SubCategoryProvidersScreenState extends State<SubCategoryProvidersScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<CategoryController>().getProviderBasedOnSubcategory(widget.subCategoryId, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
      appBar: CustomAppBar(title: widget.subCategoryName),
      body: GetBuilder<CategoryController>(
        builder: (categoryController) {
          return FooterBaseView(
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Column(
                children: [
                  // عنوان الصفحة
                  Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    child: Text(
                      'مزودي الخدمة' ,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                          color:Get.isDarkMode ? Colors.white:Theme.of(context).colorScheme.primary                 ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis
                    ),
                  ),

                  // قائمة المزودين
                  if (categoryController.providerList != null)
                    categoryController.providerList!.isNotEmpty
                        ? GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : ResponsiveHelper.isTab(context) ? 3 : 4,
                        childAspectRatio: 0.8,
                        mainAxisSpacing: Dimensions.paddingSizeDefault,
                        crossAxisSpacing: Dimensions.paddingSizeDefault,
                        mainAxisExtent: 244,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                        vertical: Dimensions.paddingSizeSmall,
                      ),
                      itemCount: categoryController.providerList!.length,
                      itemBuilder: (context, index) {
                        return ProviderCard(
                          provider: categoryController.providerList![index],
                          subCategoryId: widget.subCategoryId,
                        );
                      },
                    )
                        : NoDataScreen(
                      text: 'no_provider_found'.tr,
                      type: NoDataType.provider,
                    )
                  else
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}