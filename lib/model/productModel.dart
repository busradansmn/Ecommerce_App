import 'package:hive/hive.dart';

part 'productModel.g.dart';

@HiveType(typeId: 0)
class ProductList extends HiveObject {
  @HiveField(0)
  final List<Product> products;

  @HiveField(1)
  final int total;

  @HiveField(2)
  final int skip;

  @HiveField(3)
  final int limit;

  ProductList({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductList.fromJson(Map<String, dynamic> json) {
    return ProductList(
      products: (json["products"] as List<dynamic>)
          .map((e) => Product.fromJson(e))
          .toList(),
      total: json["total"] ?? 0,
      skip: json["skip"] ?? 0,
      limit: json["limit"] ?? 0,
    );
  }
}

// ========================================

@HiveType(typeId: 1)
class Product extends HiveObject {
  @HiveField(0)
  final int? id;

  @HiveField(1)
  final String? title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String? category;

  @HiveField(4)
  final double? price;

  @HiveField(5)
  final double? discountPercentage;

  @HiveField(6)
  final double? rating;

  @HiveField(7)
  final int? stock;

  @HiveField(8)
  final List<String>? tags;

  @HiveField(9)
  final String? brand;

  @HiveField(10)
  final String? sku;

  @HiveField(11)
  final int? weight;

  @HiveField(12)
  final Dimensions? dimensions;

  @HiveField(13)
  final String? warrantyInformation;

  @HiveField(14)
  final String? shippingInformation;

  @HiveField(15)
  final String? availabilityStatus;

  @HiveField(16)
  final List<Review>? reviews;

  @HiveField(17)
  final String? returnPolicy;

  @HiveField(18)
  final int? minimumOrderQuantity;

  @HiveField(19)
  final Meta? meta;

  @HiveField(20)
  final String? thumbnail;

  @HiveField(21)
  final List<String>? images;

  Product({
    this.id,
    this.title,
    this.description,
    this.category,
    this.price,
    this.discountPercentage,
    this.rating,
    this.stock,
    this.tags,
    this.brand,
    this.sku,
    this.weight,
    this.dimensions,
    this.warrantyInformation,
    this.shippingInformation,
    this.availabilityStatus,
    this.reviews,
    this.returnPolicy,
    this.minimumOrderQuantity,
    this.meta,
    this.thumbnail,
    this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      category: json["category"],
      price: (json["price"] as num?)?.toDouble(),
      discountPercentage: (json["discountPercentage"] as num?)?.toDouble(),
      rating: (json["rating"] as num?)?.toDouble(),
      stock: json["stock"],
      tags: json["tags"] != null ? List<String>.from(json["tags"]) : [],
      brand: json["brand"],
      sku: json["sku"],
      weight: json["weight"],
      dimensions: json["dimensions"] != null
          ? Dimensions.fromJson(json["dimensions"])
          : null,
      warrantyInformation: json["warrantyInformation"],
      shippingInformation: json["shippingInformation"],
      availabilityStatus: json["availabilityStatus"],
      reviews: json["reviews"] != null
          ? (json["reviews"] as List<dynamic>)
                .map((e) => Review.fromJson(e))
                .toList()
          : [],
      returnPolicy: json["returnPolicy"],
      minimumOrderQuantity: json["minimumOrderQuantity"],
      meta: json["meta"] != null ? Meta.fromJson(json["meta"]) : null,
      thumbnail: json["thumbnail"],
      images: json["images"] != null ? List<String>.from(json["images"]) : [],
    );
  }
}

// ==========================================

@HiveType(typeId: 2)
class Dimensions extends HiveObject {
  @HiveField(0)
  final double? width;

  @HiveField(1)
  final double? height;

  @HiveField(2)
  final double? depth;

  Dimensions({this.width, this.height, this.depth});

  factory Dimensions.fromJson(Map<String, dynamic> json) {
    return Dimensions(
      width: (json["width"] as num?)?.toDouble(),
      height: (json["height"] as num?)?.toDouble(),
      depth: (json["depth"] as num?)?.toDouble(),
    );
  }
}

// =======================================

@HiveType(typeId: 3)
class Review extends HiveObject {
  @HiveField(0)
  final double? rating;

  @HiveField(1)
  final String? comment;

  @HiveField(2)
  final DateTime? date;

  @HiveField(3)
  final String? reviewerName;

  @HiveField(4)
  final String? reviewerEmail;

  Review({
    this.rating,
    this.comment,
    this.date,
    this.reviewerName,
    this.reviewerEmail,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      rating: (json["rating"] as num?)?.toDouble(),
      comment: json["comment"],
      date: json["date"] != null ? DateTime.parse(json["date"]) : null,
      reviewerName: json["reviewerName"],
      reviewerEmail: json["reviewerEmail"],
    );
  }
}

// =======================================

@HiveType(typeId: 4)
class Meta extends HiveObject {
  @HiveField(0)
  final String? createdAt;

  @HiveField(1)
  final String? updatedAt;

  @HiveField(2)
  final String? barcode;

  @HiveField(3)
  final String? qrCode;

  Meta({this.createdAt, this.updatedAt, this.barcode, this.qrCode});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      createdAt: json["createdAt"],
      updatedAt: json["updatedAt"],
      barcode: json["barcode"],
      qrCode: json["qrCode"],
    );
  }
}
