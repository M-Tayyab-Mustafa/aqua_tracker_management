import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../model/reports.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/widgets/appbar.dart';

class MonthReportScreen extends StatelessWidget {
  const MonthReportScreen({super.key, required this.payment});

  static const String screenName = '/monthly_report_screen';

  final YearlyReport payment;

  @override
  Widget build(BuildContext context) {
    DateTime paymentDateTime =
        DateTime.fromMillisecondsSinceEpoch(payment.date);
    return Scaffold(
      appBar: const CustomAppBar(title: 'Month Report'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: smallPadding, vertical: smallPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(children: [
                  Container(
                      margin: const EdgeInsets.only(right: smallPadding),
                      height: 10,
                      width: 10,
                      color: Colors.green),
                  const Text('Bottles User Confirmed')
                ]),
                Row(children: [
                  Container(
                      margin: const EdgeInsets.only(right: smallPadding),
                      height: 10,
                      width: 10,
                      color: Colors.amber),
                  const Text('Bottles User Don\'t Confirmed')
                ]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: mediumPadding),
            child: TableCalendar(
              focusedDay: paymentDateTime,
              firstDay: paymentDateTime.copyWith(day: 1),
              lastDay: DateTime(
                  paymentDateTime.year,
                  DateUtils.getDaysInMonth(
                      paymentDateTime.year, paymentDateTime.month)),
              headerVisible: false,
              daysOfWeekHeight: screenSize.height * 0.05,
              daysOfWeekStyle: DaysOfWeekStyle(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary),
                  weekdayStyle: const TextStyle(color: Colors.white),
                  weekendStyle: const TextStyle(color: Colors.white)),
              calendarStyle: CalendarStyle(
                  cellAlignment: Alignment.center,
                  tableBorder: TableBorder.all()),
              calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) =>
                      cellContainsBottlesDecoration(
                          monthReport: payment.monthReport, day: day)),
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: smallPadding, horizontal: smallestPadding),
              child: Text(
                  'Total No Of Bottles: ${payment.monthReport.totalBottles}',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(letterSpacing: 1),
                  maxLines: 2))
        ],
      ),
    );
  }

  Widget cellContainsBottlesDecoration(
      {required MonthReport monthReport, required DateTime day}) {
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
                  Expanded(child: Center(child: Text(day.day.toString()))),
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
        : Center(
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
          );
  }
}
