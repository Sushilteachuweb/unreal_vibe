import 'package:flutter_test/flutter_test.dart';
import 'package:unreal_vibe/models/event_model.dart';

void main() {
  group('Event Tags Tests', () {
    test('should parse category string format correctly', () {
      // Sample API response with new format
      final sampleEventData = {
        '_id': '693fe9c0949a5ad24d9f90d6',
        'eventName': 'New Year Bash 2026',
        'date': '2025-12-31T00:00:00.000Z',
        'city': 'Gurgaon',
        'fullAddress': 'Canvas Laugh Club, DLF Cyber Hub, Gurgaon',
        'entryFees': 1500,
        'eventImage': 'http://api.unrealvibe.com/uploads/test.png',
        'category': 'music, festival', // New string format
        'ageRestriction': '21+',
        'status': 'Just Started',
      };

      final event = Event.fromJson(sampleEventData);

      // Verify tags are created correctly
      expect(event.tags, isNotEmpty);
      
      // Should contain category tags
      expect(event.tags.any((tag) => tag.contains('MUSIC')), isTrue);
      expect(event.tags.any((tag) => tag.contains('FESTIVAL')), isTrue);
      
      // Should contain age restriction
      expect(event.tags.any((tag) => tag.startsWith('AGE:')), isTrue);
      expect(event.tags.any((tag) => tag.contains('21+')), isTrue);
      
      print('✅ Event tags: ${event.tags}');
    });

    test('should handle both old and new category formats', () {
      // Test old array format
      final oldFormatData = {
        '_id': 'test1',
        'eventName': 'Test Event',
        'date': '2025-12-31T00:00:00.000Z',
        'city': 'Test City',
        'fullAddress': 'Test Address',
        'entryFees': 1000,
        'eventImage': 'test.png',
        'categories': ['music', 'party'], // Old array format
        'ageRestriction': '18+',
      };

      final oldEvent = Event.fromJson(oldFormatData);
      expect(oldEvent.tags.any((tag) => tag.contains('MUSIC')), isTrue);
      expect(oldEvent.tags.any((tag) => tag.contains('PARTY')), isTrue);
      
      // Test new string format
      final newFormatData = {
        '_id': 'test2',
        'eventName': 'Test Event 2',
        'date': '2025-12-31T00:00:00.000Z',
        'city': 'Test City',
        'fullAddress': 'Test Address',
        'entryFees': 1000,
        'eventImage': 'test.png',
        'category': 'comedy, standup', // New string format
        'ageRestriction': '21+',
      };

      final newEvent = Event.fromJson(newFormatData);
      expect(newEvent.tags.any((tag) => tag.contains('COMEDY')), isTrue);
      expect(newEvent.tags.any((tag) => tag.contains('STANDUP')), isTrue);
      
      print('✅ Old format tags: ${oldEvent.tags}');
      print('✅ New format tags: ${newEvent.tags}');
    });

    test('should prioritize age and category tags', () {
      final eventData = {
        '_id': 'test3',
        'eventName': 'Test Event 3',
        'date': '2025-12-31T00:00:00.000Z',
        'city': 'Test City',
        'fullAddress': 'Test Address',
        'entryFees': 1000,
        'eventImage': 'test.png',
        'category': 'music, festival',
        'ageRestriction': '21+',
        'status': 'Just Started',
      };

      final event = Event.fromJson(eventData);
      
      // Should have age restriction tag
      final ageTag = event.tags.firstWhere((tag) => tag.startsWith('AGE:'), orElse: () => '');
      expect(ageTag, isNotEmpty);
      expect(ageTag, equals('AGE: 21+'));
      
      // Should have category tags
      expect(event.tags.any((tag) => tag == 'MUSIC'), isTrue);
      expect(event.tags.any((tag) => tag == 'FESTIVAL'), isTrue);
      
      print('✅ All tags: ${event.tags}');
    });
  });
}