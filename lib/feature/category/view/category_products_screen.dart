import 'package:demandium/utils/dimensions.dart';
import 'package:demandium/utils/styles.dart';
import 'package:demandium/common/widgets/custom_image.dart';
import 'package:demandium/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> products;
  final String currency;
  final String? initialCategory;

  const CategoryProductsScreen({
    Key? key,
    required this.title,
    required this.products,
    required this.currency,
    this.initialCategory,
  }) : super(key: key);

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  String selectedCategory = 'All';
  List<String> categories = ['All'];

  @override
  void initState() {
    super.initState();
    _extractCategories();
    if (widget.initialCategory != null && categories.contains(widget.initialCategory)) {
      selectedCategory = widget.initialCategory!;
    }
  }

  void _extractCategories() {
    Set<String> cats = {};
    for (var prod in widget.products) {
      if (prod['category'] != null && prod['category'].toString().trim().isNotEmpty) {
        cats.add(prod['category'].toString().trim());
      }
    }
    categories.addAll(cats.toList()..sort());
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredProducts = widget.products;
    if (selectedCategory != 'All') {
      filteredProducts = widget.products.where((p) => p['category']?.toString().trim() == selectedCategory).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          widget.title,
          style: robotoBold.copyWith(fontSize: 18, color: Colors.black87),
        ),
      ),
      body: Column(
        children: [
          if (categories.length > 1)
            Container(
              height: 50,
              color: Colors.white,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = selectedCategory == cat;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = cat;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF15803d) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF15803d) : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: robotoMedium.copyWith(
                            fontSize: 13,
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filteredProducts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final prod = filteredProducts[index];
                final String title = prod['title']?.toString() ?? '';
                final String price = prod['price']?.toString() ?? '';
                final String desc = prod['description']?.toString() ?? '';
                final String category = prod['category']?.toString() ?? '';
                String image = prod['image']?.toString() ?? '';

                if (image.isNotEmpty && !image.startsWith('http')) {
                  image = '${AppConstants.baseUrl}/storage/app/public/directory/dynamic/$image';
                }

                bool hasDiscount = prod['has_discount'] == '1' || prod['has_discount'] == 1 || prod['has_discount'] == true;
                bool fastDelivery = prod['fast_delivery'] == '1' || prod['fast_delivery'] == 1 || prod['fast_delivery'] == true;
                final String deliveryTime = prod['delivery_time']?.toString() ?? '';
                final String discountPercent = prod['discount_percent']?.toString() ?? '';

                double originalPrice = double.tryParse(price) ?? 0;
                double discountPct = double.tryParse(discountPercent) ?? 0;
                double finalPrice = hasDiscount && discountPct > 0
                    ? originalPrice * (1 - discountPct / 100)
                    : originalPrice;

                return Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Image
                      Container(
                        width: 110,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                              ),
                              child: image.isNotEmpty
                                  ? CustomImage(
                                      image: image,
                                      fit: BoxFit.cover,
                                    )
                                  : const Center(child: Icon(Icons.image_rounded, color: Colors.grey)),
                            ),
                            if (hasDiscount && discountPct > 0)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.red[600],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '-${discountPct.toStringAsFixed(0)}%',
                                    style: robotoBold.copyWith(fontSize: 10, color: Colors.white),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: robotoBold.copyWith(fontSize: 14, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                              if (category.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(category, style: robotoRegular.copyWith(fontSize: 11, color: const Color(0xFF15803d))),
                              ],
                              if (desc.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(desc, style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                              const Spacer(),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (hasDiscount && discountPct > 0)
                                        Text(
                                          '${widget.currency} $price',
                                          style: robotoRegular.copyWith(
                                            fontSize: 11,
                                            color: Colors.grey[400],
                                            decoration: TextDecoration.lineThrough,
                                          ),
                                        ),
                                      Text(
                                        '${widget.currency} ${(hasDiscount && discountPct > 0) ? finalPrice.toStringAsFixed(2) : price}',
                                        style: robotoBold.copyWith(
                                          fontSize: 15,
                                          color: hasDiscount && discountPct > 0 ? Colors.red[700] : const Color(0xFF15803d),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (fastDelivery)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFfef3c7),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFFfde68a)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.two_wheeler_rounded, color: Color(0xFFd97706), size: 12),
                                          const SizedBox(width: 4),
                                          Text(
                                            deliveryTime.isNotEmpty ? deliveryTime : 'Fast',
                                            style: robotoBold.copyWith(fontSize: 9, color: const Color(0xFFd97706)),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
