// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:developer';

import 'package:aqua_tracker_managements/model/announcement.dart';
import 'package:aqua_tracker_managements/utils/constants.dart';
import 'package:aqua_tracker_managements/view/manager/announcements/preview_announcement.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../../utils/validation.dart';
import '../../../utils/widgets/button.dart';
import '../../../utils/widgets/text_field.dart';

part '_event.dart';
part '_state.dart';

class AnnouncementsBloc extends Bloc<AnnouncementsEvent, AnnouncementsState> {
  final double cardSize = 150;
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final detailController = TextEditingController();
  late List<Announcement> announcements;
  AnnouncementsBloc() : super(Loading()) {
    _init();
    on<BroadCast>((event, emit) async {
      titleController.clear();
      detailController.clear();
      await showDialog(
        context: event.context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('New Announcement'),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    hintText: 'Title',
                    controller: titleController,
                    keyboardType: TextInputType.text,
                    validator: simpleFieldValidation,
                  ),
                  CustomTextField(
                    hintText: 'Detail',
                    counterText: '',
                    controller: detailController,
                    maxLength: 1000,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    validator: simpleFieldValidation,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            CustomButton(onPressed: () => Navigator.pop(dialogContext), title: 'Cancel'),
            CustomButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  loading;
                  Navigator.pop(dialogContext);
                  try {
                    var doc = await firebaseCompanyDoc;
                    var user = await localStorage.user;
                    announcements.add(Announcement(
                        date: DateTime.now().millisecondsSinceEpoch,
                        title: titleController.text,
                        detail: detailController.text));
                    doc
                        .collection(fBBranchesCollectionKey)
                        .doc(user.branch)
                        .update({'announcements': announcements.map((e) => e.toMap())}).whenComplete(() => _reInit);
                  } catch (e) {
                    log(e.toString());
                    error;
                  }
                }
              },
              title: 'Confirm',
              primaryColor: true,
            ),
          ],
        ),
      );
    });

    on<CardTab>((event, emit) {
      Navigator.pushNamed(event.context, PreviewAnnouncementScreen.screenName, arguments: event.announcement);
    });
  }

  _init() async {
    var doc = await firebaseCompanyDoc;
    var user = await localStorage.user;
    doc.collection(fBBranchesCollectionKey).doc(user.branch).get().then((querySnapshot) {
      announcements = (querySnapshot.data()!['announcements'] as List)
          .map<Announcement>((map) => Announcement.fromMap(map))
          .toList()
          .reversed
          .toList();
      loaded;
    });
  }

  get _reInit {
    loading;
    _init();
  }

  get loading => emit(Loading());
  get loaded => emit(Loaded(cardSize: cardSize, announcements: announcements));

  get error => emit(Error());

  @override
  Future<void> close() {
    titleController.dispose();
    detailController.dispose();
    return super.close();
  }
}
