import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';

class MyProfileCard extends StatelessWidget {
  const MyProfileCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // My Profile Title
              Center(
                child: Text(
                  'My Profile',
                  style: TextStyle(
                    color: const Color(0xFFE91E63), // Pink/Magenta color
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Bio / About Me
              if (user?.bio != null && user!.bio!.isNotEmpty) ...[
                _buildProfileSection('Bio / About Me', user.bio!),
                const SizedBox(height: 16),
              ],
              
              // Fun Fact About Me
              if (user?.funFact != null && user!.funFact!.isNotEmpty) ...[
                _buildProfileSection('Fun Fact About Me', user.funFact!),
                const SizedBox(height: 16),
              ],
              
              // My Vibe / Interests
              if (user?.interests != null && user!.interests!.isNotEmpty) ...[
                Text(
                  'My Vibe / Interests',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Interest Tags
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: user.interests!.map((interest) => _buildInterestTag(interest)).toList(),
                ),
              ],
              
              // Show message if no profile data
              if ((user?.bio?.isEmpty ?? true) && 
                  (user?.funFact?.isEmpty ?? true) && 
                  (user?.interests?.isEmpty ?? true)) ...[
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 48,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Complete your profile to show your bio, fun facts, and interests!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            content,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF6958CA).withOpacity(0.8),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
