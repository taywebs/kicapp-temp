import 'package:flutter/material.dart';

class CategoryModel {
  String? id;
  String? parentId;
  String? name;
  String? image;
  String? imageFullPath;
  int? position;
  String? description;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  int? serviceCount;
  String? categoryType;
  dynamic dynamicSchema;
  String? banner;
  String? bannerFullPath;
  GlobalKey? globalKey;

  CategoryModel(
      {this.id,
        this.parentId,
        this.name,
        this.image,
        this.imageFullPath,
        this.position,
        this.description,
        this.isActive,
        this.createdAt,
        this.updatedAt,
        this.serviceCount,
        this.categoryType,
        this.dynamicSchema,
        this.banner,
        this.bannerFullPath,
        this.globalKey,
      });

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parentId = json['parent_id'];
    name = json['name'];
    image = json['image'];
    imageFullPath = json['image_full_path'];

    position = json['position'];
    description = json['description'];
    isActive = int.tryParse(json['is_active'].toString()) == 1 ? true : false;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    serviceCount = int.tryParse(json['services_count'].toString());
    categoryType = json['category_type'] ?? 'service';
    dynamicSchema = json['dynamic_schema'];
    banner = json['banner'];
    bannerFullPath = json['banner_full_path'];
    globalKey = GlobalKey(debugLabel: json['id']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['parent_id'] = parentId;
    data['name'] = name;
    data['image'] = image;
    data['image_full_path'] = imageFullPath;
    data['position'] = position;
    data['description'] = description;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['services_count'] = serviceCount;
    data['category_type'] = categoryType;
    data['dynamic_schema'] = dynamicSchema;
    data['banner'] = banner;
    data['banner_full_path'] = bannerFullPath;
    return data;
  }
}
