import 'package:aqua_tracker_managements/controller/client/detail/yearly_report/_bloc.dart';
import 'package:aqua_tracker_managements/view/basic_screen/error.dart';
import 'package:aqua_tracker_managements/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../utils/constants.dart';

class YearlyReportScreen extends StatelessWidget {
  const YearlyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<YearlyReportWidgetBloc, YearlyReportWidgetState>(
        builder: (context, state) {
          switch (state.runtimeType) {
            case const (Loading):
              return const Center(child: CircularProgressIndicator());
            case const (Loaded):
              (state as Loaded);
              return state.yearlyPayments.isEmpty
                  ? const Empty(title: 'No Yearly Report Found')
                  : Scrollbar(
                      radius: const Radius.circular(smallBorderRadius),
                      controller: state.verticalController,
                      trackVisibility: true,
                      thumbVisibility: true,
                      interactive: true,
                      thickness: smallPadding,
                      child: SingleChildScrollView(
                        controller: state.verticalController,
                        child: Scrollbar(
                          radius: const Radius.circular(smallBorderRadius),
                          controller: state.horizontalController,
                          trackVisibility: true,
                          thumbVisibility: true,
                          interactive: true,
                          thickness: smallPadding,
                          child: SingleChildScrollView(
                            controller: state.horizontalController,
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(bottom: mediumPadding),
                              child: Table(
                                border: TableBorder.all(),
                                defaultColumnWidth:
                                    FixedColumnWidth(screenSize.width * 0.32),
                                children: [
                                  TableRow(
                                    children: BlocProvider.of<
                                            YearlyReportWidgetBloc>(context)
                                        .tableTitles
                                        .map(
                                          (title) => TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: SizedBox(
                                              height: 50,
                                              child: Center(
                                                child: Text(
                                                  title,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  ...state.yearlyPayments
                                      .map<TableRow>(
                                        (payment) => TableRow(
                                          children: [
                                            _tableCell(
                                                context: context,
                                                title: DateFormat.yMd().format(
                                                    DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            payment.date))),
                                            _tableCell(
                                                context: context,
                                                title: payment
                                                    .monthReport.totalBottles
                                                    .toString()),
                                            _tableCell(
                                                context: context,
                                                title: payment.payment),
                                            _tableCell(
                                              context: context,
                                              title: BlocProvider.of<
                                                          YearlyReportWidgetBloc>(
                                                      context)
                                                  .statuses[payment.paymentStatus],
                                              style: TextStyle(
                                                color: BlocProvider.of<
                                                            YearlyReportWidgetBloc>(
                                                        context)
                                                    .paymentStatusColor(
                                                        payment: payment),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            _tableCell(
                                              context: context,
                                              title: 'See More',
                                              onTap: () => BlocProvider.of<
                                                          YearlyReportWidgetBloc>(
                                                      context)
                                                  .add(SeeMoreTab(
                                                      payment: payment)),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary),
                                            ),

                                            /// Here I use 3 and 2 Digits These are the indexes of payment statuses where 3 is for (Paid Status) and 2 for (Decline Status) Or We Can say these are Ids.
                                            TableCell(
                                              child: FittedBox(
                                                child: DropdownMenu(
                                                  hintText: 'Status',
                                                  initialSelection: payment
                                                                  .paymentStatus ==
                                                              3 ||
                                                          payment.paymentStatus ==
                                                              2
                                                      ? payment.paymentStatus
                                                      : null,
                                                  onSelected: (status) => BlocProvider
                                                          .of<YearlyReportWidgetBloc>(
                                                              context)
                                                      .add(
                                                          PaymentVerificationStatus(
                                                              status: status,
                                                              report: payment)),
                                                  dropdownMenuEntries: const [
                                                    DropdownMenuEntry(
                                                        value: 3,
                                                        label: 'Confirm'),
                                                    DropdownMenuEntry(
                                                        value: 2,
                                                        label: 'Decline'),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                      .toList()
                                      .reversed,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
            default:
              return const ErrorScreen();
          }
        },
      ),
    );
  }

  _tableCell(
      {required BuildContext context,
      required String title,
      GestureTapCallback? onTap,
      TextStyle? style}) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.transparent,
          height: 50,
          child: Center(
            child: Text(title, textAlign: TextAlign.center, style: style),
          ),
        ),
      ),
    );
  }
}
