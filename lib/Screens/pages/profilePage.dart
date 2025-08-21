import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../components/addItem.dart';
import '../../colors.dart';
import '../components/product_edit_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final ImagePicker _imagePicker = ImagePicker();

  // State variables
  User? _user;
  bool _isLoading = true;
  bool _isEditing = false;
  File? _selectedImage;
  String? _profilePicUrl;
  String? _userName;
  List<Map<String, dynamic>> _products = [];
  String? _errorMessage;
  bool _showTimeout = false;

  // Controllers
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeProfile();
    _setupTimeout();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _initializeProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _showTimeout = false;
    });

    _user = _auth.currentUser;
    if (_user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please sign in to view your profile';
      });
      return;
    }

    await _loadCachedData();
    await _fetchFreshData();
  }

  Future<void> _setupTimeout() async {
    await Future.delayed(const Duration(seconds: 10));
    if (_isLoading && mounted) {
      setState(() {
        _showTimeout = true;
        _errorMessage = 'Slow connection.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName');
      _profilePicUrl = prefs.getString('userProfile');
      _nameController.text = _userName ?? '';

      final cachedProducts = prefs.getString('userProducts');
      if (cachedProducts != null) {
        try {
          final List<dynamic> decoded = jsonDecode(cachedProducts);
          _products = List<Map<String, dynamic>>.from(decoded);
        } catch (e) {
          debugPrint('Error loading cached products: $e');
        }
      }
    });
  }

  Future<bool> _checkInternetConnection() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) return false;

    try {
      final response = await InternetAddress.lookup('google.com');
      return response.isNotEmpty && response[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _fetchFreshData() async {
    if (!await _checkInternetConnection()) {
      setState(() {
        _errorMessage = 'No internet. Using cached data.';
        _isLoading = false;
      });
      return;
    }

    try {
      debugPrint('Fetching fresh data for user: ${_user!.email}');

      // Fetch user data
      final userDoc =
          await _firestore.collection('users').doc(_user!.email).get();
      debugPrint('User doc exists: ${userDoc.exists}');

      // Fetch products
      final productsSnapshot =
          await _firestore
              .collection('users')
              .doc(_user!.email)
              .collection('products')
              .get();

      debugPrint('Found ${productsSnapshot.docs.length} products');

      // Update cache
      final prefs = await SharedPreferences.getInstance();
      if (userDoc.exists) {
        await prefs.setString('userName', userDoc['name'] ?? '');
        await prefs.setString('userProfile', userDoc['profilePic'] ?? '');
      }

      // Convert products to cacheable format
      final productsData =
          productsSnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              ...data.map((key, value) {
                // Convert Timestamp to ISO string
                if (value is Timestamp) {
                  return MapEntry(key, value.toDate().toIso8601String());
                }
                return MapEntry(key, value);
              }),
            };
          }).toList();

      await prefs.setString('userProducts', jsonEncode(productsData));

      setState(() {
        if (userDoc.exists) {
          _userName = userDoc['name'];
          _profilePicUrl = userDoc['profilePic'];
          _nameController.text = _userName ?? '';
        }
        _products = productsData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching data: $e');
      setState(() {
        _errorMessage = 'Error loading data. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);

    try {
      // Upload to Cloudinary
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/dlovr1x97/image/upload',
      );
      final request =
          http.MultipartRequest('POST', url)
            ..fields['upload_preset'] = 'solarMate'
            ..files.add(
              await http.MultipartFile.fromPath('file', _selectedImage!.path),
            );

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonData = jsonDecode(responseData);

        setState(() => _profilePicUrl = jsonData['secure_url']);
        await _updateProfile();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
    } finally {
      setState(() {
        _selectedImage = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await _firestore.collection('users').doc(_user!.email).update({
      'name': _nameController.text,
      'profilePic': _profilePicUrl ?? '',
    });

    await prefs.setString('userName', _nameController.text);
    await prefs.setString('userProfile', _profilePicUrl ?? '');

    setState(() {
      _userName = _nameController.text;
      _isEditing = false;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _auth.signOut();
    await _googleSignIn.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget _buildProfilePicture() {
    return GestureDetector(
      onTap: _isEditing ? _pickImage : null,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: SizedBox(
            width: 100,
            height: 100,
            child:
                _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : _profilePicUrl?.isNotEmpty == true
                    ? CachedNetworkImage(
                      imageUrl: _profilePicUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const CircularProgressIndicator(),
                      errorWidget: (_, __, ___) => _buildDefaultAvatar(),
                    )
                    : _buildDefaultAvatar(),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return const Icon(Icons.person, size: 50, color: Colors.white);
  }

  Widget _buildProductGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_products.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2, size: 50, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('No products found', style: TextStyle(fontSize: 16)),
          TextButton(onPressed: _fetchFreshData, child: const Text('Refresh')),
        ],
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.7,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          final images = List<String>.from(product['images'] ?? []);

          return GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ProductEditPage(
                          product: product,
                          userEmail: _user!.email!,
                          productId: product['id'],
                        ),
                  ),
                ),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: CachedNetworkImage(
                        imageUrl:
                            images.isNotEmpty
                                ? images.first
                                : 'https://via.placeholder.com/150',
                        fit: BoxFit.cover,
                        placeholder:
                            (_, __) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        errorWidget:
                            (_, __, ___) =>
                                const Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      product['title'] ?? 'No Title',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                    ), // Side padding
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 16,
                      ), // Bottom padding
                      child: Text(
                        'Rs. ${product['price']?.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          if (_user != null)
            IconButton(
              icon: Icon(
                _isEditing ? Icons.close : Icons.edit,
                color: Colors.white,
              ),
              onPressed: () => setState(() => _isEditing = !_isEditing),
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UploadProductPage()),
            ),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _products.isEmpty && _userName == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_user == null) {
      return _buildSignInPrompt();
    }

    return RefreshIndicator(
      onRefresh: _fetchFreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            _buildProfilePicture(),
            const SizedBox(height: 16),
            _isEditing
                ? _buildEditProfileForm()
                : Text(
                  _userName ?? 'No Name',
                  style: const TextStyle(fontSize: 20),
                ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'My Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildProductGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Please sign in to view your profile',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileForm() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _uploadProfilePicture,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}
