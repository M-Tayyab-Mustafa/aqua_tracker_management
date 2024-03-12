import 'package:flutter/material.dart';
import '../constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.surfaceTintColor,
    this.backgroundColor,
    this.centerTitle,
    this.titleColor,
  });
  final String title;
  final List<Widget>? actions;
  final Color? surfaceTintColor;
  final Color? backgroundColor;
  final bool? centerTitle;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontFamily: customFontFamily,
              fontWeight: FontWeight.bold,
              color: titleColor ?? Theme.of(context).primaryColor)),
      centerTitle: centerTitle,
      actions: actions,
      backgroundColor: backgroundColor,
      surfaceTintColor: surfaceTintColor,
    );
  }

  @override
  Size get preferredSize => const Size(double.infinity, kToolbarHeight);
}
