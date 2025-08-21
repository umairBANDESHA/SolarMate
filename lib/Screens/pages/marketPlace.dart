import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuple/tuple.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../colors.dart';
import '../components/addItem.dart';
import '../components/productView.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplacePage> {
  final TextEditingController searchController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final Connectivity _connectivity = Connectivity();

  // Cache variables
  List<Tuple3<Map<String, dynamic>, String, String>> _productCache = [];
  DateTime? _lastFetchTime;
  final int _maxCacheSize = 100;
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _loadInitialData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _hasError = true;
        _errorMessage = 'No internet connection. Please check your network.';
      });
    }
  }

  Future<void> _loadInitialData() async {
    if (_productCache.isEmpty || !_isCacheValid) {
      await _refreshData();
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Add timeout for the operation
      final snapshot = await firestore
          .collectionGroup('products')
          .get()
          .timeout(const Duration(seconds: 10));

      final products = snapshot.docs;

      final productUserData = await Future.wait(
        products.map((doc) async {
          final productData = doc.data() as Map<String, dynamic>;
          final userEmail = productData['userEmail'] as String;
          final userDoc = await firestore
              .collection('users')
              .doc(userEmail)
              .get()
              .timeout(const Duration(seconds: 5));

          final userData = userDoc.data() as Map<String, dynamic>? ?? {};

          return Tuple3<Map<String, dynamic>, String, String>(
            productData,
            userData['name']?.toString() ?? 'Unknown User',
            userData['profilePic']?.toString() ?? '',
          );
        }),
      ).timeout(const Duration(seconds: 15));

      setState(() {
        _productCache = productUserData.take(_maxCacheSize).toList();
        _lastFetchTime = DateTime.now();
        _isLoading = false;
      });
    } on FirebaseException catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Firestore error: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage =
            e is TimeoutException
                ? 'Request timed out. Please check your internet connection.'
                : 'Error loading data. Please try again.';
        _isLoading = false;
      });
    }
  }

  bool get _isCacheValid {
    return _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) <
            const Duration(minutes: 300);
  }

  List<Tuple3<Map<String, dynamic>, String, String>> get _filteredProducts {
    final searchTerm = searchController.text.toLowerCase();
    return _productCache.where((tuple) {
      final product = tuple.item1;
      return product['title'].toString().toLowerCase().contains(searchTerm);
    }).toList();
  }

  bool get isUserLoggedIn => auth.currentUser != null;

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _refreshData, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading products...'),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    final products = _filteredProducts;

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 50, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              searchController.text.isEmpty
                  ? 'No products available'
                  : 'No matching products found',
              style: const TextStyle(fontSize: 16),
            ),
            if (searchController.text.isNotEmpty)
              TextButton(
                onPressed:
                    () => setState(() {
                      searchController.clear();
                    }),
                child: const Text('Clear search'),
              ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.70,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final productData = products[index].item1;
        final userName = products[index].item2;
        final userPic = products[index].item3;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ProductDetailPage(
                      product: productData,
                      userName: userName,
                      userPic: userPic,
                    ),
              ),
            );
          },
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Hero(
                      tag: "productImage_${productData["title"]}",
                      child: CachedNetworkImage(
                        imageUrl: productData["images"][0],
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        errorWidget:
                            (context, url, error) => const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    productData["title"] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "Rs. ${productData["price"]}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: CachedNetworkImageProvider(userPic),
                        child:
                            userPic.isEmpty
                                ? const Icon(Icons.person, size: 16)
                                : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
      appBar: AppBar(
        title: const Text(
          'Marketplace',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshData,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            Expanded(
              child:
                  _hasError
                      ? _buildErrorWidget()
                      : _isLoading && _productCache.isEmpty
                      ? _buildLoadingIndicator()
                      : _buildProductGrid(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          if (!isUserLoggedIn) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Please log in first to upload a product."),
              ),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UploadProductPage()),
          );
        },
      ),
    );
  }
}
