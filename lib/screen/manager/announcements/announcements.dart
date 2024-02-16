import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../controller/manager/announcements/_bloc.dart';
import '../../../utils/constants.dart';
import '../../../utils/widget/appbar.dart';
import '../../../utils/widget/card.dart';
import '../../basic/empty.dart';
import '../../basic/error.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  static const String name = 'Announcements Screen';
  static const String path = 'announcements_screen';

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Announcements'),
      body: BlocBuilder<AnnouncementsBloc, AnnouncementsState>(
        builder: (context, state) {
          switch (state.runtimeType) {
            case const (Loading):
              return const Material(child: Center(child: CircularProgressIndicator()));
            case const (Loaded):
              (state as Loaded);
              return Stack(
                children: [
                  state.announcements.isEmpty
                      ? const Empty(title: 'Currently No Announcement Available')
                      : SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: state.announcements
                                .map(
                                  (announcement) => Padding(
                                    padding: EdgeInsets.all(smallestPadding),
                                    child: Hero(
                                      tag: announcement.date,
                                      child: CustomCard(
                                        onTapDown: (details) => BlocProvider.of<AnnouncementsBloc>(context)
                                            .add(CardTab(context: context, announcement: announcement)),
                                        height: state.cardSize,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: smallestPadding),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(top: smallestPadding),
                                                child: const Align(
                                                  alignment: Alignment.topLeft,
                                                  child: CircleAvatar(
                                                    radius: 22,
                                                    backgroundColor: Colors.white,
                                                    child: FittedBox(
                                                      fit: BoxFit.fill,
                                                      child: Icon(
                                                        Icons.notifications_active_outlined,
                                                        size: 25,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    left: smallestPadding,
                                                    top: smallestPadding,
                                                    bottom: smallestPadding,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              announcement.title.toUpperCase(),
                                                              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                                                  fontWeight: FontWeight.bold, color: Colors.white),
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: EdgeInsets.only(left: smallestPadding),
                                                            child: Text(
                                                              DateFormat.yMd().format(
                                                                  DateTime.fromMillisecondsSinceEpoch(
                                                                      announcement.date)),
                                                              style: Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge!
                                                                  .copyWith(color: Colors.white),
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.only(top: smallestPadding),
                                                        child: Text(
                                                          announcement.detail,
                                                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                              fontWeight: FontWeight.w500, color: Colors.white),
                                                          maxLines: 3,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                  Padding(
                    padding: EdgeInsets.only(right: smallPadding, bottom: smallPadding),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton(
                        tooltip: 'Add Sales',
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
                        child: Icon(Icons.add, size: buttonSize, color: Colors.white),
                        onPressed: () => BlocProvider.of<AnnouncementsBloc>(context).add(BroadCast(context: context)),
                      ),
                    ),
                  )
                ],
              );
            default:
              return const ErrorScreen();
          }
        },
      ),
    );
  }
}
