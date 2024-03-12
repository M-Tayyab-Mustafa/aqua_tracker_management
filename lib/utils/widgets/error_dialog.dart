import 'package:flutter/material.dart';

import '../constants.dart';
import 'button.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      content: SizedBox(
        height: screenSize.height * 0.3,
        child: Stack(
          children: [
            Align(
              alignment: const Alignment(0, -0.3),
              child: SizedBox(
                height: (screenSize.height * 0.3) * 0.6,
                child: Image.asset(
                  'assets/images/error.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.6),
              child: FittedBox(
                child: Text(
                  'Oops!',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.8),
              child: FittedBox(
                child: Text(
                  'Something went wrong! Try again later.',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.grey.withOpacity(0.9),
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        CustomButton(
          onPressed: () => Navigator.pop(context),
          title: 'Cancel',
          backgroundColor: Colors.red,
          titleColor: Colors.white,
        ),
      ],
    );
  }
}
