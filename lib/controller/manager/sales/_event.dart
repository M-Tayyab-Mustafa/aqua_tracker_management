part of '_bloc.dart';

@immutable
abstract class SalesEvent {}

final class Add extends SalesEvent {
  final BuildContext context;

  Add({required this.context});
}
