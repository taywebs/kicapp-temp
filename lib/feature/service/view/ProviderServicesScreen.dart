import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';


class ProviderServicesScreen extends StatelessWidget {
  final String providerId;
  final String providerName;
  final String subCategoryId;

  const ProviderServicesScreen({
    super.key,
    required this.providerId,
    required this.providerName,
    required this.subCategoryId,
  });

  @override
  Widget build(BuildContext context) {
    Get.find<ServiceController>().getProviderServicesByCategory(
        providerId,
        subCategoryId,
        1,
        true
    );

    return Scaffold(
      appBar: CustomAppBar(title: '${providerName} - ${'services'.tr}'),
      body: GetBuilder<ServiceController>(
        builder: (serviceController) {
          if (serviceController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (serviceController.providerServices == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('failed_to_load_data'.tr),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => serviceController.getProviderServicesByCategory(
                        providerId,
                        subCategoryId,
                        1,
                        true
                    ),
                    child: Text('retry'.tr),
                  ),
                ],
              ),
            );
          }

          if (serviceController.providerServices!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text('no_services_found'.tr),
                ],
              ),
            );
          }

          return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveHelper.isMobile(context) ? 2 : ResponsiveHelper.isTab(context) ? 3 : 4,
          childAspectRatio: 0.8,
          mainAxisSpacing: Dimensions.paddingSizeDefault,
          crossAxisSpacing: Dimensions.paddingSizeDefault,
          mainAxisExtent: 300,
          ),
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall,
            ),
          //  itemCount: categoryController.providerList!.length,
          //  itemBuilder: (context, index) {
          //  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            itemCount: serviceController.providerServices!.length,
            itemBuilder: (context, index) {
              Service service = serviceController.providerServices![index];
              return ServiceWidgetVertical(service: service, fromType: '',);
            },
          );
        },
      ),
    );
  }
}
// class ProviderServicesScreen extends StatefulWidget {
//   final String providerId;
//   final String providerName;
//   final String subCategoryId;
//
//   const ProviderServicesScreen({
//     super.key,
//     required this.providerId,
//     required this.providerName,
//     required this.subCategoryId,
//   });
//
//   @override
//   State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
// }
//
// class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
//   final ScrollController _scrollController = ScrollController();
//   int _currentPage = 1;
//   bool _isLoadingMore = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadInitialServices();
//     _scrollController.addListener(_scrollListener);
//   }
//
//   void _loadInitialServices() {
//     Get.find<ServiceController>().getProviderServicesByCategory(
//         widget.providerId,
//         widget.subCategoryId,
//         1,
//         true
//     );
//   }
//
//   void _loadMoreServices() {
//     if (_isLoadingMore) return;
//
//     _isLoadingMore = true;
//     _currentPage++;
//
//     Get.find<ServiceController>().getProviderServicesByCategory(
//         widget.providerId,
//         widget.subCategoryId,
//         _currentPage,
//         false
//     ).then((_) {
//       _isLoadingMore = false;
//     });
//   }
//
//   void _scrollListener() {
//     if (_scrollController.position.pixels ==
//         _scrollController.position.maxScrollExtent) {
//       _loadMoreServices();
//     }
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(title: '${widget.providerName} - ${'services'.tr}'),
//       body: GetBuilder<ServiceController>(
//         builder: (serviceController) {
//           if (serviceController.isLoading && serviceController.providerServices == null) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (serviceController.providerServices == null) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text('failed_to_load_data'.tr),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _loadInitialServices,
//                     child: Text('retry'.tr),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           if (serviceController.providerServices!.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.error_outline, size: 50, color: Colors.grey),
//                   const SizedBox(height: 20),
//                   Text('no_services_found'.tr),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _loadInitialServices,
//                     child: Text('retry'.tr),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           return RefreshIndicator(
//             onRefresh: () async {
//               _loadInitialServices();
//             },
//             child: ListView.builder(
//               controller: _scrollController,
//               padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
//               itemCount: serviceController.providerServices!.length + 1,
//               itemBuilder: (context, index) {
//                 if (index < serviceController.providerServices!.length) {
//                   return ServiceWidget(
//                     service: serviceController.providerServices![index],
//                   );
//                 } else {
//                   return _isLoadingMore
//                       ? const Center(child: Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: CircularProgressIndicator(),
//                   ))
//                       : const SizedBox();
//                 }
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }