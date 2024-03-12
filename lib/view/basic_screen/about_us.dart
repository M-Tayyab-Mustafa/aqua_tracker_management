import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../../utils/widgets/appbar.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  static const String screenName = '/about_us_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'About Us'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: smallPadding),
        child: ListView(
          children: [
            Text.rich(TextSpan(children: [
              TextSpan(
                  text: '\nWelcome to',
                  style: Theme.of(context).textTheme.bodyLarge),
              TextSpan(
                  text: '(CAS)',
                  style: Theme.of(context).textTheme.titleMedium),
              TextSpan(
                text:
                    ', where our vision is to nurture and produce excellent developers while crafting outstanding mobile applications. Founded and led by',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              TextSpan(
                  text: '(Tayyab)',
                  style: Theme.of(context).textTheme.titleMedium),
              TextSpan(
                  text:
                      ', our company is committed to fostering talent and delivering exceptional app development solutions.',
                  style: Theme.of(context).textTheme.bodyLarge),
            ])),
            Text.rich(TextSpan(children: [
              TextSpan(
                  text: '\nOur Vision\n',
                  style: Theme.of(context).textTheme.headlineSmall),
              TextSpan(
                  text: 'At CAS, our vision is twofold:\n',
                  style: Theme.of(context).textTheme.bodyLarge),
              TextSpan(
                  text: 'Develop Excellent Developers:\n',
                  style: Theme.of(context).textTheme.titleMedium),
              TextSpan(
                  text:
                      'We aspire to be a driving force behind the development of excellent developers. We believe in the power of education, mentorship, and continuous learning to shape individuals into skilled and innovative app developers.',
                  style: Theme.of(context).textTheme.bodyLarge),
              TextSpan(
                  text: '\nDevelop Excellent Apps:\n',
                  style: Theme.of(context).textTheme.titleMedium),
              TextSpan(
                  text:
                      'Simultaneously, we are dedicated to crafting outstanding mobile applications. We understand that excellent developers are at the heart of excellent apps, and our commitment to producing top-tier developers enhances our ability to create exceptional app solutions.',
                  style: Theme.of(context).textTheme.bodyLarge),
            ])),
            Text.rich(TextSpan(children: [
              TextSpan(
                  text: '\nOur Mission\n',
                  style: Theme.of(context).textTheme.headlineSmall),
              TextSpan(
                  text: 'Our mission at CAS is a dual one:\n',
                  style: Theme.of(context).textTheme.bodyLarge),
              TextSpan(
                  text: 'Foster Developer Excellence:\n',
                  style: Theme.of(context).textTheme.titleMedium),
              TextSpan(
                  text:
                      'We are on a mission to provide a conducive learning environment, mentorship, and resources to individuals passionate about app development. By doing so, we aim to produce a new generation of skilled and creative developers.',
                  style: Theme.of(context).textTheme.bodyLarge),
              TextSpan(
                  text: '\nDeliver Excellent App Solutions:\n',
                  style: Theme.of(context).textTheme.titleMedium),
              TextSpan(
                  text:
                      'In parallel, we are committed to delivering top-notch mobile applications. With our team of proficient developers, we focus on creating apps that stand out in terms of innovation, user experience, and functionality.',
                  style: Theme.of(context).textTheme.bodyLarge),
            ])),
            Text(
                '\nThank you for considering CAS as your partner in app development and developer education. We look forward to the opportunity to work with you and help you achieve excellence in both your app projects and the growth of new developers.\n',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
