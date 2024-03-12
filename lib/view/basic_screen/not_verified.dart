import 'package:aqua_tracker_managements/utils/widgets/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../utils/constants.dart';

class NotVerifiedScreen extends StatelessWidget {
  const NotVerifiedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: smallPadding),
        child: Stack(
          children: [
            Align(
              alignment: const Alignment(0, -0.55),
              child: Lottie.asset(
                'assets/gif_json/email_not_verify.json',
                fit: BoxFit.fill,
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(mediumPadding),
                    child: Text(
                      'Please verify you\'r email.',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  CustomButton(
                    title: 'Resend Verification Email',
                    onPressed: () async {
                      await FirebaseAuth.instance.currentUser!
                          .sendEmailVerification();
                    },
                    primaryColor: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
