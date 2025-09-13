import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';
// ...existing code...
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class ProfilePage extends StatefulWidget {
  final bool startInEditMode;
  final VoidCallback? onClose;
  const ProfilePage({super.key, this.startInEditMode = false, this.onClose});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Always in edit mode
  double? _uploadProgress;
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  File? _imageFile;
  String? _imageUrl;
  bool _loading = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyController = TextEditingController();
  final _medicalController = TextEditingController();
  final _hobbiesController = TextEditingController();
  final _notesController = TextEditingController();
  String? _gender;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    String? fetchedImageUrl;
    if (doc.exists) {
      final data = doc.data()!;
      fetchedImageUrl = data['imageUrl'];
      setState(() {
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _dobController.text = data['dob'] ?? '';
        _gender = data['gender'];
        _phoneController.text = data['phone'] ?? '';
        _addressController.text = data['address'] ?? '';
        _emergencyController.text = data['emergency'] ?? '';
        _medicalController.text = data['medical'] ?? '';
        _hobbiesController.text = data['hobbies'] ?? '';
        _notesController.text = data['notes'] ?? '';
        _imageUrl = fetchedImageUrl ?? user.photoURL;
      });
    } else {
      setState(() {
        _imageUrl = user.photoURL;
      });
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      final original = img.decodeImage(bytes);
      if (original != null) {
        // Center crop to square
        int size = original.width < original.height
            ? original.width
            : original.height;
        int x = (original.width - size) ~/ 2;
        int y = (original.height - size) ~/ 2;
        final square = img.copyCrop(
          original,
          x: x,
          y: y,
          width: size,
          height: size,
        );
        // Resize to 150x150
        final resized = img.copyResize(square, width: 150, height: 150);
        // Encode as JPEG with quality 40
        final compressed = img.encodeJpg(resized, quality: 40);
        final tempDir = Directory.systemTemp;
        final tempFile = await File(
          '${tempDir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ).writeAsBytes(compressed);
        setState(() {
          _imageFile = tempFile;
        });
      } else {
        setState(() {
          _imageFile = File(picked.path);
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _uploadProgress = null;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    String? imageUrl = _imageUrl;
    if (_imageFile != null) {
      // Cloudinary config
      const cloudName =
          'YOUR_CLOUD_NAME'; // <-- replace with your Cloudinary cloud name
      const uploadPreset =
          'YOUR_UNSIGNED_PRESET'; // <-- replace with your unsigned upload preset
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(
          await http.MultipartFile.fromPath('file', _imageFile!.path),
        );
      final response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = respStr.contains('secure_url') ? respStr : '';
        final urlMatch = RegExp(
          r'"secure_url"\s*:\s*"([^"]+)"',
        ).firstMatch(data);
        if (urlMatch != null) {
          imageUrl = urlMatch.group(1);
        }
      } else {
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Image upload failed.')));
        return;
      }
    }
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'dob': _dobController.text.trim(),
      'gender': _gender,
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'emergency': _emergencyController.text.trim(),
      'medical': _medicalController.text.trim(),
      'hobbies': _hobbiesController.text.trim(),
      'notes': _notesController.text.trim(),
      'uid': user.uid,
      'imageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    setState(() {
      _loading = false;
      _imageUrl = imageUrl;
      _imageFile = null;
      _uploadProgress = null;
    });
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: widget.onClose,
              tooltip: 'Close',
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2323A7), // dark blue
                      Color(0xFFE040FB), // pink
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.all(1.0),
                child: Card(
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
                    child: _buildEditForm(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_uploadProgress != null && _loading)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: LinearProgressIndicator(
                value: _uploadProgress,
                backgroundColor: Colors.white10,
                color: const Color.fromARGB(255, 0, 197, 82),
                minHeight: 6,
              ),
            ),
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white24,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : (_imageUrl != null && _imageUrl!.isNotEmpty)
                    ? NetworkImage(_imageUrl!) as ImageProvider
                    : null,
                child:
                    (_imageFile == null &&
                        (_imageUrl == null || _imageUrl!.isEmpty))
                    ? const Icon(Icons.person, size: 48, color: Colors.white54)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: _pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 4),
                      ],
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.edit,
                      size: 18,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: _inputDecoration('Name'),
            style: const TextStyle(color: Colors.white),
            validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            decoration: _inputDecoration('Email'),
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                v == null || v.isEmpty ? 'Enter your email' : null,
            maxLines: 1,
            minLines: 1,
            // The following line ensures overflow is handled
            buildCounter:
                (_, {required currentLength, required isFocused, maxLength}) =>
                    null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _dobController,
            decoration: _inputDecoration('Date of Birth (YYYY-MM-DD)'),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: _inputDecoration('Gender'),
            style: const TextStyle(color: Colors.white),
            dropdownColor: Colors.grey[900],
            items: const [
              DropdownMenuItem(value: 'Male', child: Text('Male')),
              DropdownMenuItem(value: 'Female', child: Text('Female')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (v) => setState(() => _gender = v),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            decoration: _inputDecoration('Phone Number'),
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _addressController,
            decoration: _inputDecoration('Address'),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emergencyController,
            decoration: _inputDecoration('Emergency Contact'),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _medicalController,
            decoration: _inputDecoration('Medical Issues (if any)'),
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _hobbiesController,
            decoration: _inputDecoration('Hobbies (comma separated)'),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            decoration: _inputDecoration('Other Notes'),
            style: const TextStyle(color: Colors.white),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _loading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.greenAccent, width: 2),
      ),
    );
  }
}
