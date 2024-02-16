// ignore_for_file: body_might_complete_normally_nullable
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../controller/manager/delivery_man/_bloc.dart';
import '../../../model/employee.dart';
import '../../../utils/constants.dart';
import '../../../utils/widget/appbar.dart';
import '../../../utils/widget/card.dart';
import '../../../utils/widget/custom_avatars.dart';
import '../../../utils/widget/image_preview.dart';
import '../../basic/empty.dart';
import '../../basic/error.dart';

class DeliveryManScreen extends StatelessWidget {
  const DeliveryManScreen({super.key});

  static const String name = 'Delivery Man';
  static const String path = 'delivery_man';

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
              return Stack(
                children: [
                  state.deliveryMans.isEmpty
                      ? const Empty(title: 'No Delivery Man Found')
                      : ListView.builder(
                          itemCount: state.deliveryMans.length,
                          itemBuilder: (_, index) {
                            Employee employee = state.deliveryMans[index];
                            return CustomDragAbleCard(
                              key: Key(employee.uid),
                              dismissDirection: DismissDirection.horizontal,
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  BlocProvider.of<DeliveryManBloc>(context).add(Edit(employee: employee));
                                } else {
                                  BlocProvider.of<DeliveryManBloc>(context).add(Delete(employee: employee));
                                }
                              },
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Hero(
                                        tag: employee.imageUrl,
                                        child: CustomNetworkAvatar(
                                          radius: constraints.maxWidth * 0.25,
                                          imageUrl: employee.imageUrl,
                                          onTap: () => context.pushNamed(ImagePreviewScreen.name,
                                              extra: {'image_url': employee.imageUrl, 'tag': employee.imageUrl}),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.only(left: smallPadding),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(
                                                employee.name,
                                                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                                      color: Colors.white,
                                                      overflow: TextOverflow.ellipsis,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                maxLines: 1,
                                              ),
                                              Text(
                                                employee.email.toUpperCase(),
                                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                      color: Colors.white,
                                                      overflow: TextOverflow.ellipsis,
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                maxLines: 1,
                                              ),
                                              Text(
                                                employee.contact,
                                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                      color: Colors.white,
                                                      overflow: TextOverflow.ellipsis,
                                                      fontWeight: FontWeight.w800,
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
                    padding: EdgeInsets.only(right: smallPadding, bottom: smallPadding),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton(
                        onPressed: () => BlocProvider.of<DeliveryManBloc>(context).add(Add()),
                        tooltip: 'Add Delivery Man',
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
                        child: Icon(Icons.add, size: buttonSize, color: Colors.white),
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
