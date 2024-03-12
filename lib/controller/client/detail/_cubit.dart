import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../../model/location.dart';
import '../../../model/reports.dart';
import '../../../utils/constants.dart';

part '_state.dart';

class ClientDetailCubit extends Cubit<ClientDetailScreenState> {
  final String clientUid;
  final Location location;
  late MonthReport monthReport;
  late TabController tabController;
  final List<Widget> tabs = [
    const Tab(text: 'Monthly Report'),
    const Tab(text: 'Yearly Report'),
  ];

  ClientDetailCubit(BuildContext context, {required this.clientUid, required this.location}) : super(Loading());

  init({required TickerProvider tickerProvider}) {
    tabController = TabController(length: tabs.length, vsync: tickerProvider);
    firebaseCompanyDoc.then((doc) => doc
            .collection('clients')
            .doc(clientUid)
            .collection('reports')
            .doc('${location.latitude},${location.longitude}')
            .get()
            .then((reports) {
          monthReport = MonthReport.fromMap(reports.data()!['month_report']);
          loaded;
        }));
  }

  get loading => emit(Loading());

  get loaded => emit(
        Loaded(
          tabs: tabs,
          tabController: tabController,
          monthReport: monthReport,
        ),
      );

  @override
  Future<void> close() {
    tabController.dispose();
    return super.close();
  }
}
