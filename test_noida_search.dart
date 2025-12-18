import 'package:flutter/material.dart';
import 'lib/services/search_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🧪 Testing Noida Search (Matching Postman Test)');
  print('===============================================');
  
  // Test 1: Search events in Noida (city only - matching Postman)
  print('\n📍 Test 1: Search events in Noida (city only)');
  try {
    final noidaEvents = await SearchService.searchEventsByCity('Noida');
    print('✅ Found ${noidaEvents.length} events in Noida');
    if (noidaEvents.isNotEmpty) {
      for (int i = 0; i < noidaEvents.length; i++) {
        final event = noidaEvents[i];
        print('   Event ${i + 1}: ${event.title}');
        print('     - City: ${event.city}');
        print('     - Location: ${event.location}');
        print('     - Cover Charge: ${event.coverCharge}');
      }
    } else {
      print('   ❌ No events found in Noida');
    }
  } catch (e) {
    print('❌ Error searching Noida events: $e');
  }
  
  // Test 2: Search with query "Noida" and city "Noida"
  print('\n🔍 Test 2: Search "Noida" in Noida');
  try {
    final results = await SearchService.searchEvents(
      query: 'Noida',
      city: 'Noida',
    );
    print('✅ Found ${results.length} events for "Noida" in Noida');
    if (results.isNotEmpty) {
      for (int i = 0; i < results.length; i++) {
        final event = results[i];
        print('   Event ${i + 1}: ${event.title}');
        print('     - City: ${event.city}');
        print('     - Location: ${event.location}');
      }
    } else {
      print('   ❌ No events found for "Noida" in Noida');
    }
  } catch (e) {
    print('❌ Error searching "Noida" in Noida: $e');
  }
  
  // Test 3: Search with empty query and city "Noida" (should return all Noida events)
  print('\n📍 Test 3: Search all events in Noida (empty query)');
  try {
    final results = await SearchService.searchEvents(
      query: '',
      city: 'Noida',
    );
    print('✅ Found ${results.length} events in Noida (empty query)');
    if (results.isNotEmpty) {
      for (int i = 0; i < results.length; i++) {
        final event = results[i];
        print('   Event ${i + 1}: ${event.title}');
      }
    } else {
      print('   ❌ No events found in Noida (empty query)');
    }
  } catch (e) {
    print('❌ Error searching all Noida events: $e');
  }
  
  // Test 4: Test with pagination
  print('\n📄 Test 4: Search Noida events with pagination');
  try {
    final searchResult = await SearchService.searchEventsWithPagination(
      city: 'Noida',
    );
    print('✅ Search completed - Success: ${searchResult.success}');
    print('   Events found: ${searchResult.events.length}');
    print('   Total results: ${searchResult.totalResults}');
    if (searchResult.pagination != null) {
      final p = searchResult.pagination!;
      print('   Page: ${p.page}/${p.totalPages}');
      print('   Has more: ${p.hasNext}');
    }
    if (searchResult.appliedFilters != null) {
      print('   Applied filters: ${searchResult.appliedFilters}');
    }
    
    if (searchResult.events.isNotEmpty) {
      final event = searchResult.events.first;
      print('   First event details:');
      print('     - ID: ${event.id}');
      print('     - Title: ${event.title}');
      print('     - City: ${event.city}');
      print('     - Cover Charge: ${event.coverCharge}');
    }
  } catch (e) {
    print('❌ Error in Noida pagination search: $e');
  }
  
  print('\n🎉 Noida search tests completed!');
}