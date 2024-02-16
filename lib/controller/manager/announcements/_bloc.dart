// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../model/announcement.dart';
import '../../../model/user.dart';
import '../../../screen/manager/announcements/preview_announcement.dart';
import '../../../utils/constants.dart';
import '../../../utils/local_storage/hive.dart';
import '../../../utils/validation.dart';
import '../../../utils/widget/button.dart';
import '../../../utils/widget/text_field.dart';
part '_event.dart';
part '_state.dart';

class AnnouncementsBloc extends Bloc<AnnouncementsEvent, AnnouncementsState> {
  var firebaseFs = FirebaseFirestore.instance;
  final double cardSize = 150;
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final detailController = TextEditingController();
  late List<Announcement> announcements;
  late User user;
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
                    announcements.add(Announcement(
                      date: DateTime.now().millisecondsSinceEpoch,
                      title: titleController.text,
                      detail: detailController.text,
                    ));
                    await firebaseFs
                        .collection(fBCompanyCollectionKey)
                        .doc(user.companyName)
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
      event.context.pushNamed(PreviewAnnouncementScreen.name, extra: event.announcement);
    });
  }

  _init() async {
    user = await LocalDatabase.getUser();
    await firebaseFs
        .collection(fBCompanyCollectionKey)
        .doc(user.companyName)
        .collection(fBBranchesCollectionKey)
        .doc(user.branch)
        .get()
        .then((querySnapshot) {
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
