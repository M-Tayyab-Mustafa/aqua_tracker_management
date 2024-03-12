part of '_bloc.dart';

@immutable
abstract final class AnnouncementsEvent {}

final class BroadCast extends AnnouncementsEvent {
  final BuildContext context;

  BroadCast({required this.context});
}

final class CardTab extends AnnouncementsEvent {
  final BuildContext context;
  final Announcement announcement;

  CardTab({required this.context, required this.announcement});
}
