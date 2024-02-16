import '../../utils/constants.dart';
import 'package:flutter/material.dart';

class Empty extends StatelessWidget {
  const Empty({super.key, required this.title, this.titleColor});
  final Color? titleColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: smallPadding),
      child: Stack(
        children: [
          Center(
              child: Image.asset(
            'assets/app_icon.png',
            opacity: const AlwaysStoppedAnimation(0.4),
          )),
          Center(
            child: Text(
              textAlign: TextAlign.center,
              maxLines: 2,
              title,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold, color: titleColor ?? Colors.black, fontFamily: customFontFamily),
            ),
          ),
        ],
      ),
    );
  }
}
