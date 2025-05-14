import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../data/models/user.dart';
import '../../../features/auth/services/auth_service.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Image files for profile and banner
  XFile? _profileImageFile;
  XFile? _bannerImageFile;
  File? _profileImageFileObj;
  File? _bannerImageFileObj;
  
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    
    if (currentUser != null) {
      setState(() {
        _nameController.text = currentUser.name;
        _displayNameController.text = currentUser.displayName ?? '';
        _bioController.text = currentUser.bio ?? '';
        _locationController.text = currentUser.location ?? '';
        _websiteController.text = currentUser.website ?? '';
        _phoneController.text = currentUser.phoneNumber ?? '';
      });
    }
  }
  
  Future<void> _pickProfileImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      setState(() {
        _profileImageFile = pickedFile;
        _profileImageFileObj = File(pickedFile.path);
      });
    }
  }
  
  Future<void> _pickBannerImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 400,
      imageQuality: 85,
    );
    
    if (pickedFile != null) {
      setState(() {
        _bannerImageFile = pickedFile;
        _bannerImageFileObj = File(pickedFile.path);
      });
    }
  }
  
  Future<String?> _uploadImage(File file, String path) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(path);
      // Use putFile for mobile platforms
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error uploading image: $e';
      });
      return null;
    }
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final currentUser = authService.currentUser;
      
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Upload profile image if selected
      String? profilePicUrl = currentUser.profilePicUrl;
      if (_profileImageFile != null && _profileImageFileObj != null) {
        profilePicUrl = await _uploadImage(
          _profileImageFileObj!,
          'profile_images/${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }
      
      // Upload banner image if selected
      String? bannerImageUrl = currentUser.bannerImageUrl;
      if (_bannerImageFile != null && _bannerImageFileObj != null) {
        bannerImageUrl = await _uploadImage(
          _bannerImageFileObj!,
          'banner_images/${currentUser.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }
      
      // Update user data
      await authService.updateUserProfile(
        name: _nameController.text.trim(),
        displayName: _displayNameController.text.trim(),
        bio: _bioController.text.trim(),
        location: _locationController.text.trim(),
        website: _websiteController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        profilePictureUrl: profilePicUrl,
        // bannerImageUrl is removed as it's not supported in the service
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        
        // Navigate back
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error updating profile: $e';
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;
    
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
        ),
        body: const Center(
          child: Text('Not authenticated'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Banner Image
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            image: _bannerImageFileObj != null
                                ? DecorationImage(
                                    image: FileImage(_bannerImageFileObj!) as ImageProvider,
                                    fit: BoxFit.cover,
                                  )
                                : currentUser.bannerImageUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(currentUser.bannerImageUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                          ),
                          child: currentUser.bannerImageUrl == null && _bannerImageFileObj == null
                              ? const Center(
                                  child: Icon(
                                    Icons.panorama,
                                    size: 50,
                                    color: Colors.white70,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.white),
                              onPressed: _pickBannerImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Profile Image
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            backgroundImage: _profileImageFileObj != null
                                ? FileImage(_profileImageFileObj!) as ImageProvider
                                : currentUser.profilePicUrl != null
                                    ? NetworkImage(currentUser.profilePicUrl!)
                                    : null,
                            child: currentUser.profilePicUrl == null && _profileImageFileObj == null
                                ? Text(
                                    currentUser.name.isNotEmpty
                                        ? currentUser.name[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                onPressed: _pickProfileImage,
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name *',
                        hintText: 'Your full name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Display Name
                    TextFormField(
                      controller: _displayNameController,
                      decoration: const InputDecoration(
                        labelText: 'Display Name',
                        hintText: 'How you want to be called',
                        prefixIcon: Icon(Icons.badge),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Bio
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        hintText: 'Tell us about yourself',
                        prefixIcon: Icon(Icons.info),
                      ),
                      maxLines: 3,
                    ),
                    
                    // const SizedBox(height: 16),
                    //
                    // // Location
                    // TextFormField(
                    //   controller: _locationController,
                    //   decoration: const InputDecoration(
                    //     labelText: 'Location',
                    //     hintText: 'Where you live',
                    //     prefixIcon: Icon(Icons.location_on),
                    //   ),
                    // ),
                    
                    // const SizedBox(height: 16),
                    //
                    // // Website
                    // TextFormField(
                    //   controller: _websiteController,
                    //   decoration: const InputDecoration(
                    //     labelText: 'Website',
                    //     hintText: 'Your website or social link',
                    //     prefixIcon: Icon(Icons.link),
                    //   ),
                    //   keyboardType: TextInputType.url,
                    // ),
                    
                    const SizedBox(height: 16),
                    
                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'Your phone number',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveProfile,
                        icon: const Icon(Icons.save),
                        label: Text(_isLoading ? 'Saving...' : 'Save Profile'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}