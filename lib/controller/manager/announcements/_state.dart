part of '_bloc.dart';

@immutable
abstract final class AnnouncementsState {}

final class Loading extends AnnouncementsState {}

final class Loaded extends AnnouncementsState {
  final double cardSize;
  final List<Announcement> announcements;

  Loaded({
    required this.cardSize,
    required this.announcements,
  });
}

final class Error extends AnnouncementsState {}
