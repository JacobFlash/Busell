import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';
import '../theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'add_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isInCart = false;
  bool _hasItemsInCart = false;

  @override
  void initState() {
    super.initState();
    _checkCartStatus();
    _checkCartItems();
  }

  Future<void> _checkCartStatus() async {
    final cartItems = await widget._cartService.getUserCart().first;
    setState(() {
      _isInCart = cartItems.any((item) => item.id == widget.product.id);
    });
  }

  Future<void> _checkCartItems() async {
    final cartItems = await widget._cartService.getUserCart().first;
    setState(() {
      _hasItemsInCart = cartItems.isNotEmpty;
    });
  }

  Future<void> _toggleCartStatus() async {
    try {
      if (_isInCart) {
        await widget._cartService.removeFromCart(widget.product.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product removed from cart'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        await widget._cartService.addToCart(widget.product);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product added to cart'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      // Check cart status and items after the operation
      final cartItems = await widget._cartService.getUserCart().first;
      setState(() {
        _isInCart = cartItems.any((item) => item.id == widget.product.id);
        _hasItemsInCart = cartItems.isNotEmpty;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwnProduct =
        widget.product.sellerId == widget._auth.currentUser?.uid;
    final currencyFormat = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Product Details',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Images
              SizedBox(
                height: 300,
                child: PageView.builder(
                  itemCount: widget.product.images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(widget.product.images[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Product Title and Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.product.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    currencyFormat.format(widget.product.price),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Category and Status
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.product.category,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.product.status == 'active'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.product.status.toUpperCase(),
                      style: TextStyle(
                        color: widget.product.status == 'active'
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.product.description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Seller Info
                const Text(
                  'Seller Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    widget.product.sellerName[0].toUpperCase(),
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                ),
                title: Text(
                  widget.product.sellerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Member since ${DateFormat.yMMMd().format(widget.product.createdAt)}',
                  ),
                ),
                const SizedBox(height: 24),

              // Action Buttons
              if (isOwnProduct) ...[
                ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                        builder: (context) => AddProductScreen(
                          product: widget.product,
                        ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 0),
                        ),
                        child: const Text(
                          'Edit Product',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                const SizedBox(height: 16),
                ElevatedButton(
                        onPressed: () async {
                    try {
                      await widget._productService
                          .deleteProduct(widget.product.id);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error deleting product: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 0),
                        ),
                        child: const Text(
                    'Delete Product',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ] else ...[
                ElevatedButton(
                  onPressed: _toggleCartStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isInCart ? Colors.red : AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  child: Text(
                    _isInCart ? 'Remove from Cart' : 'Add to Cart',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _hasItemsInCart
                      ? () {
                          Navigator.pushNamed(context, '/cart');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  child: const Text(
                    'Go to Cart',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
