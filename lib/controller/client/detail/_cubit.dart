import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/location.dart';
import '../../../model/reports.dart';
import '../../../utils/constants.dart';
import '../../../utils/local_storage/hive.dart';

part '_state.dart';

class ClientDetailCubit extends Cubit<ClientDetailState> {
  var firebaseFs = FirebaseFirestore.instance;
  final String clientUid;
  final Location location;
  late MonthReport monthReport;
  late TabController tabController;
  final List<Widget> tabs = [
    const Tab(text: 'Monthly Report'),
    const Tab(text: 'Yearly Report'),
  ];

  ClientDetailCubit(BuildContext context, {required this.clientUid, required this.location}) : super(Loading());

  init({required TickerProvider tickerProvider}) async {
    tabController = TabController(length: tabs.length, vsync: tickerProvider);
    try {
      _loading;
      await LocalDatabase.getUser().then((user) async {
        await firebaseFs
            .collection(fBCompanyCollectionKey)
            .doc(user.companyName)
            .collection(fBClientsCollectionKey)
            .doc(clientUid)
            .collection(fBReportsCollectionKey)
            .doc('${location.latitude},${location.longitude}')
            .get()
            .then((reports) {
          monthReport = MonthReport.fromMap(reports.data()!['month_report']);
          _loaded;
        });
      });
    } catch (e) {
      log(e.toString());
      _error;
    }
  }

  get _loading => emit(Loading());

  get _error => emit(Loading());

  get _loaded => emit(Loaded(
        tabs: tabs,
        tabController: tabController,
        monthReport: monthReport,
        clientUid: clientUid,
        location: location,
      ));

  @override
  Future<void> close() {
    tabController.dispose();
    return super.close();
  }
}
