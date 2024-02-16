import 'package:flutter/material.dart';

import '../constants.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    this.title,
    this.primaryColor = false,
    this.backgroundColor,
    this.child,
    this.titleColor,
  });

  final void Function() onPressed;
  final String? title;
  final bool primaryColor;
  final Color? backgroundColor;
  final Widget? child;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(
          primaryColor == true ? Theme.of(context).primaryColor.withOpacity(0.5) : backgroundColor ?? Colors.white,
        ),
        elevation: const MaterialStatePropertyAll(4),
        padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: mediumPadding)),
      ),
      child: child ??
          Text(
            title ?? '',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: primaryColor == true ? Colors.white : titleColor,
                ),
          ),
    );
  }
}
