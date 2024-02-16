part of '_cubit.dart';

@immutable
abstract class ClientDetailState {}

class Loading extends ClientDetailState {}

class Loaded extends ClientDetailState {
  final String clientUid;
  final Location location;
  final List<Widget> tabs;
  final TabController tabController;
  final MonthReport monthReport;

  Loaded({
    required this.clientUid,
    required this.location,
    required this.tabs,
    required this.tabController,
    required this.monthReport,
  });
}

class Error extends ClientDetailState {}
