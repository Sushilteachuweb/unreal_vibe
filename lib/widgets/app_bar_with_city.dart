import 'package:flutter/material.dart';
import 'city_dropdown_widget.dart';

class AppBarWithCity extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final double elevation;

  const AppBarWithCity({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = false,
    this.backgroundColor,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.black,
      elevation: elevation,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const CityDropdownWidget(),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}