import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../colors.dart';

class UploadProductPage extends StatefulWidget {
  const UploadProductPage({super.key});

  @override
  _ProductUploadPageState createState() => _ProductUploadPageState();
}

class _ProductUploadPageState extends State<UploadProductPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final List<File> _selectedImages = [];
  final List<String> _uploadedImageUrls = [];
  final ImagePicker _picker = ImagePicker();

  bool isLoading = false;

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles == null) return;
      if (_selectedImages.length + pickedFiles.length > 12) {
        _showSnackBar("You can only upload up to 12 images");
        return;
      }
      setState(() {
        _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    } catch (e) {
      _showSnackBar("Failed to pick images: $e");
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<String> _uploadToCloudinary(File imageFile) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/dx2q08oc0/images/upload',
    );
    final request =
        http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = 'solarMate'
          ..files.add(
            await http.MultipartFile.fromPath('file', imageFile.path),
          );

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = json.decode(responseString);
      return jsonMap['secure_url'];
    } else {
      throw Exception(
        "Failed to upload image. Status code: ${response.statusCode}",
      );
    }
  }

  Future<void> _uploadProduct() async {
    if (!_validateProductInputs()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar("You must be logged in to upload a product");
      return;
    }
    final userEmail = user.email;

    setState(() {
      isLoading = true;
    });

    try {
      // Wrap the entire upload logic inside a timeout
      await Future.any([
        _performUpload(userEmail!),
        Future.delayed(
          const Duration(seconds: 10),
          () => throw TimeoutException("Upload timed out"),
        ),
      ]);
    } on TimeoutException catch (_) {
      _showSnackBar("Upload timed out. Please check your internet connection.");
    } catch (e) {
      _showSnackBar("Failed to upload product: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _performUpload(String userEmail) async {
    _uploadedImageUrls.clear();

    for (final image in _selectedImages) {
      try {
        final imageUrl = await _uploadToCloudinary(image);
        _uploadedImageUrls.add(imageUrl);
      } catch (e) {
        _showSnackBar("Image upload failed: $e");
        throw Exception("Image upload failed");
      }
    }

    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userEmail);
    final userProductCollection = userDocRef.collection('products');

    final userDoc = await userDocRef.get();
    if (!userDoc.exists) {
      await userDocRef.set({'createdAt': FieldValue.serverTimestamp()});
    }

    await userProductCollection.add({
      'userEmail': userEmail,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'price': double.parse(_priceController.text.trim()),
      'contact': _contactController.text.trim(),
      'address': _addressController.text.trim(),
      'images': _uploadedImageUrls,
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;

    _showSnackBar("Product uploaded successfully!");
    Navigator.pop(context);
  }

  bool _validateProductInputs() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final price = _priceController.text.trim();
    final contact = _contactController.text.trim();
    final address = _addressController.text.trim();

    final priceRegex = RegExp(r'^\d+(\.\d{1,2})?$');
    final phoneRegex = RegExp(r'^\d{11,13}$');
    final addressRegex = RegExp(r'^[\w\s,#.-]{5,}$', caseSensitive: false);

    final bannedWords = ['free', 'urgent', 'cheap', 'offer'];
    final requiredKeywords = [
      'solar',
      'panel',
      'battery',
      'batteries',
      'inverter',
      'inverters',
      'pv',
      'dc',
      'ac',
      'voltage',
      'amp',
      'watts',
      'charge controller',
      'solar setup',
      'solar system',
    ];

    bool containsKeyword(String text) =>
        requiredKeywords.any((word) => text.toLowerCase().contains(word));

    bool containsBannedWords(String text) =>
        bannedWords.any((word) => text.toLowerCase().contains(word));

    if (title.length < 5 ||
        !containsKeyword(title) ||
        containsBannedWords(title)) {
      _showSnackBar(
        "Title must relate to solar/battery/inverter and avoid spam words",
      );
      return false;
    }

    if (description.length < 20 ||
        !containsKeyword(description) ||
        containsBannedWords(description)) {
      _showSnackBar("Description must be detailed and relevant to solar items");
      return false;
    }

    if (!priceRegex.hasMatch(price)) {
      _showSnackBar("Price must be a valid number (e.g. 1000 or 999.99)");
      return false;
    }

    if (!phoneRegex.hasMatch(contact)) {
      _showSnackBar("Enter a valid 10-15 digit phone number");
      return false;
    }

    if (!addressRegex.hasMatch(address)) {
      _showSnackBar(
        "Address must be at least 5 characters and properly formatted",
      );
      return false;
    }

    if (_selectedImages.isEmpty) {
      _showSnackBar("Please select at least one image");
      return false;
    }

    return true;
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Upload Product",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryBlue,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Product Title"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _contactController,
                decoration: const InputDecoration(labelText: "Contact Info"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Location / Address",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.image),
                label: const Text("Select Images (Max 12)"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.accentWhite,
                ),
              ),
              const SizedBox(height: 10),
              if (_selectedImages.isNotEmpty)
                Text("Selected Images: ${_selectedImages.length}/12"),
              const SizedBox(height: 20),
              if (_selectedImages.isNotEmpty) ...[
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            child: Image.file(
                              _selectedImages[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 5,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 10),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _uploadProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.accentWhite,
                    ),
                    child: const Text("Upload Product"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
