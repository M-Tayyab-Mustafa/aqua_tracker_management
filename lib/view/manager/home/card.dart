import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../../utils/widgets/card.dart';

class HomeScreenCard extends StatelessWidget {
  const HomeScreenCard(
      {super.key,
      this.image,
      this.icon = Icons.add,
      required this.title,
      required this.onTab});
  final String? image;
  final IconData icon;
  final String title;
  final GestureTapCallback onTab;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CustomCard(
                width: constraints.maxWidth * 0.7,
                onTap: onTab,
                child: Padding(
                  padding: const EdgeInsets.all(smallPadding),
                  child: Center(
                    child: image != null
                        ? Image.asset(
                            image!,
                            color: Colors.white,
                            fit: BoxFit.fill,
                          )
                        : FittedBox(
                            child: Icon(
                              icon,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          flex: 5,
          child: Center(
              child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          )),
        ),
      ],
    );
  }
}
