import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final Function()? onTap;
  final Function(String)? onSearch;
  final bool readOnly;

  const CustomSearchBar({
    Key? key,
    this.controller,
    this.onChanged,
    this.onTap,
    this.onSearch,
    this.readOnly = false,
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(100),
      ),
      child: TextField(
        controller: _controller,
        readOnly: widget.readOnly,
        onChanged: widget.onChanged,
        onTap: widget.onTap,
        onSubmitted: widget.onSearch,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'Search events...',
          hintStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[600],
            size: 20,
          ),
          suffixIcon: widget.onSearch != null && _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  onPressed: () => widget.onSearch?.call(_controller.text),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
