import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../controller/manager/expenses/_bloc.dart';
import '../../../utils/constants.dart';
import '../../../utils/widget/appbar.dart';
import '../../basic/empty.dart';
import '../../basic/error.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  static const String name = 'Expenses Screen';
  static const String path = 'expenses_screen';

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Expenses'),
      body: BlocBuilder<ExpensesBloc, ExpensesState>(
        builder: (context, state) {
          switch (state.runtimeType) {
            case const (Loading):
              return const Center(child: CircularProgressIndicator());
            case const (Loaded):
              (state as Loaded);
              return Stack(
                children: [
                  state.expenses.isEmpty
                      ? const Empty(title: 'No Expenses Found.')
                      : Column(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: smallPadding),
                                child: BarChart(
                                  BarChartData(
                                    minY: 0,
                                    maxY: state.maxYAxis,
                                    gridData: const FlGridData(show: true),
                                    borderData: FlBorderData(show: true),
                                    barGroups: state.individualBars
                                        .map(
                                          (barData) => BarChartGroupData(
                                            x: barData.x,
                                            barRods: [
                                              BarChartRodData(
                                                toY: barData.y,
                                                color: Colors.grey[800],
                                                width: 20,
                                                borderRadius: BorderRadius.circular(smallestBorderRadius),
                                                backDrawRodData: BackgroundBarChartRodData(
                                                  show: true,
                                                  fromY: state.maxYAxis,
                                                  color: Colors.grey[200],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                        .toList(),
                                    titlesData: FlTitlesData(
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      topTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: Theme.of(context).textTheme.headlineSmall!.fontSize!,
                                          getTitlesWidget: (value, meta) => const SizedBox(),
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: Theme.of(context).textTheme.displayLarge!.fontSize!,
                                            getTitlesWidget: (value, meta) => _leftTiles(value, meta, state: state)),
                                      ),
                                      bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) =>
                                                  _bottomTiles(value, meta, state: state))),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 7,
                              child: Scrollbar(
                                controller: state.verticalScrollbarController,
                                interactive: true,
                                thumbVisibility: true,
                                trackVisibility: true,
                                radius: Radius.circular(mediumBoardRadius),
                                child: SingleChildScrollView(
                                  controller: state.verticalScrollbarController,
                                  scrollDirection: Axis.vertical,
                                  child: Padding(
                                    padding: EdgeInsets.only(right: smallestPadding),
                                    child: Scrollbar(
                                      controller: state.horizontalScrollbarController,
                                      interactive: true,
                                      thumbVisibility: true,
                                      trackVisibility: true,
                                      radius: Radius.circular(mediumBoardRadius),
                                      child: SingleChildScrollView(
                                        controller: state.horizontalScrollbarController,
                                        scrollDirection: Axis.horizontal,
                                        child: Padding(
                                          padding: EdgeInsets.only(bottom: smallPadding),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Table(
                                                defaultVerticalAlignment: tableCellVerticalAlignment,
                                                columnWidths: {
                                                  0: FixedColumnWidth(screenSize.width * 0.25),
                                                  1: FixedColumnWidth(screenSize.width * 0.3),
                                                  2: FixedColumnWidth(screenSize.width * 0.45),
                                                  3: FixedColumnWidth(screenSize.width * 0.2),
                                                },
                                                border: TableBorder.all(),
                                                children: [
                                                  TableRow(
                                                    children: [
                                                      TableCell(
                                                          child: Text('Date',
                                                              textAlign: tableTextAlign,
                                                              style: tableHeadingTextStyle(context))),
                                                      TableCell(
                                                          child: Text('Cost Name',
                                                              textAlign: tableTextAlign,
                                                              style: tableHeadingTextStyle(context))),
                                                      TableCell(
                                                          child: Text('Details',
                                                              textAlign: tableTextAlign,
                                                              style: tableHeadingTextStyle(context))),
                                                      TableCell(
                                                          child: Text('Amount',
                                                              textAlign: tableTextAlign,
                                                              style: tableHeadingTextStyle(context))),
                                                    ],
                                                  ),
                                                  ...state.expenses.map(
                                                    (expense) => TableRow(
                                                      children: [
                                                        TableCell(
                                                            child: Text(
                                                                DateFormat.yMd().format(
                                                                    DateTime.fromMillisecondsSinceEpoch(expense.date)),
                                                                textAlign: tableTextAlign)),
                                                        TableCell(
                                                            child: Text(expense.costName, textAlign: tableTextAlign)),
                                                        TableCell(
                                                            child: Text(expense.details, textAlign: tableTextAlign)),
                                                        TableCell(
                                                            child: Text(expense.amount.toString(),
                                                                textAlign: tableTextAlign)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                  Padding(
                    padding: EdgeInsets.only(right: smallPadding, bottom: smallPadding),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton(
                        tooltip: 'Add Expense',
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
                        child: Icon(Icons.add, size: buttonSize, color: Colors.white),
                        onPressed: () => BlocProvider.of<ExpensesBloc>(context).add(Add(context: context)),
                      ),
                    ),
                  )
                ],
              );
            default:
              return const ErrorScreen();
          }
        },
      ),
    );
  }

  Widget _bottomTiles(double value, TitleMeta meta, {required Loaded state}) {
    return Text(
      DateFormat.yMd().format(DateTime.fromMillisecondsSinceEpoch(
          state.individualBars.reversed.toList()[int.parse(meta.formattedValue)].date)),
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
      textScaler: const TextScaler.linear(1.0),
    );
  }

  Widget _leftTiles(double value, TitleMeta meta, {required Loaded state}) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(right: smallestPadding),
        child: Text(meta.formattedValue,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
            textScaler: const TextScaler.linear(1.0)),
      ),
    );
  }
}
