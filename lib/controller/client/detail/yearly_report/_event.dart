part of '_bloc.dart';

@immutable
abstract final class YearReportWidgetEvent {}

final class SeeMoreTab extends YearReportWidgetEvent {
  final BuildContext context;
  final YearReport payment;

  SeeMoreTab({required this.context, required this.payment});
}

final class PaymentStatus extends YearReportWidgetEvent {
  final int? status;
  final YearReport yearReport;

  PaymentStatus({required this.status, required this.yearReport});
}
