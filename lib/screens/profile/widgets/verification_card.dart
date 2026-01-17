import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';
import '../verify_profile_screen.dart';

class VerificationCard extends StatelessWidget {
  const VerificationCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        
        // Show subtle profile complete status if 100% complete
        if (user?.profileCompletion == 100) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: const Color(0xFF10B981).withOpacity(0.7),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Profile Complete',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${user?.profileCompletion ?? 0}%',
                    style: TextStyle(
                      color: const Color(0xFF10B981).withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Show verification progress if not complete
        final profileCompletion = user?.profileCompletion ?? 0;
        final hasDocuments = user?.documents != null;
        final hasProfilePhoto = user?.profilePhotoUrl != null;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A1A), Color(0xFF1F1F1F)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2A2A2A)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Verification Level',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Complete your profile verification',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 12),
              _buildProgressBar(profileCompletion),
              const SizedBox(height: 16),
              _buildVerificationItem(Icons.phone, 'Phone Verified', true),
              _buildVerificationItem(Icons.credit_card, 'ID Upload', hasDocuments),
              _buildVerificationItem(Icons.account_circle, 'Profile Photo Update', hasProfilePhoto),
              const SizedBox(height: 16),
              _buildCompleteVerificationButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(int profileCompletion) {
    String level = 'Level 1';
    if (profileCompletion >= 80) level = 'Level 3';
    else if (profileCompletion >= 50) level = 'Level 2';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              level,
              style: TextStyle(
                color: Color(0xFF6366F1),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$profileCompletion% Complete',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: profileCompletion / 100.0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: profileCompletion >= 80 
                      ? [Color(0xFF10B981), Color(0xFF059669)]
                      : [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationItem(IconData icon, String text, bool isVerified) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isVerified ? const Color(0xFF10B981).withOpacity(0.2) : const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: isVerified ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isVerified ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
                fontSize: 14,
              ),
            ),
          ),
          if (isVerified)
            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 20),
        ],
      ),
    );
  }

  Widget _buildCompleteVerificationButton() {
    return Builder(
      builder: (context) => Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VerifyProfileScreen(),
                ),
              );
            },
            child: const Center(
              child: Text(
                'Complete Verification',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
