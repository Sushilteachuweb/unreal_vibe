import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FooterLinks extends StatelessWidget {
  const FooterLinks({Key? key}) : super(key: key);

  // URL mappings for each link
  static const Map<String, String> _linkUrls = {
    'About Us': 'https://unrealvibe.com/#about',
    'T&C': 'https://unrealvibe.com/terms-conditions',
    'Privacy Policy': 'https://unrealvibe.com/privacy-policy',
    // 'Contact Us': 'https://unrealvibe.com/',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFooterLink('About Us'),
              _buildFooterLink('T&C'),
              _buildFooterLink('Privacy Policy'),
            ],
          ),
          // const SizedBox(height: 16),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     _buildFooterLink('Contact Us'),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return InkWell(
      onTap: () => _launchUrl(text),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF6366F1),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String linkText) async {
    final url = _linkUrls[linkText];
    if (url != null) {
      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          print('Could not launch $url');
        }
      } catch (e) {
        print('Error launching URL: $e');
      }
    }
  }
}

class Copyright extends StatelessWidget {
  const Copyright({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      '© 2024 Unreal Vibe. All rights reserved.',
      style: TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 12,
      ),
      textAlign: TextAlign.center,
    );
  }
}
