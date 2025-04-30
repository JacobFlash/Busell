import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final String buyerId;
  final String sellerId;
  final String sellerName;
  final String productId;
  final String productTitle;
  final String status;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.sellerName,
    required this.productId,
    required this.productTitle,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'productId': productId,
      'productTitle': productTitle,
      'status': status,
      'totalAmount': totalAmount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as String,
      buyerId: map['buyerId'] as String,
      sellerId: map['sellerId'] as String,
      sellerName: map['sellerName'] as String,
      productId: map['productId'] as String,
      productTitle: map['productTitle'] as String,
      status: map['status'] as String,
      totalAmount: (map['totalAmount'] as num).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }
}
 