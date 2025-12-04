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
import 'widgets/dark_mode_switch.dart';
import 'widgets/footer_links.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context, 16.0);
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: ResponsiveHelper.getMaxContentWidth(context),
          ),
          child: SingleChildScrollView(
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
                  const SizedBox(height: 24),
                  const DarkModeSwitch(),
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

