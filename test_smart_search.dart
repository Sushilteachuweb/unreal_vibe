import 'package:flutter/material.dart';
import 'lib/services/search_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🧪 Testing Smart Search Logic');
  print('=============================');
  
  // Test 1: Search for city name in same city (should use city-only search)
  print('\n🎯 Test 1: Search "Noida" while in Noida (smart city search)');
  try {
    final results = await SearchService.searchInCity('Noida', 'Noida');
    print('✅ Found ${results.length} events using smart search');
    if (results.isNotEmpty) {
      print('   First event: ${results.first.title}');
    }
  } catch (e) {
    print('❌ Error in smart search: $e');
  }
  
  // Test 2: Regular search with different query and city
  print('\n🔍 Test 2: Search "music" while in Noida (regular search)');
  try {
    final results = await SearchService.searchInCity('music', 'Noida');
    print('✅ Found ${results.length} events using regular search');
    if (results.isNotEmpty) {
      print('   First event: ${results.first.title}');
    }
  } catch (e) {
    print('❌ Error in regular search: $e');
  }
  
  // Test 3: Search for different city name
  print('\n🏙️ Test 3: Search "Delhi" while in Noida (city name detection)');
  try {
    final results = await SearchService.searchInCity('Delhi', 'Noida');
    print('✅ Found ${results.length} events searching for Delhi');
    if (results.isNotEmpty) {
      print('   First event: ${results.first.title}');
    }
  } catch (e) {
    print('❌ Error searching Delhi: $e');
  }
  
  // Test 4: Compare old vs new approach
  print('\n⚖️ Test 4: Compare old vs new search approach');
  try {
    print('   Old approach (query + city):');
    final oldResults = await SearchService.searchEvents(query: 'Noida', city: 'Noida');
    print('   Found ${oldResults.length} events');
    
    print('   New approach (smart search):');
    final newResults = await SearchService.searchInCity('Noida', 'Noida');
    print('   Found ${newResults.length} events');
    
    if (newResults.length > oldResults.length) {
      print('   ✅ Smart search found more results!');
    } else if (newResults.length == oldResults.length) {
      print('   ℹ️ Same number of results');
    } else {
      print('   ⚠️ Old approach found more results');
    }
  } catch (e) {
    print('❌ Error in comparison: $e');
  }
  
  // Test 5: City-only search (what should work)
  print('\n🏙️ Test 5: Direct city-only search');
  try {
    final results = await SearchService.searchEventsByCity('Noida');
    print('✅ Found ${results.length} events with city-only search');
    if (results.isNotEmpty) {
      print('   First event: ${results.first.title}');
    }
  } catch (e) {
    print('❌ Error in city-only search: $e');
  }
  
  print('\n🎉 Smart search tests completed!');
}