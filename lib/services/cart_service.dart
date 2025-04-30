import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _cartCollection => _firestore.collection('carts');

  // Get user's cart
  Stream<List<Product>> getUserCart() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _cartCollection
        .doc(userId)
        .collection('items')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Product.fromMap(data);
      }).toList();
    });
  }

  // Add product to cart
  Future<void> addToCart(Product product) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _cartCollection.doc(userId).collection('items').doc(product.id).set({
      ...product.toMap(),
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Remove product from cart
  Future<void> removeFromCart(String productId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _cartCollection
        .doc(userId)
        .collection('items')
        .doc(productId)
        .delete();
  }

  // Clear cart
  Future<void> clearCart() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final batch = _firestore.batch();
    final items = await _cartCollection.doc(userId).collection('items').get();

    for (var doc in items.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
