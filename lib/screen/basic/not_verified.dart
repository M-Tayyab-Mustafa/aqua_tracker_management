import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../utils/constants.dart';
import '../../utils/widget/appbar.dart';
import '../../utils/widget/button.dart';

class NotVerifiedScreen extends StatelessWidget {
  const NotVerifiedScreen({super.key});

  static const String name = 'Email Not Verified Screen';
  static const String path = 'email_not_verified_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: ''),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: smallPadding),
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
                    padding: EdgeInsets.all(mediumPadding),
                    child: Text(
                      'Please verify you\'r email.',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  CustomButton(
                    title: 'Resend Verification Email',
                    onPressed: () async => await FirebaseAuth.instance.currentUser!.sendEmailVerification(),
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
