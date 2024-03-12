// ignore_for_file: body_might_complete_normally_nullable

import 'package:aqua_tracker_managements/view/manager/delivery_man/image_preview.dart';
import 'package:aqua_tracker_managements/utils/widgets/custom_avatars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../controller/manager/delivery_man/_bloc.dart';
import '../../../model/delivery_man.dart';
import '../../../utils/constants.dart';
import '../../../utils/widgets/appbar.dart';
import '../../../utils/widgets/card.dart';
import '../../../utils/widgets/empty.dart';
import '../../basic_screen/error.dart';

class DeliveryManScreen extends StatelessWidget {
  const DeliveryManScreen({super.key});

  static const String name = 'delivery_man';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Delivery Mans'),
      body: BlocBuilder<DeliveryManBloc, DeliveryManState>(
        builder: (context, state) {
          switch (state.runtimeType) {
            case const (Loading):
              return const Center(child: CircularProgressIndicator());
            case const (Loaded):
              (state as Loaded);
              return state.deliveryMans.isEmpty
                  ? const Empty(title: 'No Delivery Man Found')
                  : Stack(
                      children: [
                        ListView.builder(
                          itemCount: state.deliveryMans.length,
                          itemBuilder: (_, index) {
                            Employee employee = state.deliveryMans[index];
                            return CustomDragAbleCard(
                              key: Key(employee.uid),
                              dismissDirection: DismissDirection.horizontal,
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  BlocProvider.of<DeliveryManBloc>(context)
                                      .add(Edit(employee: employee));
                                } else {
                                  BlocProvider.of<DeliveryManBloc>(context)
                                      .add(Delete(employee: employee));
                                }
                              },
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Hero(
                                        tag: employee.uid,
                                        child: CustomNetworkAvatar(
                                          radius: constraints.maxWidth * 0.25,
                                          imageUrl: employee.imageUrl,
                                          onTap: () => Navigator.pushNamed(
                                              context,
                                              ImagePreviewScreen.screenName,
                                              arguments: [
                                                employee.imageUrl,
                                                employee.uid
                                              ]),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: smallPadding),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(
                                                employee.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium!
                                                    .copyWith(
                                                      color: Colors.white,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                maxLines: 1,
                                              ),
                                              Text(
                                                employee.email.toUpperCase(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      color: Colors.white,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                maxLines: 1,
                                              ),
                                              Text(
                                                employee.contact,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                      color: Colors.white,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                maxLines: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: smallPadding, bottom: smallPadding),
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: FloatingActionButton(
                              onPressed: () =>
                                  BlocProvider.of<DeliveryManBloc>(context)
                                      .add(Add()),
                              tooltip: 'Add Delivery Man',
                              backgroundColor: buttonColors,
                              child: Icon(Icons.add,
                                  size: buttonSize.height * 0.7,
                                  color: Colors.white),
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
}
