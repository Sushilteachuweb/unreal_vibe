import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../utils/responsive_helper.dart';
import '../../providers/user_provider.dart';
import '../../navigation/main_navigation.dart';

class UploadDocumentsScreen extends StatefulWidget {
  const UploadDocumentsScreen({Key? key}) : super(key: key);

  @override
  State<UploadDocumentsScreen> createState() => _UploadDocumentsScreenState();
}

class _UploadDocumentsScreenState extends State<UploadDocumentsScreen> {
  final ImagePicker _picker = ImagePicker();
  
  // Track uploaded documents
  File? document1;
  File? document2;
  File? profilePicture;
  
  // Track current step
  int currentStep = 1; // 1 = first doc, 2 = second doc, 3 = profile pic
  
  String get stepTitle {
    if (currentStep == 1) return 'Upload First Document';
    if (currentStep == 2) return 'Upload Second Document';
    return 'Upload Profile Picture';
  }
  
  String get stepDescription {
    if (currentStep == 1) return 'Take or select a photo of your first identity document';
    if (currentStep == 2) return 'Take or select a photo of your second identity document';
    return 'Take or select a profile picture of yourself';
  }

  Future<void> _pickImage(ImageSource source) async {
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
          if (currentStep == 1) {
            document1 = file;
          } else if (currentStep == 2) {
            document2 = file;
          } else {
            profilePicture = file;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        // Log detailed error for developers
        debugPrint('🚨 [UploadDocuments] Image selection error: $e');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to select image. Please try again'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
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
                  'Choose Image Source',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Color(0xFFE94B8B)),
                  title: const Text(
                    'Camera',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Color(0xFFE94B8B)),
                  title: const Text(
                    'Gallery',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _nextStep() {
    if (currentStep == 1 && document1 != null) {
      setState(() {
        currentStep = 2;
      });
    } else if (currentStep == 2 && document2 != null) {
      setState(() {
        currentStep = 3;
      });
    } else if (currentStep == 3 && profilePicture != null) {
      _completeProfile();
    }
  }

  Future<void> _completeProfile() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFE94B8B),
          ),
        );
      },
    );

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;

      if (user == null) {
        throw Exception('User data not found');
      }

      // Call complete profile API
      final result = await userProvider.completeProfile(
        name: user.name ?? '',
        email: user.email ?? '',
        city: user.city ?? '',
        gender: user.gender ?? '',
        aadhaar: document1,
        drivingLicense: document2,
        pan: document2, // Using document2 as pan for now
        profilePhoto: profilePicture,
      );

      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      if (result['success']) {
        // Show success dialog
        _showSuccessDialog();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to complete profile'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog
      Navigator.of(context).pop();

      // Log detailed error for developers
      debugPrint('🚨 [UploadDocuments] Profile completion error: $e');
      
      // Show user-friendly error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to complete profile. Please try again'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF10B981),
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Profile Complete!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 20),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your documents and profile picture have been uploaded successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF9CA3AF),
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop(); // Close dialog
                    
                    // Navigate to profile screen with updated data
                    await _navigateToProfile();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE94B8B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _navigateToProfile() async {
    // Show loading indicator
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFE94B8B),
          ),
        ),
      );
    }

    try {
      // Refresh user profile data
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshProfile();
      
      if (!mounted) return;
      
      // Close loading indicator
      Navigator.of(context).pop();
      
      // Navigate to profile screen (index 4 in MainNavigation)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const MainNavigation(initialIndex: 4),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      
      // Close loading indicator
      Navigator.of(context).pop();
      
      // Log detailed error for developers
      debugPrint('🚨 [UploadDocuments] Profile refresh error: $e');
      
      // Show user-friendly error but still navigate to profile
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not refresh profile data'),
          backgroundColor: Colors.orange,
        ),
      );
      
      // Navigate anyway
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const MainNavigation(initialIndex: 4),
        ),
        (route) => false,
      );
    }
  }

  File? get currentImage {
    if (currentStep == 1) return document1;
    if (currentStep == 2) return document2;
    return profilePicture;
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context, 24.0);
    final maxWidth = ResponsiveHelper.getMaxContentWidth(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Complete Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress indicator
                        _buildProgressIndicator(),
                        const SizedBox(height: 32),
                        
                        // Title
                        Text(
                          stepTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 28),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Description
                        Text(
                          stepDescription,
                          style: TextStyle(
                            color: const Color(0xFF9CA3AF),
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Image preview or upload button
                        Center(
                          child: currentImage == null
                              ? _buildUploadButton()
                              : _buildImagePreview(),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                
                // Action buttons (fixed at bottom)
                Container(
                  padding: EdgeInsets.fromLTRB(padding, 0, padding, padding),
                  child: _buildActionButtons(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildProgressDot(1, 'Doc 1'),
        _buildProgressLine(currentStep > 1),
        _buildProgressDot(2, 'Doc 2'),
        _buildProgressLine(currentStep > 2),
        _buildProgressDot(3, 'Photo'),
      ],
    );
  }

  Widget _buildProgressDot(int step, String label) {
    final isActive = currentStep >= step;
    final isCompleted = currentStep > step;
    
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? const Color(0xFFE94B8B) : const Color(0xFF2A2A2A),
              border: Border.all(
                color: isActive ? const Color(0xFFE94B8B) : const Color(0xFF2A2A2A),
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      step.toString(),
                      style: TextStyle(
                        color: isActive ? Colors.white : const Color(0xFF6B7280),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : const Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Expanded(
      flex: 2,
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 30),
        color: isActive ? const Color(0xFFE94B8B) : const Color(0xFF2A2A2A),
      ),
    );
  }

  Widget _buildUploadButton() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        width: double.infinity,
        height: 280,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF2A2A2A),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2A2A2A),
              ),
              child: const Icon(
                Icons.add_photo_alternate,
                color: Color(0xFFE94B8B),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              currentStep == 3 ? 'Add Profile Picture' : 'Add Document Photo',
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Tap to take photo or choose from gallery',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF9CA3AF),
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE94B8B),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: currentStep == 3
                ? Image.file(
                    currentImage!,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    currentImage!,
                    fit: BoxFit.contain,
                  ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: _showImageSourceDialog,
          icon: const Icon(Icons.refresh, color: Color(0xFFE94B8B)),
          label: const Text(
            'Change Photo',
            style: TextStyle(
              color: Color(0xFFE94B8B),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final hasImage = currentImage != null;
    
    return Row(
      children: [
        if (currentStep > 1)
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  currentStep--;
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF2A2A2A)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Back',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (currentStep > 1) const SizedBox(width: 12),
        Expanded(
          flex: currentStep > 1 ? 2 : 1,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: hasImage
                  ? const LinearGradient(
                      colors: [Color(0xFFFF4081), Color(0xFFE91E63)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: hasImage ? null : const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(28.0),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28.0),
                onTap: hasImage ? _nextStep : null,
                child: Center(
                  child: Text(
                    currentStep == 3 ? 'Complete' : 'Next',
                    style: TextStyle(
                      color: hasImage ? Colors.white : const Color(0xFF6B7280),
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, 18),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
