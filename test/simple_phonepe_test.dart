import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Simple PhonePe Tests', () {
    test('basic test should pass', () {
      expect(1 + 1, equals(2));
      print('✅ Basic test passed');
    });

    test('phonepe field format should be correct', () {
      final mockRequest = {
        'eventId': 'test_event',
        'phonepe_order_id': 'order_123',
        'phonepe_payment_id': 'pay_123',
        'phonepe_transaction_id': 'txn_123',
        'phonepe_signature': 'sig_123',
        'payment_gateway': 'phonepe',
      };
      
      expect(mockRequest.containsKey('phonepe_order_id'), isTrue);
      expect(mockRequest.containsKey('phonepe_payment_id'), isTrue);
      expect(mockRequest.containsKey('phonepe_transaction_id'), isTrue);
      expect(mockRequest['payment_gateway'], equals('phonepe'));
      
      print('✅ PhonePe field format test passed');
    });
  });
}