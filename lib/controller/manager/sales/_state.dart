part of '_bloc.dart';

@immutable
abstract final class SalesState {}

final class Loading extends SalesState {}

final class Loaded extends SalesState {
  final List<Sale> sales;
  final List<IndividualBar> individualBars;
  final double maxYAxis;

  Loaded({
    required this.sales,
    required this.individualBars,
    required this.maxYAxis,
  });
}

final class Error extends SalesState {}
