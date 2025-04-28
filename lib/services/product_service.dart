import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../services/storage_service.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _storageService = StorageService();

  // Collection reference
  CollectionReference get _productsCollection =>
      _firestore.collection('products');

  // Get all products for the current user
  Stream<List<Product>> getUserProducts(String userId) {
    return _productsCollection
        .where('sellerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(
              {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    });
  }

  // Get a single product by ID
  Future<Product?> getProduct(String productId) async {
    final doc = await _productsCollection.doc(productId).get();
    if (!doc.exists) return null;
    return Product.fromMap(
        {...doc.data() as Map<String, dynamic>, 'id': doc.id});
  }

  // Create a new product
  Future<String> createProduct(Product product) async {
    final docRef = await _productsCollection.add(product.toMap());
    return docRef.id;
  }

  // Update an existing product
  Future<void> updateProduct(Product product) async {
    await _productsCollection.doc(product.id).update(product.toMap());
  }

  // Delete a product (permanent delete from Firestore and storage)
  Future<void> deleteProduct(String productId) async {
    try {
      // First get the product to access its images
      final product = await getProduct(productId);
      if (product != null) {
        // Delete images from storage
        await _storageService.deleteImages(product.images);
        // Delete the product document
        await _productsCollection.doc(productId).delete();
      }
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Mark a product as sold
  Future<void> markAsSold(String productId) async {
    await _productsCollection.doc(productId).update({
      'status': 'sold',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get active products for browsing
  Stream<List<Product>> getActiveProducts() {
    return _productsCollection
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(
              {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    });
  }

  // Search products
  Stream<List<Product>> searchProducts(String query) {
    if (query.isEmpty) return getActiveProducts();

    final lowercaseQuery = query.toLowerCase();
    return _productsCollection
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(
              {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .where(
              (product) => product.title.toLowerCase().contains(lowercaseQuery))
          .toList();
    });
  }

  // Get products by category
  Stream<List<Product>> getProductsByCategory(String category) {
    return _productsCollection
        .where('status', isEqualTo: 'active')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(
              {...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();
    });
  }
}
