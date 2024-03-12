import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../controller/delivery_man/home/_bloc.dart';
import '../../basic/error.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String name = 'Deliveryman Home';
  static const String path = '/deliveryman_home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          switch (state.runtimeType) {
            case const (Loading):
              return const Center(child: CircularProgressIndicator.adaptive());
            case const (Loaded):
              return Container();
            default:
              return const ErrorScreen();
          }
        },
      ),
    );
  }
}
