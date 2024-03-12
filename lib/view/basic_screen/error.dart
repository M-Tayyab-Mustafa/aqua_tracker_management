import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Align(
              alignment: const Alignment(0, -0.3),
              child: SizedBox(
                height: screenSize.height * 0.45,
                child: Image.asset(
                  'assets/images/error.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.5),
              child: FittedBox(
                child: Text(
                  'Oops!',
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium!
                      .copyWith(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.7),
              child: FittedBox(
                child: Text(
                  'Something went wrong! Try again later.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(color: Colors.grey.withOpacity(0.9)),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
