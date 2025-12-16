import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';

class HostModeToggle extends StatelessWidget {
  const HostModeToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        final isHost = user?.isHost ?? false;
        final isHostVerified = user?.isHostVerified ?? false;
        final eventsHosted = user?.eventsHosted ?? 0;
        final profileCompletion = user?.profileCompletion ?? 0;
        
        if (!isHost && profileCompletion < 100) {
          // Show subtle "Complete Profile" message for non-hosts
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
                  Icons.event_outlined,
                  color: const Color(0xFF6366F1).withOpacity(0.7),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Become a Host',
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
                    color: const Color(0xFF6366F1).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$profileCompletion%',
                    style: TextStyle(
                      color: const Color(0xFF6366F1).withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        // Show compact host status for hosts
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.star_outline,
                    color: const Color(0xFF6366F1).withOpacity(0.7),
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          'Host Mode',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (isHostVerified)
                          Icon(
                            Icons.verified,
                            color: const Color(0xFF10B981).withOpacity(0.7),
                            size: 14,
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: const Color(0xFF10B981).withOpacity(0.8),
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Compact host stats
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          '$eventsHosted',
                          style: TextStyle(
                            color: const Color(0xFF6366F1).withOpacity(0.8),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Events Hosted',
                          style: TextStyle(
                            color: const Color(0xFF9CA3AF).withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        isHostVerified ? Icons.verified : Icons.pending,
                        color: isHostVerified 
                            ? const Color(0xFF10B981).withOpacity(0.7) 
                            : const Color(0xFFF59E0B).withOpacity(0.7),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isHostVerified ? 'Verified' : 'Pending',
                        style: TextStyle(
                          color: isHostVerified 
                              ? const Color(0xFF10B981).withOpacity(0.7) 
                              : const Color(0xFFF59E0B).withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
