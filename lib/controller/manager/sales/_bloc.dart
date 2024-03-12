// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:developer' as developer;
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../model/individual_bar.dart';
import '../../../model/sale.dart';
import '../../../model/user.dart';
import '../../../utils/constants.dart';
import '../../../utils/local_storage/hive.dart';
import '../../../utils/validation.dart';
import '../../../utils/widget/button.dart';
import '../../../utils/widget/text_field.dart';
part '_state.dart';
part '_event.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  var firebaseFs = FirebaseFirestore.instance;
  late List<Sale> sales;
  late User user;
  final addBottlesController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  double maxYAxis = 0;
  List<IndividualBar> individualBars = [];
  SalesBloc() : super(Loading()) {
    _init();
    on<Add>((event, emit) async {
      bool alreadyExists = false;
      addBottlesController.clear();
      await showDialog(
        barrierDismissible: false,
        context: event.context,
        builder: (context) => AlertDialog.adaptive(
          actionsAlignment: MainAxisAlignment.spaceBetween,
          contentPadding: EdgeInsets.zero,
          title: const Text('Add Today Sale'),
          content: Form(
            key: formKey,
            child: CustomTextField(
                hintText: 'Bottles',
                controller: addBottlesController,
                validator: simpleFieldValidation,
                keyboardType: TextInputType.number),
          ),
          actions: [
            CustomButton(onPressed: () => Navigator.pop(context), title: 'Cancel'),
            CustomButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  loading;
                  int bottles = int.parse(addBottlesController.text);
                  Navigator.pop(context);
                  try {
                    await firebaseFs
                        .collection(fBCompanyCollectionKey)
                        .doc(user.companyName)
                        .get()
                        .then((company) async {
                      double bottlePrice = double.parse((company.data() as Map)['bottle_price'].toString());
                      for (Sale sale in sales) {
                        var saleDateTime = DateTime.fromMillisecondsSinceEpoch(sale.date);
                        var now = DateTime.now();
                        if (now.day == saleDateTime.day &&
                            now.month == saleDateTime.month &&
                            now.year == saleDateTime.year) {
                          var newBottles = sale.bottles + bottles;
                          sales[(sales.indexOf(sale))] =
                              sale.copyWith(bottles: newBottles, amount: bottlePrice * newBottles);

                          alreadyExists = true;
                          break;
                        }
                      }
                      if (!alreadyExists) {
                        sales.add(Sale(
                          date: DateTime.now().millisecondsSinceEpoch,
                          bottles: bottles,
                          amount: (bottlePrice * bottles),
                        ));
                      }
                      List newSales = sales.map((e) => e.toMap()).toList();
                      await firebaseFs
                          .collection(fBCompanyCollectionKey)
                          .doc(user.companyName)
                          .collection(fBBranchesCollectionKey)
                          .doc(user.branch)
                          .update({'sales': newSales}).whenComplete(() {
                        _reInit;
                      });
                    });
                  } catch (e) {
                    developer.log(e.toString());
                    error;
                  }
                }
              },
              title: 'Add',
              primaryColor: true,
            ),
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
      user = await LocalDatabase.getUser();
      await firebaseFs
          .collection(fBCompanyCollectionKey)
          .doc(user.companyName)
          .collection(fBBranchesCollectionKey)
          .doc(user.branch)
          .get()
          .then((branchDoc) {
        sales = (branchDoc.data()!['sales'] as List).map<Sale>((sale) => Sale.fromMap(sale)).toList().reversed.toList();
        if (sales.isNotEmpty) {
          maxYAxis = sales.map((e) => e.amount).reduce(max) + 500; //* To make sure Graph always greater then max Value
          individualBars = List.generate(
              sales.length, (index) => IndividualBar(x: index, y: sales[index].amount, date: sales[index].date));
          individualBars = individualBars.reversed.toList();
        }
        _loaded;
      });
    } catch (e) {
      developer.log(e.toString());
      error;
    }
  }

  get loading => emit(Loading());
  get _loaded => emit(Loaded(
        sales: sales,
        individualBars: individualBars,
        maxYAxis: maxYAxis,
      ));
  get error => emit(Error());

  @override
  Future<void> close() {
    addBottlesController.dispose();
    return super.close();
  }
}
