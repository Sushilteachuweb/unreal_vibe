import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/responsive_helper.dart';
import '../../providers/user_provider.dart';
import 'widgets/profile_header.dart';
import 'widgets/host_mode_toggle.dart';
import 'widgets/verification_card.dart';
import 'widgets/my_profile_card.dart';
import 'widgets/settings_card.dart';
import 'widgets/achievements_card.dart';
import 'widgets/additional_options_card.dart';
import 'widgets/footer_links.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final result = await userProvider.fetchProfile();

      if (!mounted) return;

      if (!result['success']) {
        setState(() => _hasError = true);
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to load profile'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _fetchProfile,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _hasError = true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context, 16.0);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _fetchProfile,
        color: const Color(0xFF6366F1),
        backgroundColor: Colors.white,
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.getMaxContentWidth(context),
            ),
            child: _isLoading && !_hasError
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6366F1),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          const ProfileHeader(),
                          const SizedBox(height: 24),
                          const HostModeToggle(),
                          const SizedBox(height: 24),
                          const VerificationCard(),
                          const SizedBox(height: 24),
                          const MyProfileCard(),
                          const SizedBox(height: 24),
                          const SettingsCard(),
                          const SizedBox(height: 24),
                          const AchievementsCard(),
                          const SizedBox(height: 24),
                          const AdditionalOptionsCard(),
                          const SizedBox(height: 32),
                          const FooterLinks(),
                          const SizedBox(height: 20),
                          const Copyright(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Unrealvibes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final userCity = userProvider.user?.city ?? 'Noida';
              return Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    userCity,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

