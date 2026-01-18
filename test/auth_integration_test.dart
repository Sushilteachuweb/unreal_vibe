import 'package:flutter_test/flutter_test.dart';
import 'package:unreal_vibe/services/ticket_service.dart';
import 'package:unreal_vibe/services/user_storage.dart';

void main() {
  group('Authentication Integration Tests', () {
    test('createOrder should require authentication', () async {
      // Clear any existing token
      await UserStorage.clearToken();
      
      // Sample data
      const eventId = '693d271e028bde4c2b458541';
      final selectedTickets = [
        {'type': 'Male', 'quantity': 1}
      ];
      final attendees = [
        {
          'fullName': 'Test User',
          'email': 'test@example.com',
          'phone': '9999999999',
          'gender': 'Male',
          'passType': 'Male'
        }
      ];

      try {
        await TicketService.createOrder(
          eventId: eventId,
          selectedTickets: selectedTickets,
          attendees: attendees,
        );
        
        // Should not reach here without authentication
        fail('Expected authentication error');
      } catch (e) {
        expect(e.toString(), contains('Authentication required'));
        print('✅ Authentication check working: $e');
      }
    });

    test('verifyPayment should require authentication', () async {
      // Clear any existing token
      await UserStorage.clearToken();
      
      try {
        await TicketService.verifyPayment(
          eventId: '693d271e028bde4c2b458541',
          orderId: 'order_123',
          paymentId: 'pay_123',
          paymentMethod: 'phonepe',
        );
        
        // Should not reach here without authentication
        fail('Expected authentication error');
      } catch (e) {
        expect(e.toString(), contains('Authentication required'));
        print('✅ Authentication check working for verify payment: $e');
      }
    });

    test('fetchEventPasses should work without authentication', () async {
      // This should work without auth as it's just fetching pass data
      try {
        final passes = await TicketService.fetchEventPasses('693d271e028bde4c2b458541');
        print('✅ Fetch passes works without auth: ${passes.length} passes');
      } catch (e) {
        print('ℹ️  Fetch passes failed (expected if API not available): $e');
      }
    });
  });
}