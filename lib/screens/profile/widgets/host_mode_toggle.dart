import 'package:flutter/material.dart';

class HostModeToggle extends StatefulWidget {
  const HostModeToggle({Key? key}) : super(key: key);

  @override
  State<HostModeToggle> createState() => _HostModeToggleState();
}

class _HostModeToggleState extends State<HostModeToggle> {
  bool isHostMode = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Host Mode',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Create and manage events',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Switch(
            value: isHostMode,
            onChanged: (value) => setState(() => isHostMode = value),
            activeColor: const Color(0xFF6366F1),
            activeTrackColor: const Color(0xFF6366F1).withOpacity(0.3),
            inactiveThumbColor: const Color(0xFF9CA3AF),
            inactiveTrackColor: const Color(0xFF2A2A2A),
          ),
        ],
      ),
    );
  }
}
