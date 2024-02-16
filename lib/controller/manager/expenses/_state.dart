part of '_bloc.dart';

@immutable
abstract class ExpensesState {}

final class Loading extends ExpensesState {}

final class Loaded extends ExpensesState {
  final GlobalKey<FormState> formKey;
  final ScrollController verticalScrollbarController;
  final ScrollController horizontalScrollbarController;
  final List<Expense> expenses;
  final List<IndividualBar> individualBars;
  final double maxYAxis;

  Loaded(
      {required this.formKey,
      required this.verticalScrollbarController,
      required this.horizontalScrollbarController,
      required this.expenses,
      required this.individualBars,
      required this.maxYAxis});
}

final class Error extends ExpensesState {}
