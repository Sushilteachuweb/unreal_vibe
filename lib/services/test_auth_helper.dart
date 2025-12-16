import 'user_storage.dart';

class TestAuthHelper {
  /// For testing purposes - simulate a logged in user
  /// In production, this should be replaced with proper authentication
  static Future<void> simulateLogin() async {
    // Save a test token (this would normally come from the API)
    await UserStorage.saveToken('test_bearer_token_12345');
    await UserStorage.saveLoginStatus(true);
    await UserStorage.saveUserId('test_user_id');
    
    print('🔐 Test authentication simulated');
  }
  
  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await UserStorage.getToken();
    final isLoggedIn = await UserStorage.getLoginStatus();
    return token != null && isLoggedIn;
  }
  
  /// Clear authentication
  static Future<void> logout() async {
    await UserStorage.clearAll();
    print('🚪 Test authentication cleared');
  }
}