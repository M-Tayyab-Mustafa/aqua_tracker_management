part of '_bloc.dart';

@immutable
abstract final class ExpensesEvent {}

final class Add extends ExpensesEvent {
  final BuildContext context;

  Add({required this.context});
}
