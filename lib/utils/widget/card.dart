import 'package:flutter/material.dart';
import '../constants.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
    this.onTap,
    required this.child,
    this.backgroundColor,
    this.onTapDown,
  });

  final double? height;
  final double? width;
  final Widget child;
  final GestureTapCallback? onTap;
  final GestureTapDownCallback? onTapDown;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onTapDown,
      onTap: onTap,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          gradient: backgroundColor != null
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.lightBlue.withOpacity(0.2),
                    Colors.deepPurple.shade600,
                  ],
                ),
          boxShadow: [
            BoxShadow(
              blurRadius: 1,
              spreadRadius: 1,
              color: Colors.black.withOpacity(0.4),
              offset: const Offset(2, 2),
            ),
            BoxShadow(
              blurRadius: 1,
              spreadRadius: 1,
              color: Colors.white.withOpacity(0.4),
              offset: const Offset(-2, -2),
            ),
          ],
          borderRadius: borderRadius ?? BorderRadius.circular(smallBorderRadius),
        ),
        child: Padding(
          padding: EdgeInsets.all(smallestPadding),
          child: child,
        ),
      ),
    );
  }
}

class CustomDragAbleCard extends StatelessWidget {
  const CustomDragAbleCard(
      {required super.key,
      this.isDismissible = true,
      this.dismissDirection = DismissDirection.endToStart,
      this.height,
      this.width,
      this.onTap,
      this.confirmDismiss,
      required this.child,
      this.borderRadius,
      this.margin,
      this.backgroundColor,
      this.padding});

  final bool isDismissible;
  final double? height;
  final double? width;
  final Widget child;
  final GestureTapCallback? onTap;
  final ConfirmDismissCallback? confirmDismiss;
  final DismissDirection dismissDirection;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.all(smallestPadding),
      child: Dismissible(
        key: key!,
        direction: isDismissible ? dismissDirection : DismissDirection.none,
        confirmDismiss: confirmDismiss,
        background: Align(
          alignment: Alignment.centerLeft,
          child: Icon(Icons.edit_note_rounded, color: Colors.greenAccent, size: buttonSize),
        ),
        secondaryBackground: Align(
          alignment: Alignment.centerRight,
          child: Icon(Icons.delete, color: Colors.red, size: buttonSize),
        ),
        child: CustomCard(
          backgroundColor: backgroundColor,
          height: height,
          width: width,
          borderRadius: borderRadius,
          onTap: onTap,
          child: Padding(
            padding: padding ?? EdgeInsets.all(smallestPadding),
            child: child,
          ),
        ),
      ),
    );
  }
}
