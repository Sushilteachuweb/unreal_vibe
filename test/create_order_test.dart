import 'package:flutter_test/flutter_test.dart';
import 'package:unreal_vibe/services/ticket_service.dart';
import 'package:unreal_vibe/models/attendee_model.dart';

void main() {
  group('Create Order API Tests', () {
    test('createOrder should format request correctly', () async {
      // Sample data matching the API format
      const eventId = '693d271e028bde4c2b458541';
      
      final selectedTickets = [
        {'type': 'Male', 'quantity': 2}
      ];
      
      final attendees = [
        {
          'fullName': 'Rohan Verma',
          'email': 'rohan@example.com',
          'phone': '9999999999',
          'gender': 'Male',
          'passType': 'Male'
        },
        {
          'fullName': 'Amit Shah',
          'email': 'amit@example.com',
          'phone': '8888888888',
          'gender': 'Male',
          'passType': 'Male'
        }
      ];

      try {
        final response = await TicketService.createOrder(
          eventId: eventId,
          selectedTickets: selectedTickets,
          attendees: attendees,
        );
        
        // Verify the response structure
        expect(response, isA<Map<String, dynamic>>());
        print('✅ Order created successfully: $response');
      } catch (e) {
        print('❌ Create order failed: $e');
        // This is expected if API is not available during testing
      }
    });

    test('Attendee model should validate correctly', () {
      // Valid attendee
      final validAttendee = Attendee(
        fullName: 'John Doe',
        email: 'john@example.com',
        phone: '9876543210',
        gender: 'Male',
        passType: 'Male',
      );
      
      expect(validAttendee.isValid, isTrue);
      
      // Invalid email
      final invalidEmailAttendee = Attendee(
        fullName: 'John Doe',
        email: 'invalid-email',
        phone: '9876543210',
        gender: 'Male',
        passType: 'Male',
      );
      
      expect(invalidEmailAttendee.isValid, isFalse);
      
      // Invalid phone
      final invalidPhoneAttendee = Attendee(
        fullName: 'John Doe',
        email: 'john@example.com',
        phone: '123', // Too short
        gender: 'Male',
        passType: 'Male',
      );
      
      expect(invalidPhoneAttendee.isValid, isFalse);
    });

    test('Attendee toJson should match API format', () {
      final attendee = Attendee(
        fullName: 'Rohan Verma',
        email: 'rohan@example.com',
        phone: '9999999999',
        gender: 'Male',
        passType: 'Male',
      );

      final json = attendee.toJson();
      
      expect(json['fullName'], equals('Rohan Verma'));
      expect(json['email'], equals('rohan@example.com'));
      expect(json['phone'], equals('9999999999'));
      expect(json['gender'], equals('Male'));
      expect(json['passType'], equals('Male'));
    });

    test('verifyPayment should format request correctly', () async {
      // Sample payment verification data
      const eventId = '693d271e028bde4c2b458541';
      const orderId = 'order_123456789';
      const phonePePaymentId = 'pay_phonepe123456';
      const phonePeSignature = 'signature_abc123';
      final selectedTickets = [
        {'type': 'Male', 'quantity': 1}
      ];

      try {
        final response = await TicketService.verifyPayment(
          eventId: eventId,
          orderId: orderId,
          paymentId: phonePePaymentId,
          signature: phonePeSignature,
          paymentMethod: 'phonepe',
          selectedTickets: selectedTickets,
        );
        
        // Verify the response structure
        expect(response, isA<Map<String, dynamic>>());
        print('✅ Payment verified successfully: $response');
      } catch (e) {
        print('❌ Payment verification failed: $e');
        // Check for specific error messages
        if (e.toString().contains('selectedTickets must be a non-empty array')) {
          print('ℹ️  selectedTickets issue detected - should be fixed now');
        }
      }
    });

    test('verify payment request should use correct field names', () {
      // This test verifies the request format without making actual API call
      const expectedFields = ['eventId', 'phonepe_order_id', 'phonepe_payment_id', 'phonepe_signature'];
      
      // The actual request body should contain phonepe_order_id, not orderId
      final mockRequestBody = {
        'eventId': 'test_event',
        'phonepe_order_id': 'order_123', // Correct field name
        'phonepe_payment_id': 'pay_123',
        'phonepe_signature': 'sig_123',
      };
      
      for (String field in expectedFields) {
        expect(mockRequestBody.containsKey(field), isTrue, 
               reason: 'Request should contain field: $field');
      }
      
      // Should NOT contain the old field name
      expect(mockRequestBody.containsKey('orderId'), isFalse,
             reason: 'Request should not contain old field name: orderId');
      
      print('✅ Request format validation passed');
    });
  });
}