import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../models/ticket_model.dart';
import '../../services/ticket_service.dart';
import 'attendee_details_screen.dart';

class TicketSelectionScreen extends StatefulWidget {
  final Event event;

  const TicketSelectionScreen({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  State<TicketSelectionScreen> createState() => _TicketSelectionScreenState();
}

class _TicketSelectionScreenState extends State<TicketSelectionScreen> {
  final List<TicketSelection> _ticketSelections = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeTickets();
  }

  void _initializeTickets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<TicketType> ticketTypes;
      
      // Try to fetch fresh passes data from API
      final apiTickets = await TicketService.fetchEventPasses(widget.event.id);
      
      if (apiTickets.isNotEmpty) {
        // Update the description for API tickets with event's whatsIncludedInTicket
        ticketTypes = apiTickets.map((ticket) {
          return TicketType(
            id: ticket.id,
            name: ticket.name,
            price: ticket.price,
            description: widget.event.whatsIncludedInTicket ?? ticket.description,
            includes: [widget.event.whatsIncludedInTicket ?? ticket.description],
            totalQuantity: ticket.totalQuantity,
            remainingQuantity: ticket.remainingQuantity,
          );
        }).toList();
      } else if (widget.event.passes != null && widget.event.passes!.isNotEmpty) {
        // Use passes from event data
        ticketTypes = widget.event.passes!.map((pass) {
          return TicketType.fromPass(pass, widget.event.whatsIncludedInTicket);
        }).toList();
      } else {
        // Fallback to default ticket types
        ticketTypes = TicketType.getTicketTypes();
      }
      
      for (var ticketType in ticketTypes) {
        _ticketSelections.add(TicketSelection(ticketType: ticketType));
      }
    } catch (e) {
      print('Error initializing tickets: $e');
      // Use event passes or fallback
      List<TicketType> ticketTypes;
      
      if (widget.event.passes != null && widget.event.passes!.isNotEmpty) {
        ticketTypes = widget.event.passes!.map((pass) {
          return TicketType.fromPass(pass, widget.event.whatsIncludedInTicket);
        }).toList();
      } else {
        // Update default tickets with event's whatsIncludedInTicket
        ticketTypes = TicketType.getTicketTypes().map((ticket) {
          return TicketType(
            id: ticket.id,
            name: ticket.name,
            price: ticket.price,
            description: widget.event.whatsIncludedInTicket ?? ticket.description,
            includes: [widget.event.whatsIncludedInTicket ?? ticket.description],
            totalQuantity: ticket.totalQuantity,
            remainingQuantity: ticket.remainingQuantity,
          );
        }).toList();
      }
      
      for (var ticketType in ticketTypes) {
        _ticketSelections.add(TicketSelection(ticketType: ticketType));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int get _totalTickets {
    return _ticketSelections.fold(0, (sum, selection) => sum + selection.quantity);
  }

  double get _totalPrice {
    return _ticketSelections.fold(0.0, (sum, selection) => sum + selection.totalPrice);
  }

  void _incrementTicket(int index) {
    final selection = _ticketSelections[index];
    final remainingQuantity = selection.ticketType.remainingQuantity;
    
    // Check if we can add more tickets
    if (remainingQuantity == null || selection.quantity < remainingQuantity) {
      setState(() {
        _ticketSelections[index].quantity++;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Only $remainingQuantity tickets available for ${selection.ticketType.name}'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _decrementTicket(int index) {
    if (_ticketSelections[index].quantity > 0) {
      setState(() {
        _ticketSelections[index].quantity--;
      });
    }
  }

  void _proceedToDetails() {
    if (_totalTickets == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one ticket'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Filter only selected tickets
    final selectedTickets = _ticketSelections
        .where((selection) => selection.quantity > 0)
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendeeDetailsScreen(
          event: widget.event,
          ticketSelections: selectedTickets,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Tickets',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6958CA),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ticket Packages',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ..._ticketSelections.asMap().entries.map((entry) {
                          final index = entry.key;
                          final selection = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildTicketCard(selection, index),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                if (_totalTickets > 0) _buildBottomBar(),
              ],
            ),
    );
  }

  Widget _buildTicketCard(TicketSelection selection, int index) {
    final isAvailable = selection.ticketType.remainingQuantity == null || 
                       selection.ticketType.remainingQuantity! > 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selection.quantity > 0
              ? const Color(0xFF8B5CF6)
              : const Color(0xFF2A2A2A),
          width: selection.quantity > 0 ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selection.ticketType.name,
                      style: TextStyle(
                        color: isAvailable ? Colors.white : Colors.grey,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (selection.ticketType.remainingQuantity != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${selection.ticketType.remainingQuantity} left',
                        style: TextStyle(
                          color: selection.ticketType.remainingQuantity! > 10 
                              ? Colors.green 
                              : Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '₹${selection.ticketType.price.toInt()}',
                style: TextStyle(
                  color: isAvailable ? const Color(0xFFFFA726) : Colors.grey,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...selection.ticketType.includes.map((include) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '• ',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 16,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      include,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
          Row(
            children: [
              if (selection.quantity == 0)
                Expanded(
                  child: Container(
                    height: 56.0,
                    decoration: BoxDecoration(
                      gradient: isAvailable 
                          ? const LinearGradient(
                              colors: [Color(0xFFFF4081), Color(0xFFE91E63)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [Colors.grey.shade600, Colors.grey.shade700],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(28.0),
                    ),
                    child: ElevatedButton(
                      onPressed: isAvailable ? () => _incrementTicket(index) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28.0),
                        ),
                      ),
                      child: Text(
                        isAvailable ? 'Book Now!' : 'Sold Out',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => _decrementTicket(index),
                          icon: const Icon(Icons.remove, color: Colors.white),
                        ),
                        Text(
                          '${selection.quantity}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          onPressed: isAvailable ? () => _incrementTicket(index) : null,
                          icon: Icon(Icons.add, color: isAvailable ? Colors.white : Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(color: Color(0xFF2A2A2A)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_totalTickets Ticket${_totalTickets > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${_totalPrice.toInt()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 56.0,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF4081), Color(0xFFE91E63)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28.0),
                ),
                child: ElevatedButton(
                  onPressed: _proceedToDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.0),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
