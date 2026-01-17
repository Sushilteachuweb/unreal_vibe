import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/error_handler.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _cityController;
  late TextEditingController _bioController;
  late TextEditingController _funFactController;
  late TextEditingController _interestsController;
  String _selectedGender = 'Male';
  
  File? _profilePhoto;
  File? _aadhaar;
  File? _pan;
  File? _drivingLicense;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _funFactController = TextEditingController(text: user?.funFact ?? '');
    _interestsController = TextEditingController(
      text: user?.interests?.join(', ') ?? '',
    );
    _selectedGender = user?.gender ?? 'Male';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    _funFactController.dispose();
    _interestsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, String type) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 60,
      );
      
      if (image != null) {
        final file = File(image.path);
        final fileSize = await file.length();
        final fileSizeMB = fileSize / (1024 * 1024);
        
        // Check if file is too large (more than 2MB)
        if (fileSizeMB > 2) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image is too large (${fileSizeMB.toStringAsFixed(1)}MB). Please use a smaller image.'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return;
        }
        
        setState(() {
          switch (type) {
            case 'profile':
              _profilePhoto = file;
              break;
            case 'aadhaar':
              _aadhaar = file;
              break;
            case 'pan':
              _pan = file;
              break;
            case 'drivingLicense':
              _drivingLicense = file;
              break;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
      }
    }
  }

  void _showImageSourceDialog(String type, String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Color(0xFFE94B8B)),
                  title: const Text('Camera', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera, type);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Color(0xFFE94B8B)),
                  title: const Text('Gallery', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery, type);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Convert interests string to list
      List<String> interestsList = [];
      if (_interestsController.text.trim().isNotEmpty) {
        interestsList = _interestsController.text
            .split(',')
            .map((interest) => interest.trim())
            .where((interest) => interest.isNotEmpty)
            .toList();
      }

      final result = await userProvider.completeProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        city: _cityController.text.trim(),
        gender: _selectedGender,
        bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
        funFact: _funFactController.text.trim().isNotEmpty ? _funFactController.text.trim() : null,
        interests: interestsList.isNotEmpty ? interestsList : null,
        profilePhoto: _profilePhoto,
        aadhaar: _aadhaar,
        pan: _pan,
        drivingLicense: _drivingLicense,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (result['success']) {
        // Override specific backend messages
        String successMessage = result['message'] ?? 'Profile updated successfully';
        if (successMessage.toLowerCase().contains('you are now a host') || 
            successMessage.toLowerCase().contains('host')) {
          successMessage = 'Profile updated successfully';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _isLoading = false);
      
      ErrorHandler.showErrorSnackBar(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfilePhotoSection(),
              const SizedBox(height: 32),
              _buildTextField('Name', _nameController, Icons.person),
              const SizedBox(height: 16),
              _buildTextField('Email', _emailController, Icons.email, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField('City', _cityController, Icons.location_city),
              const SizedBox(height: 16),
              _buildGenderSelector(),
              const SizedBox(height: 24),
              // Note: Bio, Fun Facts, and Interests are UI-only for now (not connected to API)
              _buildTextArea('Bio / About Me', _bioController, Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextArea('Fun Fact About Me', _funFactController, Icons.emoji_emotions),
              const SizedBox(height: 16),
              _buildInterestsSelector(),
              const SizedBox(height: 32),
              _buildDocumentsSection(),
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    final user = Provider.of<UserProvider>(context).user;
    
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => _showImageSourceDialog('profile', 'Update Profile Photo'),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE94B8B), width: 3),
              ),
              child: ClipOval(
                child: _profilePhoto != null
                    ? Image.file(_profilePhoto!, fit: BoxFit.cover)
                    : (user?.profilePhotoUrl != null
                        ? Image.network(
                            'http://api.unrealvibe.com${user!.profilePhotoUrl}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _showImageSourceDialog('profile', 'Update Profile Photo'),
            icon: const Icon(Icons.camera_alt, color: Color(0xFFE94B8B)),
            label: const Text(
              'Change Photo',
              style: TextStyle(color: Color(0xFFE94B8B), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: const Icon(Icons.person, size: 60, color: Color(0xFF6B7280)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE94B8B)),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Row(
            children: [
              const Icon(Icons.wc, color: Color(0xFF6B7280)),
              const SizedBox(width: 12),
              Text(
                _selectedGender,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Cannot be changed',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }



  Widget _buildTextArea(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF6B7280)),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE94B8B)),
            ),
            hintText: 'Tell us about yourself...',
            hintStyle: const TextStyle(color: Color(0xFF6B7280)),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Vibe / Interests',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _interestsController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.interests, color: Color(0xFF6B7280)),
            filled: true,
            fillColor: const Color(0xFF1A1A1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE94B8B)),
            ),
            hintText: 'Enter your interests separated by commas (e.g., Music, Travel, Photography, Dancing)',
            hintStyle: const TextStyle(color: Color(0xFF6B7280)),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tip: Separate multiple interests with commas',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Documents (Optional)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        _buildDocumentUpload('Aadhaar', _aadhaar, 'aadhaar'),
        const SizedBox(height: 12),
        _buildDocumentUpload('PAN Card', _pan, 'pan'),
        const SizedBox(height: 12),
        _buildDocumentUpload('Driving License', _drivingLicense, 'drivingLicense'),
      ],
    );
  }

  Widget _buildDocumentUpload(String label, File? file, String type) {
    final user = Provider.of<UserProvider>(context).user;
    
    // Check if document is already uploaded on server
    bool isUploaded = false;
    if (user?.documents != null) {
      switch (type) {
        case 'aadhaar':
          isUploaded = user!.documents!.aadhaar != null;
          break;
        case 'pan':
          isUploaded = user!.documents!.pan != null;
          break;
        case 'drivingLicense':
          isUploaded = user!.documents!.drivingLicense != null;
          break;
      }
    }
    
    // Show as uploaded if either file is selected or already uploaded on server
    final hasDocument = file != null || isUploaded;
    
    return GestureDetector(
      onTap: () => _showImageSourceDialog(type, 'Upload $label'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasDocument ? const Color(0xFF10B981) : const Color(0xFF2A2A2A),
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasDocument ? Icons.check_circle : Icons.upload_file,
              color: hasDocument ? const Color(0xFF10B981) : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasDocument 
                    ? (file != null ? '$label uploaded (new)' : '$label uploaded')
                    : 'Upload $label',
                style: TextStyle(
                  color: hasDocument ? Colors.white : const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (hasDocument)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: Color(0xFF10B981),
                ),
              )
            else
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF6B7280),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          gradient: !_isLoading
              ? const LinearGradient(
                  colors: [Color(0xFFFF4081), Color(0xFFE91E63)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: _isLoading ? Colors.grey.withOpacity(0.3) : null,
          borderRadius: BorderRadius.circular(28.0),
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28.0),
            ),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Save Changes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
