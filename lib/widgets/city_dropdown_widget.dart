import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';

class CityDropdownWidget extends StatefulWidget {
  const CityDropdownWidget({super.key});

  @override
  State<CityDropdownWidget> createState() => _CityDropdownWidgetState();
}

class _CityDropdownWidgetState extends State<CityDropdownWidget> {
  final List<String> _availableCities = ['Delhi', 'Noida', 'Gurgaon'];

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        return PopupMenuButton<String>(
          onSelected: (String city) async {
            print('🎯 [CityDropdown] City selected: $city');
            await eventProvider.changeCity(city);
            print('🎯 [CityDropdown] City change completed');
          },
          itemBuilder: (BuildContext context) {
            return _availableCities.map((String city) {
              final isSelected = city == eventProvider.selectedCity;
              return PopupMenuItem<String>(
                value: city,
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: isSelected 
                          ? const Color(0xFF6958CA)
                          : Colors.white.withOpacity(0.7),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        city,
                        style: TextStyle(
                          color: isSelected 
                              ? const Color(0xFF6958CA)
                              : Colors.white,
                          fontSize: 14,
                          fontWeight: isSelected 
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check,
                        color: Color(0xFF6958CA),
                        size: 16,
                      ),
                  ],
                ),
              );
            }).toList();
          },
          color: const Color(0xFF1A1A1A),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                eventProvider.selectedCity,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}