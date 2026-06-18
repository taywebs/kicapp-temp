import 'dart:convert';

class DirectoryModel {
  String? id;
  String? providerId;
  String? categoryId;
  String? title;
  String? description;
  String? address;
  String? city;
  String? latitude;
  String? longitude;
  String? coverImage;
  String? coverImageFullPath;
  String? thumbnail;
  List<String>? images;
  List<String>? imagesFullPath;
  dynamic dynamicData;
  List<String>? features;
  double? averageRating;
  String? priceLevel;
  Map<String, dynamic>? provider;
  Map<String, dynamic>? category;

    String? phone;
    String? website;

  DirectoryModel({
    this.id,
    this.providerId,
    this.categoryId,
    this.title,
    this.description,
    this.address,
    this.city,
    this.latitude,
    this.longitude,
    this.phone,
    this.website,
    this.coverImage,
    this.coverImageFullPath,
    this.thumbnail,
    this.images,
    this.imagesFullPath,
    this.dynamicData,
    this.features,
    this.averageRating,
    this.priceLevel,
    this.provider,
    this.category,
  });

  DirectoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    providerId = json['provider_id'];
    categoryId = json['category_id'];
    title = json['title'];
    description = json['description'];
    address = json['address'];
    city = json['city'];
    latitude = json['latitude']?.toString();
    longitude = json['longitude']?.toString();
    phone = json['phone']?.toString();
    website = json['website']?.toString();
    coverImage = json['cover_image'] ?? json['thumbnail'];
    coverImageFullPath = json['cover_image_full_path'];
    thumbnail = json['thumbnail'];
    if (json['images'] != null) {
      if (json['images'] is List) {
        images = List<String>.from(json['images']);
      } else if (json['images'] is String) {
        try {
          images = List<String>.from((json['images'] as String).replaceAll('[', '').replaceAll(']', '').replaceAll('"', '').split(',').where((s) => s.isNotEmpty));
        } catch (_) {
          images = null;
        }
      }
    }
    // images_full_path from API (array of full URLs)
    if (json['images_full_path'] != null && json['images_full_path'] is List) {
      imagesFullPath = List<String>.from(json['images_full_path']);
    }
    // dynamic_data holds the schema info
    if (json['dynamic_data'] != null) {
      dynamic raw = json['dynamic_data'];
      if (raw is Map) {
        dynamicData = raw;
      } else if (raw is List) {
        dynamicData = raw;
      } else if (raw is String && raw.isNotEmpty) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map || decoded is List) {
            dynamicData = decoded;
          } else {
            dynamicData = jsonDecode(decoded.toString());
          }
        } catch (_) {
          dynamicData = null;
        }
      }
    }

    // attributes holds features
    if (json['attributes'] != null) {
      if (json['attributes'] is List) {
        features = List<String>.from(json['attributes']);
      } else if (json['attributes'] is String) {
        try {
          final decoded = jsonDecode(json['attributes']);
          if (decoded is List) {
            features = List<String>.from(decoded);
          }
        } catch (_) {
          features = null;
        }
      }
    }
    averageRating = json['average_rating'] != null ? double.tryParse(json['average_rating'].toString()) : null;
    priceLevel = json['price_level'];
    if (json['provider'] != null && json['provider'] is Map) {
      provider = Map<String, dynamic>.from(json['provider']);
    }
    if (json['category'] != null && json['category'] is Map) {
      category = Map<String, dynamic>.from(json['category']);
    }
  }

  // Logo URL - provider logo
  String? get logoUrl {
    if (provider != null && provider!['logo_full_path'] != null) {
      return provider!['logo_full_path'].toString();
    }
    return null;
  }

  // Banner URL - the listing cover
  String? get bannerUrl {
    if (coverImageFullPath != null) return coverImageFullPath;
    if (thumbnail != null) {
      return thumbnail;
    }
    return null;
  }

  // Gallery full paths for slider
  List<String> get galleryFullPaths {
    // Prefer images_full_path from API (full URLs)
    if (imagesFullPath != null && imagesFullPath!.isNotEmpty) {
      return imagesFullPath!;
    }
    if (images == null || images!.isEmpty) return [];
    return images!;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider_id': providerId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'phone': phone,
      'website': website,
      'cover_image': coverImage,
      'cover_image_full_path': coverImageFullPath,
      'thumbnail': thumbnail,
      'images': images,
      'images_full_path': imagesFullPath,
      'dynamic_data': dynamicData,
      'features': features,
      'average_rating': averageRating,
      'price_level': priceLevel,
      'provider': provider,
      'category': category,
    };
  }
}
