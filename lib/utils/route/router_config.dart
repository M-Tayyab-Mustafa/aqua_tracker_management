import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../controller/client/_bloc.dart';
import '../../controller/client/detail/_cubit.dart';
import '../../controller/sign_in/_bloc.dart';
import '../../custom_location_picker/location_pick_from_map.dart';
import '../../custom_location_picker/location_pick_from_map/_bloc.dart';
import '../../model/announcement.dart';
import '../../model/reports.dart';
import '../../screen/basic/about_us.dart';
import '../../screen/basic/not_verified.dart';
import '../../screen/client/client.dart';
import '../../screen/client/details/details.dart';
import '../../screen/sign_in.dart';
import '../../screen/deliveryman/home.dart' as deliveryman;
//! Manager Blocs Paths
import '../../controller/manager/sales/_bloc.dart' as manager;
import '../../controller/manager/home/_bloc.dart' as manager;
import '../../controller/manager/expenses/_bloc.dart' as manager;
import '../../controller/manager/delivery_man/_bloc.dart' as manager;
import '../../controller/manager/announcements/_bloc.dart' as manager;
import '../../controller/manager/delivery_man/delivery_man_location/_bloc.dart' as manager;
//! Manager Screens Paths
import '../widget/image_preview.dart';
import '../../screen/manager/home/home.dart' as manager;
import '../../screen/manager/sales/sales.dart' as manager;
import '../../screen/manager/expenses/expenses.dart' as manager;
import '../../screen/manager/delivery_man/delivery_man.dart' as manager;
import '../../screen/manager/announcements/announcements.dart' as manager;
import '../../screen/manager/delivery_man/delivery_man_location.dart' as manager;
import '../../screen/manager/announcements/preview_announcement.dart' as manager;
import 'screen_transition.dart';

GoRouter get routerConfig => GoRouter(
      initialLocation: SignInScreen.path,
      routes: [
        //! Navigate To Sign In Screen
        GoRoute(
          name: SignInScreen.name,
          path: SignInScreen.path,
          onExit: (context) async {
            if (SignInBloc.showBackTabDialog) {
              return await _backButtonDialog(context);
            } else {
              return true;
            }
          },
          pageBuilder: (context, state) => ScreenTransition.screenFadeTransition(
            state: state,
            child: BlocProvider(
              create: (context) => SignInBloc(context: context),
              child: const SignInScreen(),
            ),
          ),
          routes: [
            GoRoute(
              name: NotVerifiedScreen.name,
              path: NotVerifiedScreen.path,
              pageBuilder: (context, state) => ScreenTransition.screenFadeTransition(
                state: state,
                child: const NotVerifiedScreen(),
              ),
            )
          ],
        ),
        //! Navigate To Manager Home Screen
        GoRoute(
          name: manager.HomeScreen.name,
          path: manager.HomeScreen.path,
          onExit: (context) async {
            if (manager.HomeBloc.showBackTabDialog) {
              return await _backButtonDialog(context);
            } else {
              return true;
            }
          },
          pageBuilder: (context, state) => ScreenTransition.screenFadeTransition(
            state: state,
            child: BlocProvider(
              create: (context) => manager.HomeBloc(),
              child: const manager.HomeScreen(),
            ),
          ),
          routes: [
            //! Navigate To Delivery Man Location Screen For Manager
            GoRoute(
              name: manager.DeliveryManLocationScreen.name,
              path: manager.DeliveryManLocationScreen.path,
              pageBuilder: (context, state) => ScreenTransition.screenFadeTransition(
                state: state,
                child: BlocProvider(
                  create: (context) => manager.DeliveryManLocationBloc(context),
                  child: const manager.DeliveryManLocationScreen(),
                ),
              ),
            ),
            //! Navigate To Delivery Man Screen For Manager
            GoRoute(
              name: manager.DeliveryManScreen.name,
              path: manager.DeliveryManScreen.path,
              pageBuilder: (context, state) => ScreenTransition.screenFadeTransition(
                state: state,
                child: BlocProvider(
                  create: (context) => manager.DeliveryManBloc(context),
                  child: const manager.DeliveryManScreen(),
                ),
              ),
            ),
            //! Navigate To Sales Screen
            GoRoute(
              name: manager.SalesScreen.name,
              path: manager.SalesScreen.path,
              pageBuilder: (context, state) => ScreenTransition.screenFadeTransition(
                state: state,
                child: BlocProvider(
                  create: (context) => manager.SalesBloc(),
                  child: const manager.SalesScreen(),
                ),
              ),
            ),
            //! Navigate To Expenses Screen
            GoRoute(
              name: manager.ExpensesScreen.name,
              path: manager.ExpensesScreen.path,
              pageBuilder: (context, state) => ScreenTransition.screenFadeTransition(
                state: state,
                child: BlocProvider(
                  create: (context) => manager.ExpensesBloc(context),
                  child: const manager.ExpensesScreen(),
                ),
              ),
            ),
            //! Navigate To Announcements Screen
            GoRoute(
                name: manager.AnnouncementsScreen.name,
                path: manager.AnnouncementsScreen.path,
                pageBuilder: (context, state) => ScreenTransition.screenFadeTransition(
                      state: state,
                      child: BlocProvider(
                        create: (context) => manager.AnnouncementsBloc(),
                        child: const manager.AnnouncementsScreen(),
                      ),
                    ),
                routes: [
                  //! Navigate To Preview Announcement Screen
                  GoRoute(
                    name: manager.PreviewAnnouncementScreen.name,
                    path: manager.PreviewAnnouncementScreen.path,
                    pageBuilder: (context, state) => ScreenTransition.screenFadeTransition(
                      state: state,
                      child: manager.PreviewAnnouncementScreen(announcement: (state.extra as Announcement)),
                    ),
                  ),
                ]),
          ],
        ),
        //! Navigate To Delivery Man Home Screen
        GoRoute(
          name: deliveryman.HomeScreen.name,
          path: deliveryman.HomeScreen.path,
          pageBuilder: (context, state) => ScreenTransition.screenFadeTransition(
            state: state,
            child: const deliveryman.HomeScreen(),
          ),
        ),
        //! Navigate To Client Screen
        GoRoute(
          name: ClientScreen.name,
          path: ClientScreen.path,
          pageBuilder: (context, state) => ScreenTransition.screenFadeTransition(
            state: state,
            child: BlocProvider(
              create: (context) => ClientBloc(context),
              child: const ClientScreen(),
            ),
          ),
          routes: [
            GoRoute(
                name: ClientDetailScreen.name,
                path: ClientDetailScreen.path,
                pageBuilder: (context, state) => ScreenTransition.screenFadeTransition(
                      state: state,
                      child: BlocProvider(
                        create: (context) => ClientDetailCubit(context,
                            clientUid: (state.extra as Map)['client_uid'],
                            location: (state.extra as Map)['client_location']),
                        child: const ClientDetailScreen(),
                      ),
                    ),
                routes: [
                  GoRoute(
                    name: SeeMoreDetailsScreen.name,
                    path: SeeMoreDetailsScreen.path,
                    pageBuilder: (context, state) => ScreenTransition.screenFadeTransition(
                      state: state,
                      child: SeeMoreDetailsScreen(yearReport: (state.extra as YearReport)),
                    ),
                  ),
                ]),
          ],
        ),
        //! Navigate To Location Picking Screen
        GoRoute(
          name: PickLocationFromMapScreen.name,
          path: PickLocationFromMapScreen.path,
          pageBuilder: (context, state) => ScreenTransition.screenFadeTransition(
            state: state,
            child: BlocProvider(
              create: (context) => PickLocationFromMapBloc(),
              child: const PickLocationFromMapScreen(),
            ),
          ),
        ),
        //! Navigate To Image Preview Screen
        GoRoute(
          name: ImagePreviewScreen.name,
          path: ImagePreviewScreen.path,
          pageBuilder: (context, state) => ScreenTransition.screenFadeTransition(
            state: state,
            child: ImagePreviewScreen(imageUrl: (state.extra as Map)['image_url'], tag: (state.extra as Map)['tag']),
          ),
        ),
        //! Navigate To About Us Screen
        GoRoute(
          name: AboutUsScreen.name,
          path: AboutUsScreen.path,
          pageBuilder: (context, state) => ScreenTransition.screenFadeTransition(
            state: state,
            child: const AboutUsScreen(),
          ),
        ),
      ],
    );

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
            onPressed: () => Navigator.pop(context, false)),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Yes'),
          onPressed: () async => await FirebaseAuth.instance.signOut().whenComplete(() => Navigator.pop(context, true)),
        ),
      ],
    ),
  );
}
