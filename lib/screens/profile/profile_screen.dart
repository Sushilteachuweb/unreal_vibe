import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/responsive_helper.dart';
import '../../providers/user_provider.dart';
import '../../providers/event_provider.dart';
import 'widgets/profile_header.dart';
import 'widgets/host_mode_toggle.dart';
import 'widgets/host_mode_request_card.dart';
import 'widgets/verification_card.dart';
import 'widgets/my_profile_card.dart';
import 'widgets/settings_card.dart';
import 'widgets/achievements_card.dart';
import 'widgets/additional_options_card.dart';
import 'widgets/footer_links.dart';
import '../../widgets/skeleton_loading.dart';
import '../../widgets/app_bar_with_city.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with WidgetsBindingObserver {
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchProfileIfNeeded();
    
    // Initialize EventProvider with user's city
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventProvider = context.read<EventProvider>();
      final userProvider = context.read<UserProvider>();
      
      // Initialize city from user profile if available
      if (userProvider.user?.city != null) {
        eventProvider.initializeCityFromProfile(userProvider.user!.city);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reset loading state when app comes back to foreground
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      }
    }
  }

  // This method is called when returning from another screen
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reset loading states when returning to this screen
    if (mounted) {
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    }
  }

  Future<void> _fetchProfileIfNeeded() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Only show loading if we don't have cached data
    if (!userProvider.hasUserData) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      final result = await userProvider.fetchProfileIfNeeded();

      if (!mounted) return;

      if (!result['success'] && !userProvider.hasUserData) {
        setState(() => _hasError = true);
        
        // Show error message only if we don't have cached data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to load profile'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _onRefresh,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted && !userProvider.hasUserData) {
        setState(() => _hasError = true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onRefresh() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.fetchProfile(forceRefresh: true);
  }

  Widget _buildSkeletonLoading(double padding) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile header skeleton
            const ProfileHeaderSkeleton(),
            const SizedBox(height: 24),
            // Host mode toggle skeleton
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SkeletonLoading(width: 120, height: 18),
                  const SkeletonLoading(width: 50, height: 30, borderRadius: BorderRadius.all(Radius.circular(15))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Verification card skeleton
            const ProfileCardSkeleton(),
            const SizedBox(height: 24),
            // My profile card skeleton
            const ProfileCardSkeleton(),
            const SizedBox(height: 24),
            // Settings card skeleton
            const ProfileCardSkeleton(),
            const SizedBox(height: 24),
            // Achievements card skeleton
            const ProfileCardSkeleton(),
            const SizedBox(height: 24),
            // Additional options card skeleton
            const ProfileCardSkeleton(),
            const SizedBox(height: 32),
            // Footer links skeleton
            Column(
              children: [
                const SkeletonLoading(width: 150, height: 16),
                const SizedBox(height: 8),
                const SkeletonLoading(width: 120, height: 16),
                const SizedBox(height: 8),
                const SkeletonLoading(width: 100, height: 16),
              ],
            ),
            const SizedBox(height: 20),
            const SkeletonLoading(width: 200, height: 14),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.isMobile(context) 
        ? ResponsiveHelper.getMobilePadding(context)
        : ResponsiveHelper.getResponsivePadding(context, 16.0);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const AppBarWithCity(title: 'Unrealvibe'),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: const Color(0xFF6366F1),
        backgroundColor: Colors.white,
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.getMaxContentWidth(context),
            ),
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                // Show skeleton loading only when we have no user data and are loading
                if (_isLoading && !userProvider.hasUserData && !_hasError) {
                  return _buildSkeletonLoading(padding);
                }
                
                // Show main content
                return RefreshLoadingIndicator(
                  isLoading: userProvider.isLoading && userProvider.hasUserData,
                  child: SingleChildScrollView(
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
                          const HostModeRequestCard(),
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }

}
