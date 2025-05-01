import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import 'profile_screen.dart';
import 'product_detail_screen.dart';
import '../widgets/product_tag.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedIndex = 2;

  // Professional business color scheme
  final Color _primaryColor = const Color(0xFF1A237E); // Deep indigo
  final Color _accentColor = const Color(0xFF1976D2); // Professional blue
  final Color _backgroundColor = const Color(0xFFF8F9FA); // Very light gray
  final Color _textColor = const Color(0xFF2C3E50); // Dark slate
  final Color _cardColor = Colors.white; // White cards
  final Color _borderColor = const Color(0xFFE0E0E0); // Light gray border
  final Color _successColor = Colors.green; // Green color for success

  final _productService = ProductService();
  final _auth = FirebaseAuth.instance;
  final _cartService = CartService();
  final _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      // Categories tab
      Navigator.pushNamed(context, '/categories');
      // Reset the selected index to home
      setState(() {
        _selectedIndex = 2;
      });
    } else if (index == 1) {
      // Cart tab
      Navigator.pushNamed(context, '/cart');
      // Reset the selected index to home
      setState(() {
        _selectedIndex = 2;
      });
    } else if (index == 2) {
      // Home tab (middle)
      // Already on home screen
    } else if (index == 3) {
      // Sell tab
      Navigator.pushNamed(context, '/sell');
      // Reset the selected index to home
      setState(() {
        _selectedIndex = 2;
      });
    } else if (index == 4) {
      // Profile tab
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        ),
      );
      // Reset the selected index to home
      setState(() {
        _selectedIndex = 2;
      });
    }
  }

  Widget _buildProductCard(Product product, int index) {
    final isOwnProduct = product.sellerId == _auth.currentUser?.uid;

    return StreamBuilder<List<Product>>(
      stream: _cartService.getUserCart(),
      builder: (context, snapshot) {
        final cartItems = snapshot.data ?? [];
        final isInCart = cartItems.any((item) => item.id == product.id);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _borderColor,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: _backgroundColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                        child: product.images.isNotEmpty
                            ? ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: Image.network(
                                    product.images.first,
                                    fit: BoxFit.fill,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                          color: _accentColor,
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Colors.black26,
                                          size: 40,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.image,
                                  color: Colors.black26,
                                  size: 40,
                                ),
                              ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            style: TextStyle(
                              color: _textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: _accentColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isInCart)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: _accentColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    Icons.shopping_cart,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isOwnProduct)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: ProductTag(
                      type: 'owner',
                      backgroundColor: _primaryColor,
                    ),
                  ),
                if (isInCart)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: ProductTag(
                      type: 'cart',
                      backgroundColor: _successColor,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Collapsible App Bar
            SliverAppBar(
              expandedHeight: 100,
              floating: true,
              pinned: false,
              backgroundColor: _backgroundColor,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Busell',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                            letterSpacing: 1.1,
                            height: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StreamBuilder<List<Product>>(
                            stream: _cartService.getUserCart(),
                            builder: (context, snapshot) {
                              final cartItems = snapshot.data ?? [];
                              final itemCount = cartItems.length;

                              return SizedBox(
                                width: 36,
                                height: 36,
                                child: Stack(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.shopping_cart),
                                      color: _primaryColor,
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/cart');
                                      },
                                    ),
                                    if (itemCount > 0)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: _accentColor,
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 16,
                                            minHeight: 16,
                                          ),
                                          child: Text(
                                            itemCount.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          StreamBuilder<List<Order>>(
                            stream: _orderService.getOrders(),
                            builder: (context, snapshot) {
                              final orders = snapshot.data ?? [];
                              final pendingCount = orders
                                  .where((order) => order.status == 'pending')
                                  .length;

                              return SizedBox(
                                width: 36,
                                height: 36,
                                child: Stack(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.pending_actions),
                                      color: _primaryColor,
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/pending-orders');
                                      },
                                    ),
                                    if (pendingCount > 0)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: _accentColor,
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 16,
                                            minHeight: 16,
                                          ),
                                          child: Text(
                                            pendingCount.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: IconButton(
                              icon: const Icon(Icons.notifications_none),
                              color: _primaryColor,
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                // TODO: Implement notifications
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Pinned Search Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverSearchBarDelegate(
                child: Container(
                  color: _backgroundColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _borderColor,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                        color: _textColor,
                        fontSize: 14,
                        height: 1.2,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          height: 1.2,
                        ),
                        prefixIcon: Icon(Icons.search, color: _primaryColor),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: _primaryColor),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Products Grid
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: StreamBuilder<List<Product>>(
                stream: _searchQuery.isEmpty
                    ? _productService.getActiveProducts()
                    : _productService.searchProducts(_searchQuery),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }

                  final products = snapshot.data ?? [];
                  if (products.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No products available',
                          style: TextStyle(
                            color: _textColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildProductCard(products[index], index),
                      childCount: products.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: _cardColor,
          border: Border(
            top: BorderSide(
              color: _borderColor,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 2, 'Home'),
            _buildNavItem(Icons.category, 0, 'Categories'),
            _buildNavItem(Icons.add_circle_outline, 3, 'Sell'),
            _buildNavItem(Icons.person, 4, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(isSelected ? 8 : 4),
            decoration: BoxDecoration(
              color: isSelected ? _accentColor : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : _primaryColor,
              size: isSelected ? 20 : 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? _accentColor : _primaryColor,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverSearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverSearchBarDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 64.0;

  @override
  double get minExtent => 64.0;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
