part of '_cubit.dart';

@immutable
abstract class ClientDetailScreenState {}

class Loading extends ClientDetailScreenState {}

class Loaded extends ClientDetailScreenState {
  final List<Widget> tabs;
  final TabController tabController;
  final MonthReport monthReport;

  Loaded({required this.tabs, required this.tabController, required this.monthReport});
}
