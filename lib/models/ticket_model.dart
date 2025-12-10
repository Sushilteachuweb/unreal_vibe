class TicketType {
  final String id;
  final String name;
  final double price;
  final String description;
  final List<String> includes;

  TicketType({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.includes,
  });

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
