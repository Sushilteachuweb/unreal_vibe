import 'package:flutter/material.dart';

class MyProfileCard extends StatelessWidget {
  const MyProfileCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          _buildProfileItem('Bio / About Me', () {}),
          _buildDivider(),
          
          // Fun Fact About Me
          _buildProfileItem('Fun Fact About Me', () {}),
          
          const SizedBox(height: 24),
          
          // My Vibe / Interests
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
            children: [
              _buildInterestTag('EDM'),
              _buildInterestTag('Techno'),
              _buildInterestTag('House Parties'),
              _buildInterestTag('Travel'),
              _buildInterestTag('Photography'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: const Color(0xFF2A2A2A),
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
