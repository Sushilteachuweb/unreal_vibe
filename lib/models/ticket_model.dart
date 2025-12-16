class TicketType {
  final String id;
  final String name;
  final double price;
  final String description;
  final List<String> includes;
  final int? totalQuantity;
  final int? remainingQuantity;

  TicketType({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.includes,
    this.totalQuantity,
    this.remainingQuantity,
  });

  // Create TicketType from API TicketPass
  factory TicketType.fromPass(dynamic pass, String? whatsIncluded) {
    // Handle both object and map formats
    String passId = '';
    String passType = '';
    double passPrice = 0.0;
    int? totalQty;
    int? remainingQty;
    
    if (pass is Map<String, dynamic>) {
      passId = pass['id'] ?? pass['_id'] ?? '';
      passType = pass['type'] ?? '';
      passPrice = (pass['price'] ?? 0).toDouble();
      totalQty = pass['totalQuantity'];
      remainingQty = pass['remainingQuantity'];
    } else {
      // Handle object format
      passId = pass.id ?? pass._id ?? '';
      passType = pass.type ?? '';
      passPrice = (pass.price ?? 0).toDouble();
      totalQty = pass.totalQuantity;
      remainingQty = pass.remainingQuantity;
    }
    
    return TicketType(
      id: passId,
      name: passType.isNotEmpty 
          ? passType[0].toUpperCase() + passType.substring(1).toLowerCase()
          : passType,
      price: passPrice,
      description: whatsIncluded ?? 'Entry Ticket',
      includes: [whatsIncluded ?? 'Entry Ticket'],
      totalQuantity: totalQty,
      remainingQuantity: remainingQty,
    );
  }

  static List<TicketType> getTicketTypes() {
    return [
      TicketType(
        id: 'male',
        name: 'MALE PASS',
        price: 2999,
        description: 'UNLIMITED ALCOHOL JUNGLE JUICE + 1 TIME FOOD',
        includes: [
          'UNLIMITED ALCOHOL JUNGLE JUICE + 1 TIME FOOD',
        ],
      ),
      TicketType(
        id: 'couple',
        name: 'COUPLE PASS',
        price: 2499,
        description: 'UNLIMTED JUNGLE ALCOHOL +1 TIME FOOD',
        includes: [
          'UNLIMITED JUNGLE JUICE ALCOHOL MIXED +1 TIME FOOD',
        ],
      ),
      TicketType(
        id: 'female',
        name: 'FEMALE PASS',
        price: 999,
        description: 'UNLIMITED JUNGLE JUICE ALCOHOL MIXED + 1 TIME FOOD',
        includes: [
          'UNLIMITED JUNGLE JUICE ALCOHOL MIXED + 1 TIME FOOD',
        ],
      ),
    ];
  }

  // Create ticket types from event passes
  static List<TicketType> fromEventPasses(List<dynamic>? passes, String? whatsIncluded) {
    if (passes == null || passes.isEmpty) {
      return getTicketTypes(); // Fallback to default
    }
    
    return passes.map((pass) => TicketType.fromPass(pass, whatsIncluded)).toList();
  }
}

class TicketSelection {
  final TicketType ticketType;
  int quantity;

  TicketSelection({
    required this.ticketType,
    this.quantity = 0,
  });

  double get totalPrice => ticketType.price * quantity;
}
