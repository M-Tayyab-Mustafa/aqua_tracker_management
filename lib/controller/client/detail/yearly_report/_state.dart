part of '_bloc.dart';

@immutable
abstract class YearReportWidgetState {}

final class Loading extends YearReportWidgetState {}

final class Loaded extends YearReportWidgetState {
  final List<YearReport> yearlyPayments;
  final ScrollController verticalController;
  final ScrollController horizontalController;

  Loaded({required this.yearlyPayments, required this.verticalController, required this.horizontalController});
}
