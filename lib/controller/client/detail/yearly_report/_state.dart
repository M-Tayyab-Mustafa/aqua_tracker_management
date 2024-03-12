part of '_bloc.dart';

@immutable
abstract class YearlyReportWidgetState {}

final class Loading extends YearlyReportWidgetState {}

final class Loaded extends YearlyReportWidgetState {
  final List<YearlyReport> yearlyPayments;
  final ScrollController verticalController;
  final ScrollController horizontalController;

  Loaded({required this.yearlyPayments, required this.verticalController, required this.horizontalController});
}
