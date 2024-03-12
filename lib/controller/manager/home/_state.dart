part of '_bloc.dart';

@immutable
abstract class HomeState {}

final class Loading extends HomeState {}

final class Loaded extends HomeState {
  final List listOfAds;
  final Animation<double> rotationTween;
  final Animation<double> opacityTween;
  final Animation<double> heightTween;
  final Animation<double> addsHeightTween;
  final Animation<double> widthTween;
  final Animation<double> borderRadiusTween;
  final Animation<double> boxShadowTween;
  final User user;
  final GlobalKey<FormState> nameFormKey;
  final TextEditingController nameController;
  final GlobalKey<FormState> emailFormKey;
  final TextEditingController emailController;
  final GlobalKey<FormState> contactFormKey;
  final TextEditingController contactController;

  Loaded(
      {required this.listOfAds,
      required this.rotationTween,
      required this.opacityTween,
      required this.heightTween,
      required this.addsHeightTween,
      required this.widthTween,
      required this.borderRadiusTween,
      required this.boxShadowTween,
      required this.user,
      required this.nameFormKey,
      required this.nameController,
      required this.emailFormKey,
      required this.emailController,
      required this.contactFormKey,
      required this.contactController});
}
