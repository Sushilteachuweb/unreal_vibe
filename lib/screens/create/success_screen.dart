import 'package:flutter/material.dart';
import '../../navigation/main_navigation.dart';
import '../../utils/responsive_helper.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getResponsivePadding(context, 24.0);
    final maxWidth = ResponsiveHelper.getMaxContentWidth(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  width: ResponsiveHelper.isDesktop(context) ? 150 : 120,
                  height: ResponsiveHelper.isDesktop(context) ? 150 : 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFF1B6B).withOpacity(0.3),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: ResponsiveHelper.isDesktop(context) ? 100 : 80,
                      height: ResponsiveHelper.isDesktop(context) ? 100 : 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFF1B6B),
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.check,
                        color: Color(0xFFFF1B6B),
                        size: ResponsiveHelper.isDesktop(context) ? 60 : 48,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Thank You!',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 36),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your submission has been received. Our executive will get in touch with you shortly with more details.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(context, 15),
                    color: Color(0xFF9CA3AF),
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                // Return to Home Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF1B6B), Color(0xFFAB47BC)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const MainNavigation(initialIndex: 0),
                          ),
                          (route) => false,
                        );
                      },
                      borderRadius: BorderRadius.circular(28),
                      child: const Center(
                        child: Text(
                          'Return to Home',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Explore Events Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF2C2C2E),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const MainNavigation(initialIndex: 1),
                          ),
                          (route) => false,
                        );
                      },
                      borderRadius: BorderRadius.circular(28),
                      child: const Center(
                        child: Text(
                          'Explore Events',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFAB47BC),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
