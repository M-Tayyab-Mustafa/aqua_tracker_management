part of '_bloc.dart';

@immutable
abstract final class HomeState {}

final class Loading extends HomeState {}

final class Loaded extends HomeState {}
