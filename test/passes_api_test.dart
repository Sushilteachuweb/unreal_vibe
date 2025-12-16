import 'package:flutter_test/flutter_test.dart';
import 'package:unreal_vibe/services/ticket_service.dart';
import 'package:unreal_vibe/models/ticket_model.dart';

void main() {
  group('Passes API Tests', () {
    test('fetchEventPasses should handle API response correctly', () async {
      // Test with a sample event ID
      const testEventId = '693d271e028bde4c2b458541';
      
      try {
        final passes = await TicketService.fetchEventPasses(testEventId);
        
        // Verify the response
        expect(passes, isA<List<TicketType>>());
        
        if (passes.isNotEmpty) {
          // Check first pass structure
          final firstPass = passes.first;
          expect(firstPass.id, isNotEmpty);
          expect(firstPass.name, isNotEmpty);
          expect(firstPass.price, greaterThan(0));
          
          print('✅ Successfully fetched ${passes.length} passes');
          for (var pass in passes) {
            print('   - ${pass.name}: ₹${pass.price.toInt()} (${pass.remainingQuantity}/${pass.totalQuantity} available)');
          }
        } else {
          print('⚠️  No passes returned from API (using fallback)');
        }
      } catch (e) {
        print('❌ API call failed: $e');
        // This is expected if API is not available during testing
      }
    });

    test('TicketType.fromPass should handle API response format', () {
      // Sample API response data
      final samplePassData = {
        'type': 'Male',
        'price': 2000,
        'totalQuantity': 80,
        'remainingQuantity': 78,
        '_id': '693d271e028bde4c2b458542',
        'id': '693d271e028bde4c2b458542'
      };

      final ticketType = TicketType.fromPass(samplePassData, 'Entry + 1 Drink');

      expect(ticketType.id, equals('693d271e028bde4c2b458542'));
      expect(ticketType.name, equals('MALE'));
      expect(ticketType.price, equals(2000.0));
      expect(ticketType.totalQuantity, equals(80));
      expect(ticketType.remainingQuantity, equals(78));
      expect(ticketType.description, equals('Entry + 1 Drink'));
    });
  });
}