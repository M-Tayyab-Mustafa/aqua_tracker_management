// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part '_event.dart';
part '_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(Loading()) {
    _loaded;
  }
  get _loaded => emit(Loaded());
  get _loading => emit(Loading());
}
