import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8), // Removed horizontal padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildNavItem(
                  icon: Icons.home,
                  label: 'Home',
                  index: 0,
                  isActive: currentIndex == 0,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.explore,
                  label: 'Explore',
                  index: 1,
                  isActive: currentIndex == 1,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.add_circle_outlined,
                  label: 'Host',
                  index: 2,
                  isActive: currentIndex == 2,
                  isSpecial: true,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.confirmation_number,
                  label: 'Tickets',
                  index: 3,
                  isActive: currentIndex == 3,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  index: 4,
                  isActive: currentIndex == 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
    bool isSpecial = false,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: isSpecial ? const EdgeInsets.all(4) : EdgeInsets.zero,
            decoration: isSpecial
                ? BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6958CA), Color(0xFF8A7BFF)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  )
                : null,
            child: Icon(
              icon,
              size: isSpecial ? 32 : 24,
              color: isActive
                  ? (isSpecial ? Colors.white : Color(0xFF6958CA))
                  : Colors.grey[300],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? Color(0xFF6958CA) : Colors.grey[600],
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
