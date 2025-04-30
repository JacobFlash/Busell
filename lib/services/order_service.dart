import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order.dart';

class OrderService {
  final firestore.FirebaseFirestore _firestore = firestore.FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new order
  Future<Order> createOrder({
    required String productId,
    required String sellerId,
    required String sellerName,
    required String productTitle,
    required double totalAmount,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final orderRef = _firestore.collection('orders').doc();
      final order = Order(
        id: orderRef.id,
        buyerId: user.uid,
        sellerId: sellerId,
        sellerName: sellerName,
        productId: productId,
        productTitle: productTitle,
        status: 'pending',
        totalAmount: totalAmount,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await orderRef.set(order.toMap());
      return order;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Get orders for the current user (both as buyer and seller)
  Stream<List<Order>> getOrders() {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      return _firestore
          .collection('orders')
          .where('buyerId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map<List<Order>>((snapshot) {
        return snapshot.docs
            .map<Order>((doc) => Order.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to get orders: $e');
    }
  }

  // Get orders where the current user is the seller
  Stream<List<Order>> getSellerOrders() {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      return _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map<List<Order>>((snapshot) {
        return snapshot.docs
            .map<Order>((doc) => Order.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      });
    } catch (e) {
      throw Exception('Failed to get seller orders: $e');
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final orderRef = _firestore.collection('orders').doc(orderId);
      final orderDoc = await orderRef.get();
      
      if (!orderDoc.exists) {
        throw Exception('Order not found');
      }

      final order = Order.fromMap(orderDoc.data() as Map<String, dynamic>);
      
      // Only allow seller or admin to update status
      if (order.sellerId != user.uid) {
        throw Exception('Unauthorized to update order status');
      }

      await orderRef.update({
        'status': status,
        'updatedAt': firestore.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // Cancel order (only buyer can cancel pending orders)
  Future<void> cancelOrder(String orderId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final orderRef = _firestore.collection('orders').doc(orderId);
      final orderDoc = await orderRef.get();
      
      if (!orderDoc.exists) {
        throw Exception('Order not found');
      }

      final order = Order.fromMap(orderDoc.data() as Map<String, dynamic>);
      
      if (order.buyerId != user.uid) {
        throw Exception('Only the buyer can cancel the order');
      }

      if (order.status != 'pending') {
        throw Exception('Only pending orders can be cancelled');
      }

      await orderRef.update({
        'status': 'cancelled',
        'updatedAt': firestore.FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }
}
 