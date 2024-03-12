// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'package:aqua_tracker_managements/model/reports.dart';
import 'package:aqua_tracker_managements/model/user.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../../../model/location.dart';
import '../../../../utils/constants.dart';
import '../../../../view/client/details/reports/monthly_report.dart';

part '_event.dart';

part '_state.dart';

class YearlyReportWidgetBloc extends Bloc<YearlyReportWidgetEvent, YearlyReportWidgetState> {
  final String clientUid;
  final Location location;

  final List<String> tableTitles = ['Date', 'Total Bottles', 'Payment', 'Status', '', 'Payment  Verified'];

  //* Payment Statuses (0 for Not Paid) && (1 for Pending) && (2 for Decline) && (3 for Paid)
  final List<String> statuses = ['Not Paid', 'Pending', 'Decline', 'Paid'];

  late List<YearlyReport> yearlyReport;

  final ScrollController verticalController = ScrollController();
  final ScrollController horizontalController = ScrollController();
  late User user;

  YearlyReportWidgetBloc(BuildContext context, {required this.clientUid, required this.location}) : super(Loading()) {
    init();
    on<SeeMoreTab>((event, emit) {
      Navigator.pushNamed(context, MonthReportScreen.screenName, arguments: event.payment);
    });
    on<PaymentVerificationStatus>((event, emit) async {
      if (event.status != null) {
        yearlyReport = yearlyReport.map((payment) {
          if (event.report == payment) {
            return payment.copyWith(paymentStatus: event.status!);
          } else {
            return payment;
          }
        }).toList();
        (await firebaseCompanyDoc)
            .collection('clients')
            .doc(clientUid)
            .collection('reports')
            .doc('${location.latitude},${location.longitude}')
            .update({'yearly_reports': yearlyReport.map((e) => e.toMap()).toList()});
        loaded;
      }
    });
  }

  init() async {
    (await firebaseCompanyDoc)
        .collection('clients')
        .doc(clientUid)
        .collection('reports')
        .doc('${location.latitude},${location.longitude}')
        .get()
        .then((reports) {
      yearlyReport =
          List.from(reports.data()!['yearly_reports'].map<YearlyReport>((report) => YearlyReport.fromMap(report)));
      loaded;
    });
  }

  Color paymentStatusColor({required YearlyReport payment}) {
    return payment.paymentStatus == 0 // index of Paid Status
        ? Colors.redAccent
        : payment.paymentStatus == 1 // index of Pending Status
            ? Colors.amber
            : payment.paymentStatus == 2 // index of Decline Status
                ? Colors.redAccent
                : Colors.green;
  }

  get loading => emit(Loading());

  get loaded => emit(Loaded(
      yearlyPayments: yearlyReport,
      verticalController: verticalController,
      horizontalController: horizontalController));

  @override
  Future<void> close() {
    verticalController.dispose();
    horizontalController.dispose();
    return super.close();
  }
}
