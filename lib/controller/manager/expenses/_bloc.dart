// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:math';
import 'dart:developer' as developer;

import 'package:aqua_tracker_managements/utils/constants.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../../model/expense.dart';
import '../../../model/individual_bar.dart';
import '../../../model/user.dart';
import '../../../utils/validation.dart';
import '../../../utils/widgets/button.dart';
import '../../../utils/widgets/text_field.dart';
part '_event.dart';
part '_state.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final verticalScrollbarController = ScrollController(keepScrollOffset: true);
  final horizontalScrollbarController = ScrollController(keepScrollOffset: true);
  final formKey = GlobalKey<FormState>();
  final costNameController = TextEditingController();
  final detailController = TextEditingController();
  final amountController = TextEditingController();
  late List<Expense> expenses;
  bool alreadyExists = false;
  double maxYAxis = 0;
  List<IndividualBar> individualBars = [];
  late User user;
  ExpensesBloc(BuildContext context) : super(Loading()) {
    _init();
    on<Add>((event, emit) async {
      costNameController.clear();
      amountController.clear();
      detailController.clear();
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (dialogContext) => AlertDialog.adaptive(
          actionsAlignment: MainAxisAlignment.spaceBetween,
          title: const Text('Add Expense'),
          contentPadding: EdgeInsets.zero,
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                      hintText: 'Cost Name',
                      controller: costNameController,
                      keyboardType: TextInputType.text,
                      validator: simpleFieldValidation),
                  CustomTextField(
                      hintText: 'Amount',
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      validator: simpleFieldValidation),
                  CustomTextField(
                      hintText: 'Detail',
                      controller: detailController,
                      maxLength: 500,
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      validator: simpleFieldValidation),
                ],
              ),
            ),
          ),
          actions: [
            CustomButton(onPressed: () => Navigator.pop(dialogContext), title: 'Cancel'),
            CustomButton(
                onPressed: () async {
                  alreadyExists = false;
                  if (formKey.currentState!.validate()) {
                    loading;
                    Navigator.pop(dialogContext);
                    try {
                      await firebaseCompanyDoc.then((doc) async {
                        for (Expense expense in expenses) {
                          var saleDateTime = DateTime.fromMillisecondsSinceEpoch(expense.date);
                          var now = DateTime.now();
                          if (now.day == saleDateTime.day &&
                              now.month == saleDateTime.month &&
                              now.year == saleDateTime.year) {
                            var newAmount = expense.amount + double.parse(amountController.text);
                            expenses[expenses.indexOf(expense)] = Expense(
                                date: expense.date,
                                costName: '${expense.costName},\n${costNameController.text}',
                                details: '${expense.details},\n${detailController.text}',
                                amount: newAmount);
                            alreadyExists = true;
                            break;
                          }
                        }
                        if (!alreadyExists) {
                          expenses.add(Expense(
                              date: DateTime.now().millisecondsSinceEpoch,
                              costName: costNameController.text,
                              details: detailController.text,
                              amount: double.parse(amountController.text)));
                        }
                        List newExpenses = expenses.map((e) => e.toMap()).toList();
                        await doc
                            .collection(fBBranchesCollectionKey)
                            .doc(user.branch)
                            .update({'expenses': newExpenses}).then((branchDoc) {
                          _reInit;
                        });
                      });
                    } catch (e) {
                      developer.log(e.toString());
                      error;
                    }
                  }
                },
                title: 'Confirm',
                primaryColor: true),
          ],
        ),
      );
    });
  }

  get _reInit {
    loading;
    _init();
  }

  _init() async {
    try {
      await firebaseCompanyDoc.then((doc) async {
        user = await localStorage.user;
        await doc.collection(fBBranchesCollectionKey).doc(user.branch).get().then((branchDoc) {
          expenses = (branchDoc.data()!['expenses'] as List)
              .map<Expense>((expenses) => Expense.fromMap(expenses))
              .toList()
              .reversed
              .toList();
          if (expenses.isNotEmpty) {
            maxYAxis =
                expenses.map((e) => e.amount).reduce(max) + 500; // To make sure Graph always greater then max Value
            individualBars = List.generate(expenses.length,
                (index) => IndividualBar(x: index, y: expenses[index].amount, date: expenses[index].date));
            individualBars = individualBars.reversed.toList();
          }

          loaded;
        });
      });
    } catch (e) {
      developer.log(e.toString());
      error;
    }
  }

  get loading => emit(Loading());
  get loaded => emit(Loaded(
        formKey: formKey,
        verticalScrollbarController: verticalScrollbarController,
        horizontalScrollbarController: horizontalScrollbarController,
        expenses: expenses,
        individualBars: individualBars,
        maxYAxis: maxYAxis,
      ));
  get error => emit(Error());

  @override
  Future<void> close() {
    verticalScrollbarController.dispose();
    horizontalScrollbarController.dispose();
    costNameController.dispose();
    detailController.dispose();
    amountController.dispose();
    return super.close();
  }
}
