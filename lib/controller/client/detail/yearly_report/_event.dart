part of '_bloc.dart';

@immutable
abstract class YearlyReportWidgetEvent {}


final class SeeMoreTab extends YearlyReportWidgetEvent {
  final YearlyReport payment;

  SeeMoreTab({required this.payment});
}
final class PaymentVerificationStatus extends YearlyReportWidgetEvent {
  final int? status;
  final YearlyReport report;

  PaymentVerificationStatus({required this.status,required this.report});
}
