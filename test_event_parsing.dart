import 'dart:convert';
import 'lib/models/event_model.dart';

void main() {
  print('🧪 Testing Event Parsing with Real API Response');
  print('===============================================');
  
  // Real API response from Postman
  const String apiResponse = '''
  {
    "success": true,
    "data": {
      "events": [
        {
          "_id": "6942766071a29237dc6ca7d1",
          "hostId": {
            "_id": "69400bc9192ead67852e2c5d",
            "eventsHosted": 2,
            "name": "sushil"
          },
          "hostedBy": "sushil",
          "eventName": "Rooftop Sunset Party",
          "subtitle": "Sunset | Music | Cocktails",
          "eventImage": "http://api.unrealvibe.com/uploads/1765963360096-686757980.png",
          "date": "2025-01-25T00:00:00.000Z",
          "time": "06:00 PM",
          "day": "Saturday",
          "eventDateTime": "2025-01-25T06:00:00.000Z",
          "fullAddress": "Sector 18, Noida",
          "city": "Noida",
          "about": "Relaxed rooftop party with sunset views.",
          "partyFlow": "Entry → Welcome Drinks → DJ Night → Countdown → Fireworks",
          "partyEtiquette": "Dress code mandatory",
          "whatsIncluded": "DJ, Dance Floor, Fireworks",
          "houseRules": "No recording allowed; follow club guidelines; keep phones on silent mode.",
          "howItWorks": "Book your ticket → Receive QR code → Scan at venue → Enjoy the show.",
          "cancellationPolicy": "Tickets are non-refundable unless the event is cancelled.",
          "ageRestriction": "21+",
          "whatsIncludedInTicket": "Entry + 1 Drink",
          "expectedGuestCount": "120",
          "maleToFemaleRatio": "60:40",
          "category": "Rooftop Party",
          "thingsToKnow": "Carry ID proof",
          "partyTerms": "No outside alcohol",
          "maxCapacity": 300,
          "currentBookings": 7,
          "averageRating": 3.3333333333333335,
          "totalReviews": 3,
          "shareCount": 2,
          "passes": [
            {
              "type": "Male",
              "price": 1499,
              "totalQuantity": 60,
              "remainingQuantity": 60,
              "_id": "6942766071a29237dc6ca7d2"
            },
            {
              "type": "Female",
              "price": 799,
              "totalQuantity": 40,
              "remainingQuantity": 40,
              "_id": "6942766071a29237dc6ca7d3"
            },
            {
              "type": "Couple",
              "price": 2299,
              "totalQuantity": 20,
              "remainingQuantity": 20,
              "_id": "6942766071a29237dc6ca7d4"
            }
          ],
          "location": {
            "type": "Point",
            "coordinates": [77.3218196, 28.570317]
          },
          "sharedBy": [
            {
              "user": "6940021c192ead67852e2b42",
              "_id": "69427fe130e63a28a26b41b1",
              "sharedAt": "2025-12-17T10:03:13.526Z"
            },
            {
              "user": "6942aa6930e63a28a26b42ea",
              "_id": "6942aa8630e63a28a26b42f8",
              "sharedAt": "2025-12-17T13:05:10.995Z"
            }
          ],
          "createdAt": "2025-12-17T09:22:40.359Z",
          "updatedAt": "2025-12-18T08:40:54.079Z",
          "__v": 2,
          "bookingPercentage": 2,
          "totalEventsHosted": 2
        }
      ],
      "pagination": {
        "total": 1,
        "page": 1,
        "limit": 15,
        "totalPages": 1,
        "hasNext": false,
        "hasPrev": false
      },
      "appliedFilters": {
        "textSearch": false,
        "city": "Noida",
        "nearbyApplied": false,
        "radiusKm": null
      }
    }
  }
  ''';
  
  try {
    print('📡 Parsing API response...');
    final Map<String, dynamic> data = json.decode(apiResponse);
    
    if (data['success'] == true && data['data'] != null && data['data']['events'] != null) {
      final List<dynamic> eventsJson = data['data']['events'];
      print('✅ Found ${eventsJson.length} events in API response');
      
      for (int i = 0; i < eventsJson.length; i++) {
        try {
          print('\\n🎯 Parsing event ${i + 1}...');
          final event = Event.fromJson(eventsJson[i]);
          
          print('✅ Successfully parsed event:');
          print('   ID: ${event.id}');
          print('   Title: ${event.title}');
          print('   Subtitle: ${event.subtitle}');
          print('   Date: ${event.date}');
          print('   Time: ${event.time}');
          print('   Location: ${event.location}');
          print('   Full Address: ${event.fullAddress}');
          print('   City: ${event.city}');
          print('   Cover Charge: ${event.coverCharge}');
          print('   Image URL: ${event.imageUrl}');
          print('   Tags: ${event.tags}');
          print('   Age Restriction: ${event.ageRestriction}');
          print('   Host: ${event.hostName}');
          print('   Max Capacity: ${event.maxCapacity}');
          print('   Current Bookings: ${event.currentBookings}');
          print('   Passes: ${event.passes?.length ?? 0} pass types');
          
          if (event.passes != null) {
            for (final pass in event.passes!) {
              print('     - ${pass.type}: ₹${pass.price}');
            }
          }
          
        } catch (eventError, stackTrace) {
          print('❌ Error parsing event ${i + 1}: $eventError');
          print('📍 Stack trace: $stackTrace');
          print('📄 Event JSON: ${eventsJson[i]}');
        }
      }
    } else {
      print('❌ Invalid API response structure');
    }
    
  } catch (e, stackTrace) {
    print('❌ Error parsing API response: $e');
    print('📍 Stack trace: $stackTrace');
  }
  
  print('\\n🎉 Event parsing test completed!');
}