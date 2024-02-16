import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../model/announcement.dart';
import '../../../utils/constants.dart';

class PreviewAnnouncementScreen extends StatelessWidget {
  const PreviewAnnouncementScreen({super.key, required this.announcement});
  final Announcement announcement;

  static const String name = 'Manager Preview Announcements Screen';
  static const String path = 'manager_preview_announcements_screen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: smallPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  announcement.title.toUpperCase(),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(),
              Padding(
                padding: EdgeInsets.symmetric(vertical: smallPadding),
                child: Text(
                  announcement.detail,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              const Divider(),
              Center(
                child: Padding(
                  padding: EdgeInsets.all(smallPadding),
                  child: SizedBox(
                    height: screenSize.height * 0.3,
                    child: Lottie.asset(
                      'assets/gif_json/announcement.json',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
