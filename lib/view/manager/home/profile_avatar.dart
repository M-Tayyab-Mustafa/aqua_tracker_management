import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../controller/manager/home/_bloc.dart';
import '../../../utils/constants.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.radius});
  final double radius;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        switch (state.runtimeType) {
          case const (Loaded):
            (state as Loaded);
            return Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(largeBorderRadius),
              child: CircleAvatar(
                radius: radius,
                backgroundColor: buttonColors,
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width: radius * 2,
                        height: radius * 2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(radius * 3),
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                    ),
                    Center(
                      child: FittedBox(
                        child: Text(
                          state.user.name.characters.first,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          default:
            return Container();
        }
      },
    );
  }
}
