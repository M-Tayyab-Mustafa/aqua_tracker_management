import 'package:aqua_tracker_managements/controller/client/detail/_cubit.dart';
import 'package:aqua_tracker_managements/model/reports.dart';
import 'package:aqua_tracker_managements/view/client/details/reports/yearly_report.dart';
import 'package:aqua_tracker_managements/view/basic_screen/error.dart';
import 'package:aqua_tracker_managements/utils/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../utils/constants.dart';

class ClientDetailScreen extends StatefulWidget {
  const ClientDetailScreen({super.key});

  static const String name = 'client_detail';

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
      body: BlocBuilder<ClientDetailCubit, ClientDetailScreenState>(
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
                          monthlyReportWidget(state.monthReport),
                          const YearlyReportScreen(),
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

  Widget monthlyReportWidget(MonthReport monthReport) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: smallPadding, vertical: smallPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: smallPadding),
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
                    margin: const EdgeInsets.only(right: smallPadding),
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
          padding: const EdgeInsets.symmetric(vertical: smallPadding),
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
                  return cellContainsBottlesDecoration(monthReport: monthReport, day: day);
                }
                return null;
              },
              defaultBuilder: (context, day, focusedDay) {
                return cellContainsBottlesDecoration(monthReport: monthReport, day: day);
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: smallPadding, horizontal: smallestPadding),
          child: Text(
            'Total No Of Bottles: ${monthReport.totalBottles}',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(letterSpacing: 1),
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget? cellContainsBottlesDecoration({required MonthReport monthReport, required DateTime day}) {
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
        : day.isBefore(DateTime.now())
            ? Center(
                child: Container(
                  color: Colors.greenAccent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: Center(child: Text(day.day.toString()))),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Container(
                              height: constraints.maxHeight,
                              width: constraints.maxWidth,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                '0 Bottles',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null;
  }
}
