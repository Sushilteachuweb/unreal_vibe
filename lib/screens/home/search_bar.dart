import 'package:flutter/material.dart';
import '../../services/search_service.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function()? onTap;
  final Function(String)? onSearch;
  final bool readOnly;
  final String? userCity;
  final bool showSuggestions;

  const CustomSearchBar({
    Key? key,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onSearch,
    this.readOnly = false,
    this.userCity,
    this.showSuggestions = false,
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  bool _showSuggestions = false;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    
    // Load suggestions if city is provided
    if (widget.userCity != null) {
      _suggestions = SearchService.getSearchSuggestions(widget.userCity!);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged(String value) {
    setState(() {
      _showSuggestions = widget.showSuggestions && 
                        value.isNotEmpty && 
                        value.length >= 2 &&
                        _suggestions.isNotEmpty;
    });
    widget.onChanged?.call(value);
  }

  void _selectSuggestion(String suggestion) {
    _controller.text = suggestion;
    setState(() {
      _showSuggestions = false;
    });
    widget.onSearch?.call(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(100),
          ),
          child: TextField(
            controller: _controller,
            readOnly: widget.readOnly,
            onChanged: _onTextChanged,
            onTap: widget.onTap,
            onSubmitted: (value) {
              setState(() {
                _showSuggestions = false;
              });
              widget.onSearch?.call(value);
            },
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: widget.userCity != null 
                  ? 'Search events in ${widget.userCity}...'
                  : 'Search events...',
              hintStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey[600],
                size: 20,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.onSearch != null && _controller.text.isNotEmpty) ...[
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _showSuggestions = false;
                        });
                        widget.onSearch?.call(_controller.text);
                      },
                    ),
                  ],
                  if (_controller.text.isNotEmpty) ...[
                    IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      onPressed: () {
                        _controller.clear();
                        setState(() {
                          _showSuggestions = false;
                        });
                        widget.onChanged?.call('');
                      },
                    ),
                  ],
                ],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        
        // Search Suggestions
        if (_showSuggestions && _suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[800]!, width: 1),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.grey[500],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Popular searches in ${widget.userCity}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                ...List.generate(
                  _suggestions.take(5).length, // Show max 5 suggestions
                  (index) {
                    final suggestion = _suggestions[index];
                    return InkWell(
                      onTap: () => _selectSuggestion(suggestion),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: index < 4 && index < _suggestions.length - 1
                              ? Border(
                                  bottom: BorderSide(
                                    color: Colors.grey[800]!,
                                    width: 0.5,
                                  ),
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.grey[600],
                              size: 16,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                suggestion,
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.north_west,
                              color: Colors.grey[600],
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
