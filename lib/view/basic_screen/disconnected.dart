import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class DisconnectedScreen extends StatelessWidget {
  const DisconnectedScreen({super.key});
  static const String screenName = '/no_internet_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: screenSize.height * 0.6,
            child: Image.asset('assets/images/no_connection.png',
                fit: BoxFit.fill),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: screenSize.height * 0.4,
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: Center(
                      child: Text('Oops!',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(color: Colors.black87),
                          textAlign: TextAlign.center),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(smallPadding),
                      child: Text(
                        'No internet connection check the network modem, and router.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: Colors.grey.withOpacity(0.8)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
