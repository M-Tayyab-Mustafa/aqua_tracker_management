part of '_bloc.dart';

@immutable
abstract final class HomeState {}

final class Loading extends HomeState {}

final class Error extends HomeState {}

final class Loaded extends HomeState {
  final List listOfAds;
  final User user;
  final Animation<double> heightTween;
  final Animation<double> widthTween;
  final Animation<double> rotationTween;
  final Animation<double> opacityTween;
  final Animation<double> borderRadiusTween;
  final Animation<double> boxShadowTween;
  final double addSize;
  final GlobalKey<FormState> nameFormKey;
  final TextEditingController nameController;
  final GlobalKey<FormState> emailFormKey;
  final TextEditingController emailController;
  final GlobalKey<FormState> contactFormKey;
  final TextEditingController contactController;

  Loaded({
    required this.listOfAds,
    required this.user,
    required this.heightTween,
    required this.widthTween,
    required this.rotationTween,
    required this.opacityTween,
    required this.borderRadiusTween,
    required this.boxShadowTween,
    required this.addSize,
    required this.nameFormKey,
    required this.nameController,
    required this.emailFormKey,
    required this.emailController,
    required this.contactFormKey,
    required this.contactController,
  });
}
