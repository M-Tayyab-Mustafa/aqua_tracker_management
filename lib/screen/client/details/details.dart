import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../controller/client/detail/_cubit.dart';
import '../../../controller/client/detail/yearly_report/_bloc.dart' as yearly_bloc;
import '../../../model/reports.dart';
import '../../../utils/constants.dart';
import '../../../utils/widget/appbar.dart';
import '../../basic/empty.dart';
import '../../basic/error.dart';

class ClientDetailScreen extends StatefulWidget {
  const ClientDetailScreen({super.key});

  static const String name = 'Client Detail';
  static const String path = 'client_detail';

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> with SingleTickerProviderStateMixin {
  @override
  void didChangeDependencies() {
    BlocProvider.of<ClientDetailCubit>(context).init(tickerProvider: this);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Details'),
      body: BlocBuilder<ClientDetailCubit, ClientDetailState>(
        builder: (context, state) {
          switch (state.runtimeType) {
            case const (Loading):
              return const Center(child: CircularProgressIndicator());
            case const (Loaded):
              (state as Loaded);
              return Center(
                child: Column(
                  children: [
                    TabBar(
                      controller: state.tabController,
                      labelColor: Theme.of(context).primaryColor,
                      tabs: state.tabs,
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: state.tabController,
                        children: [
                          MonthReportWidget(monthReport: state.monthReport),
                          BlocProvider(
                            create: (context) => yearly_bloc.YearReportWidgetBloc(context,
                                clientUid: state.clientUid, location: state.location),
                            child: const _YearReportWidget(),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            default:
              return const ErrorScreen();
          }
        },
      ),
    );
  }
}

class MonthReportWidget extends StatelessWidget {
  const MonthReportWidget({super.key, required this.monthReport});
  final MonthReport monthReport;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: smallPadding, vertical: smallPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: smallPadding),
                    height: 10,
                    width: 10,
                    color: Colors.green,
                  ),
                  const Text('Bottles you confirmed'),
                ],
              ),
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(right: smallPadding),
                    height: 10,
                    width: 10,
                    color: Colors.amber,
                  ),
                  const Text('Bottles you don\'t confirmed'),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: smallPadding),
          child: TableCalendar(
            focusedDay: DateTime.now(),
            firstDay: DateTime.now().copyWith(day: 1),
            lastDay: DateTime.now().copyWith(day: DateUtils.getDaysInMonth(DateTime.now().year, DateTime.now().month)),
            headerVisible: false,
            daysOfWeekHeight: screenSize.height * 0.05,
            daysOfWeekStyle: DaysOfWeekStyle(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
              weekdayStyle: const TextStyle(color: Colors.white),
              weekendStyle: const TextStyle(color: Colors.white),
            ),
            calendarStyle: CalendarStyle(cellAlignment: Alignment.center, tableBorder: TableBorder.all()),
            calendarBuilders: CalendarBuilders(
              todayBuilder: (context, day, focusedDay) {
                if (monthReport.details.containsKey(day.day.toString())) {
                  return _cellContainsBottlesDecoration(monthReport: monthReport, day: day);
                }
                return null;
              },
              defaultBuilder: (context, day, focusedDay) {
                return _cellContainsBottlesDecoration(monthReport: monthReport, day: day);
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: smallPadding, horizontal: smallestPadding),
          child: Text(
            'Total No Of Bottles: ${monthReport.totalBottles}',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(letterSpacing: 1),
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget? _cellContainsBottlesDecoration({required MonthReport monthReport, required DateTime day}) {
    return monthReport.details.containsKey(day.day.toString())
        ? Center(
            child: Container(
              color: monthReport.details[day.day.toString()]!.approved ? Colors.greenAccent : Colors.amberAccent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        day.day.toString(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Container(
                        height: constraints.maxHeight,
                        width: constraints.maxWidth,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '${monthReport.details[day.day.toString()]!.bottles} Bottles',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          )
        : null;
  }
}

class _YearReportWidget extends StatelessWidget {
  const _YearReportWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<yearly_bloc.YearReportWidgetBloc, yearly_bloc.YearReportWidgetState>(
        builder: (context, state) {
          switch (state.runtimeType) {
            case const (yearly_bloc.Loading):
              return const Center(child: CircularProgressIndicator());
            case const (yearly_bloc.Loaded):
              (state as yearly_bloc.Loaded);
              return state.yearlyPayments.isEmpty
                  ? const Empty(title: 'No Yearly Report Found')
                  : Scrollbar(
                      radius: Radius.circular(smallBorderRadius),
                      controller: state.verticalController,
                      trackVisibility: true,
                      thumbVisibility: true,
                      interactive: true,
                      thickness: smallPadding,
                      child: SingleChildScrollView(
                        controller: state.verticalController,
                        child: Scrollbar(
                          radius: Radius.circular(smallBorderRadius),
                          controller: state.horizontalController,
                          trackVisibility: true,
                          thumbVisibility: true,
                          interactive: true,
                          thickness: 8,
                          child: SingleChildScrollView(
                            controller: state.horizontalController,
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: mediumPadding),
                              child: Table(
                                border: TableBorder.all(),
                                defaultColumnWidth: FixedColumnWidth(screenSize.width * 0.32),
                                children: [
                                  TableRow(
                                    children: BlocProvider.of<yearly_bloc.YearReportWidgetBloc>(context)
                                        .tableTitles
                                        .map(
                                          (title) => TableCell(
                                            verticalAlignment: TableCellVerticalAlignment.middle,
                                            child: SizedBox(
                                              height: 50,
                                              child: Center(
                                                child: Text(
                                                  title,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
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
                                                title: DateFormat.yMd()
                                                    .format(DateTime.fromMillisecondsSinceEpoch(payment.date))),
                                            _tableCell(
                                                context: context, title: payment.monthReport.totalBottles.toString()),
                                            _tableCell(context: context, title: payment.payment),
                                            _tableCell(
                                              context: context,
                                              title: BlocProvider.of<yearly_bloc.YearReportWidgetBloc>(context)
                                                  .statuses[payment.paymentStatus],
                                              style: TextStyle(
                                                color: BlocProvider.of<yearly_bloc.YearReportWidgetBloc>(context)
                                                    .paymentStatusColor(payment: payment),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            _tableCell(
                                              context: context,
                                              title: 'See More',
                                              onTap: () => BlocProvider.of<yearly_bloc.YearReportWidgetBloc>(context)
                                                  .add(yearly_bloc.SeeMoreTab(context: context, payment: payment)),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: Theme.of(context).colorScheme.primary),
                                            ),

                                            /// Here I use 3 and 2 Digits These are the indexes of payment statuses where 3 is for (Paid Status) and 2 for (Decline Status) Or We Can say these are Ids.
                                            TableCell(
                                              child: FittedBox(
                                                child: DropdownMenu(
                                                  hintText: 'Status',
                                                  initialSelection:
                                                      payment.paymentStatus == 3 || payment.paymentStatus == 2
                                                          ? payment.paymentStatus
                                                          : null,
                                                  onSelected: (status) =>
                                                      BlocProvider.of<yearly_bloc.YearReportWidgetBloc>(context).add(
                                                          yearly_bloc.PaymentStatus(
                                                              status: status, yearReport: payment)),
                                                  dropdownMenuEntries: const [
                                                    DropdownMenuEntry(value: 3, label: 'Confirm'),
                                                    DropdownMenuEntry(value: 2, label: 'Decline'),
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

  _tableCell({required BuildContext context, required String title, GestureTapCallback? onTap, TextStyle? style}) {
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

class SeeMoreDetailsScreen extends StatefulWidget {
  const SeeMoreDetailsScreen({super.key, required this.yearReport});

  static const String name = 'Monthly Report Screen';
  static const String path = 'monthly_report_screen';

  final YearReport yearReport;

  @override
  State<SeeMoreDetailsScreen> createState() => _SeeMoreDetailsScreenState();
}

class _SeeMoreDetailsScreenState extends State<SeeMoreDetailsScreen> {
  late DateTime paymentDateTime;
  @override
  void initState() {
    super.initState();
    paymentDateTime = DateTime.fromMillisecondsSinceEpoch(widget.yearReport.date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Details'),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: smallPadding, vertical: smallPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(children: [
                  Container(
                    margin: EdgeInsets.only(right: smallPadding),
                    height: 10,
                    width: 10,
                    color: Colors.green,
                  ),
                  const Text('Bottles User Confirmed')
                ]),
                Row(children: [
                  Container(
                    margin: EdgeInsets.only(right: smallPadding),
                    height: 10,
                    width: 10,
                    color: Colors.amber,
                  ),
                  const Text('Bottles User Don\'t Confirmed')
                ]),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: mediumPadding),
            child: TableCalendar(
              focusedDay: paymentDateTime,
              firstDay: paymentDateTime.copyWith(day: 1),
              lastDay:
                  DateTime(paymentDateTime.year, DateUtils.getDaysInMonth(paymentDateTime.year, paymentDateTime.month)),
              headerVisible: false,
              daysOfWeekHeight: screenSize.height * 0.05,
              daysOfWeekStyle: DaysOfWeekStyle(
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                  weekdayStyle: const TextStyle(color: Colors.white),
                  weekendStyle: const TextStyle(color: Colors.white)),
              calendarStyle: CalendarStyle(cellAlignment: Alignment.center, tableBorder: TableBorder.all()),
              calendarBuilders: CalendarBuilders(defaultBuilder: (context, day, focusedDay) {
                var monthReport = widget.yearReport.monthReport;
                return monthReport.details.containsKey(day.day.toString())
                    ? Center(
                        child: Container(
                          color: monthReport.details[day.day.toString()]!.approved
                              ? Colors.greenAccent
                              : Colors.amberAccent,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(day.day.toString()),
                                ),
                              ),
                              Expanded(
                                child: LayoutBuilder(builder: (context, constraints) {
                                  return Container(
                                    height: constraints.maxHeight,
                                    width: constraints.maxWidth,
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Text(
                                      '${monthReport.details[day.day.toString()]!.bottles} Bottles',
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      )
                    : null;
              }),
            ),
          ),
          Padding(
              padding: EdgeInsets.symmetric(vertical: smallPadding, horizontal: smallestPadding),
              child: Text('Total No Of Bottles: ${widget.yearReport.monthReport.totalBottles}',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(letterSpacing: 1), maxLines: 2))
        ],
      ),
    );
  }
}
