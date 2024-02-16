part of '_bloc.dart';

@immutable
abstract final class HomeEvent {}

final class SignOut extends HomeEvent {
  final BuildContext context;

  SignOut({required this.context});
}

final class ChangeName extends HomeEvent {
  final BuildContext context;

  ChangeName({required this.context});
}

final class ChangeEmail extends HomeEvent {
  final BuildContext context;

  ChangeEmail({required this.context});
}

final class ChangeContact extends HomeEvent {
  final BuildContext context;

  ChangeContact({required this.context});
}

final class AboutUs extends HomeEvent {
  final BuildContext context;

  AboutUs({required this.context});
}

final class ProfileImagePreview extends HomeEvent {
  final BuildContext context;
  final String imageUrl;

  ProfileImagePreview({required this.context, required this.imageUrl});
}

final class Client extends HomeEvent {}

final class DeliveryManLocation extends HomeEvent {}

final class DeliveryMan extends HomeEvent {}

final class Expenses extends HomeEvent {}

final class Sales extends HomeEvent {}

final class Announcements extends HomeEvent {}

final class BackButtonTap extends HomeEvent {}
