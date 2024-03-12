import 'package:aqua_tracker_managements/controller/client/detail/yearly_report/_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../controller/client/_bloc.dart';
import '../../controller/client/detail/_cubit.dart';
import '../../controller/location_picker_dialog/location_pick_from_map/_bloc.dart';
import '../../controller/sign_in/_bloc.dart';
import '../../view/basic_screen/location_pick_from_map.dart';
import '../../view/client/client.dart';
import '../../view/client/details/details.dart';
import '../../view/sign_in/sign_in.dart';
import 'transition.dart';
import '../../controller/manager/announcements/_bloc.dart' as manager;
import '../../controller/manager/delivery_man/_bloc.dart' as manager;
import '../../controller/manager/delivery_man_location/_bloc.dart' as manager;
import '../../controller/manager/expenses/_bloc.dart' as manager;
import '../../controller/manager/home/_bloc.dart' as manager;
import '../../controller/manager/sales/_bloc.dart' as manager;
import '../../view/manager/announcements/announcements.dart' as manager;
import '../../view/manager/delivery_man/delivery_man.dart' as manager;
import '../../view/manager/delivery_man_location/delivery_man_location.dart' as manager;
import '../../view/manager/expenses/expenses.dart' as manager;
import '../../view/manager/home/home.dart' as manager;
import '../../view/manager/sales/sales.dart' as manager;

GoRouter get routerConfig => GoRouter(
      initialLocation: SignInScreen.name,
      routes: [
        GoRoute(
          path: SignInScreen.name,
          pageBuilder: (context, state) => buildFadeTransitionPage(
            state: state,
            child: BlocProvider(
              create: (context) => SignInBloc(context),
              child: const SignInScreen(),
            ),
          ),
          onExit: (context) async {
            if (SignInBloc.backTabDialogForSignInScreen) {
              return await _backButtonDialog(context);
            } else {
              return true;
            }
          },
        ),
        GoRoute(
          name: manager.HomeScreen.name,
          path: manager.HomeScreen.name,
          pageBuilder: (context, state) => buildFadeTransitionPage(
            state: state,
            child: BlocProvider(
              create: (context) => manager.HomeBloc(context),
              child: const manager.HomeScreen(),
            ),
          ),
          onExit: (context) async {
            if (manager.HomeBloc.backTabDialogForHomeScreen) {
              return await _backButtonDialog(context);
            } else {
              return true;
            }
          },
          routes: [
            GoRoute(
              name: LocationPickFromMapScreen.name,
              path: LocationPickFromMapScreen.name,
              pageBuilder: (context, state) => buildFadeTransitionPage(
                state: state,
                child: BlocProvider(
                  create: (context) => LocationPickFromMapBloc(),
                  child: const LocationPickFromMapScreen(),
                ),
              ),
            ),
            GoRoute(
              name: ClientScreen.name,
              path: ClientScreen.name,
              pageBuilder: (context, state) => buildFadeTransitionPage(
                state: state,
                child: BlocProvider(
                  create: (context) => ClientBloc(context),
                  child: const ClientScreen(),
                ),
              ),
              routes: [
                GoRoute(
                  name: ClientDetailScreen.name,
                  path: ClientDetailScreen.name,
                  pageBuilder: (context, state) {
                    var clientUid = (state.extra! as Map)['client_uid'];
                    var clientLocation = (state.extra! as Map)['client_location'];
                    return buildFadeTransitionPage(
                      state: state,
                      child: MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create: (context) => ClientDetailCubit(
                              context,
                              clientUid: clientUid,
                              location: clientLocation,
                            ),
                          ),
                          BlocProvider(
                            create: (context) => YearlyReportWidgetBloc(
                              context,
                              clientUid: clientUid,
                              location: clientLocation,
                            ),
                          ),
                        ],
                        child: const ClientDetailScreen(),
                      ),
                    );
                  },
                )
              ],
            ),
            GoRoute(
              name: manager.DeliveryManLocationScreen.name,
              path: manager.DeliveryManLocationScreen.name,
              pageBuilder: (context, state) => buildFadeTransitionPage(
                state: state,
                child: BlocProvider(
                  create: (context) => manager.DeliveryManLocationBloc(context),
                  child: const manager.DeliveryManLocationScreen(),
                ),
              ),
            ),
            GoRoute(
              name: manager.DeliveryManScreen.name,
              path: manager.DeliveryManScreen.name,
              pageBuilder: (context, state) => buildFadeTransitionPage(
                state: state,
                child: BlocProvider(
                  create: (context) => manager.DeliveryManBloc(context),
                  child: const manager.DeliveryManScreen(),
                ),
              ),
            ),
            GoRoute(
              name: manager.ExpensesScreen.name,
              path: manager.ExpensesScreen.name,
              pageBuilder: (context, state) => buildFadeTransitionPage(
                state: state,
                child: BlocProvider(
                  create: (context) => manager.ExpensesBloc(context),
                  child: const manager.ExpensesScreen(),
                ),
              ),
            ),
            GoRoute(
              name: manager.SalesScreen.name,
              path: manager.SalesScreen.name,
              pageBuilder: (context, state) => buildFadeTransitionPage(
                state: state,
                child: BlocProvider(
                  create: (context) => manager.SalesBloc(),
                  child: const manager.SalesScreen(),
                ),
              ),
            ),
            GoRoute(
              name: manager.AnnouncementsScreen.name,
              path: manager.AnnouncementsScreen.name,
              pageBuilder: (context, state) => buildFadeTransitionPage(
                state: state,
                child: BlocProvider(
                  create: (context) => manager.AnnouncementsBloc(),
                  child: const manager.AnnouncementsScreen(),
                ),
              ),
            ),
          ],
        ),
      ],
    );

//! Back Button Dialog

Future<bool> _backButtonDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      actionsAlignment: MainAxisAlignment.spaceBetween,
      title: const Text('Do you want to exit?'),
      actions: <Widget>[
        TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('No'),
            onPressed: () => Navigator.of(context).pop(false)),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Yes'),
          onPressed: () async {
            await FirebaseAuth.instance.signOut().whenComplete(() => Navigator.of(context).pop(true));
          },
        ),
      ],
    ),
  );
}
