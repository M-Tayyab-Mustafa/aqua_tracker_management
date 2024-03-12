import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';

class SplashedScreen extends StatelessWidget {
  const SplashedScreen({super.key});

  static const String screenName = 'splash-screen';

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.sizeOf(context);
    buttonColors = Theme.of(context).primaryColor.withOpacity(0.5);
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: const Alignment(0, -0.3),
            child: SizedBox(
              height: screenSize.height * 0.35,
              child:
                  Image.asset('assets/images/app_icon.png', fit: BoxFit.fill),
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  child: Text(
                    'Aqua Tracker',
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          fontFamily: customFontFamily,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(smallPadding),
              child: FittedBox(
                child: Text(
                  'Powered By CAS Since 2010',
                  style: GoogleFonts.keaniaOne(
                    fontSize: Theme.of(context).textTheme.bodySmall!.fontSize,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
