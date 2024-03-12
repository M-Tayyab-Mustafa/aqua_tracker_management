// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../model/location.dart';
import '../../../../model/reports.dart';
import '../../../../model/user.dart';
import '../../../../screen/client/details/details.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/local_storage/hive.dart';

part '_event.dart';
part '_state.dart';

class YearReportWidgetBloc extends Bloc<YearReportWidgetEvent, YearReportWidgetState> {
  var firebaseFs = FirebaseFirestore.instance;
  final String clientUid;
  final Location location;
  final List<String> tableTitles = ['Date', 'Total Bottles', 'Payment', 'Status', '', 'Payment  Verified'];

  //* Payment Statuses (0 for Not Paid) && (1 for Pending) && (2 for Decline) && (3 for Paid)
  final List<String> statuses = ['Not Paid', 'Pending', 'Decline', 'Paid'];

  late List<YearReport> yearlyReport;
  final ScrollController verticalController = ScrollController();
  final ScrollController horizontalController = ScrollController();
  late User user;

  YearReportWidgetBloc(BuildContext context, {required this.clientUid, required this.location}) : super(Loading()) {
    LocalDatabase.getUser().then(
      (user) async => await firebaseFs
          .collection(fBCompanyCollectionKey)
          .doc(user.companyName)
          .collection(fBClientsCollectionKey)
          .doc(clientUid)
          .collection(fBReportsCollectionKey)
          .doc('${location.latitude},${location.longitude}')
          .get()
          .then((reports) {
        this.user = user;
        yearlyReport =
            List.from(reports.data()!['yearly_reports'].map<YearReport>((report) => YearReport.fromMap(report)));
        _loaded;
      }),
    );
    on<SeeMoreTab>((event, emit) {
      event.context.pushNamed(SeeMoreDetailsScreen.name, extra: event.payment);
    });
    on<PaymentStatus>((event, emit) async {
      if (event.status != null) {
        yearlyReport = yearlyReport.map((yearReport) {
          if (event.yearReport == yearReport) {
            return yearReport.copyWith(paymentStatus: event.status!);
          } else {
            return yearReport;
          }
        }).toList();
        await firebaseFs
            .collection(fBCompanyCollectionKey)
            .doc(user.companyName)
            .collection(fBClientsCollectionKey)
            .doc(clientUid)
            .collection(fBReportsCollectionKey)
            .doc('${location.latitude},${location.longitude}')
            .update({'yearly_reports': yearlyReport.map((e) => e.toMap()).toList()});
        _loaded;
      }
    });
  }

  Color paymentStatusColor({required YearReport payment}) {
    return payment.paymentStatus == 0 // index of Paid Status
        ? Colors.redAccent
        : payment.paymentStatus == 1 // index of Pending Status
            ? Colors.amber
            : payment.paymentStatus == 2 // index of Decline Status
                ? Colors.redAccent
                : Colors.green;
  }

  get loading => emit(Loading());

  get _loaded => emit(Loaded(
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
