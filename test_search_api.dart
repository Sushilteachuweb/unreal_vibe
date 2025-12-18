import 'package:flutter/material.dart';
import 'lib/services/search_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🧪 Testing Search API Integration');
  print('================================');
  
  // Test 1: Search with city only
  print('\n📍 Test 1: Search events in Delhi');
  try {
    final delhiEvents = await SearchService.searchEventsByCity('Delhi');
    print('✅ Found ${delhiEvents.length} events in Delhi');
    if (delhiEvents.isNotEmpty) {
      print('   First event: ${delhiEvents.first.title}');
    } else {
      print('   No events found in Delhi');
    }
  } catch (e) {
    print('❌ Error searching Delhi events: $e');
  }
  
  // Test 2: Search with query and city
  print('\n🎵 Test 2: Search "music" events in Delhi');
  try {
    final musicEvents = await SearchService.searchEvents(
      query: 'music',
      city: 'Delhi',
    );
    print('✅ Found ${musicEvents.length} music events in Delhi');
    if (musicEvents.isNotEmpty) {
      print('   First event: ${musicEvents.first.title}');
    } else {
      print('   No music events found in Delhi');
    }
  } catch (e) {
    print('❌ Error searching music events: $e');
  }
  
  // Test 3: Search with query only
  print('\n🔍 Test 3: Search "concert" events (no city filter)');
  try {
    final concertEvents = await SearchService.searchEventsByQuery('concert');
    print('✅ Found ${concertEvents.length} concert events');
    if (concertEvents.isNotEmpty) {
      print('   First event: ${concertEvents.first.title}');
    } else {
      print('   No concert events found');
    }
  } catch (e) {
    print('❌ Error searching concert events: $e');
  }
  
  // Test 3b: Search with pagination
  print('\n📄 Test 3b: Search with pagination info');
  try {
    final searchResult = await SearchService.searchEventsWithPagination(
      query: 'music',
      city: 'Delhi',
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
  } catch (e) {
    print('❌ Error in pagination search: $e');
  }
  
  // Test 4: Get search suggestions
  print('\n💡 Test 4: Get search suggestions for Delhi');
  final suggestions = SearchService.getSearchSuggestions('Delhi');
  print('✅ Got ${suggestions.length} suggestions:');
  for (int i = 0; i < suggestions.take(5).length; i++) {
    print('   ${i + 1}. ${suggestions[i]}');
  }
  
  // Test 5: Validation functions
  print('\n✔️ Test 5: Validation functions');
  print('   Valid query "music": ${SearchService.isValidSearchQuery('music')}');
  print('   Invalid query "a": ${SearchService.isValidSearchQuery('a')}');
  print('   Valid city "Delhi": ${SearchService.isValidCity('Delhi')}');
  print('   Invalid city "": ${SearchService.isValidCity('')}');
  
  print('\n🎉 Search API integration tests completed!');
}