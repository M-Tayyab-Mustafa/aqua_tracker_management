part of '_bloc.dart';

@immutable
abstract class HomeEvent {}

final class SignOut extends HomeEvent {}

final class ChangeName extends HomeEvent {
  final BuildContext dialogContext;

  ChangeName({required this.dialogContext});
}

final class ChangeEmail extends HomeEvent {
  final BuildContext dialogContext;

  ChangeEmail({required this.dialogContext});
}

final class ChangeContact extends HomeEvent {
  final BuildContext dialogContext;

  ChangeContact({required this.dialogContext});
}

final class AboutUs extends HomeEvent {}

final class Client extends HomeEvent {}

final class DeliveryManLocation extends HomeEvent {}

final class DeliveryMan extends HomeEvent {}

final class Expenses extends HomeEvent {}

final class Sales extends HomeEvent {}

final class Announcements extends HomeEvent {}

final class BackButtonTap extends HomeEvent {}
