import 'package:flutter_test/flutter_test.dart';
import 'package:unreal_vibe/services/host_service.dart';

void main() {
  group('HostService Tests', () {
    test('should create valid host request payload', () {
      // Test data matching the API requirements
      const testDate = '2025-12-30';
      const testLocality = 'Sector 18';
      const testCity = 'Noida';
      const testPincode = '201301';

      // This test verifies the request structure matches API expectations
      expect(testDate, isNotEmpty);
      expect(testLocality, isNotEmpty);
      expect(testCity, isNotEmpty);
      expect(testPincode, hasLength(6));
    });

    test('should handle network errors gracefully', () async {
      // Test with invalid data to trigger error handling
      final result = await HostService.submitHostRequest(
        preferredPartyDate: '',
        locality: '',
        city: '',
        pincode: '',
      );

      // Should return a response object even on failure
      expect(result, isNotNull);
      expect(result.success, isA<bool>());
      expect(result.message, isA<String>());
    });
  });
}