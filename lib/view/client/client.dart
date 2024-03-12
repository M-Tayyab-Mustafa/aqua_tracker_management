import 'package:aqua_tracker_managements/controller/client/_bloc.dart';
import 'package:aqua_tracker_managements/model/location.dart';
import 'package:aqua_tracker_managements/utils/constants.dart';
import 'package:aqua_tracker_managements/view/basic_screen/error.dart';
import 'package:aqua_tracker_managements/utils/widgets/appbar.dart';
import 'package:aqua_tracker_managements/utils/widgets/card.dart';
import 'package:aqua_tracker_managements/utils/widgets/empty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/client.dart';
import '../../utils/widgets/button.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  static const String name = 'client_screen';

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const CustomAppBar(title: 'Clients'),
      body: BlocBuilder<ClientBloc, ClientState>(
        builder: (context, state) {
          switch (state.runtimeType) {
            case const (Loading):
              return const Material(child: Center(child: CircularProgressIndicator()));
            case const (Loaded):
              (state as Loaded);
              return Stack(
                children: [
                  state.clients.isEmpty
                      ? const Empty(title: 'No Clients Available')
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.clients.length,
                          itemBuilder: (context, index) {
                            Client client = state.clients[index];
                            return CustomDragAbleCard(
                              dismissDirection: DismissDirection.horizontal,
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  BlocProvider.of<ClientBloc>(context).add(Edit(client: client));
                                } else {
                                  BlocProvider.of<ClientBloc>(context).add(Delete(client: client));
                                }
                                return null;
                              },
                              key: Key(client.uid),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(client.name.toUpperCase(),
                                            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                                color: Colors.white,
                                                overflow: TextOverflow.ellipsis,
                                                fontWeight: FontWeight.bold),
                                            maxLines: 2),
                                        Text(client.email.toUpperCase(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(color: Colors.white, overflow: TextOverflow.ellipsis),
                                            maxLines: 1),
                                        Text(client.contact,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(color: Colors.white, overflow: TextOverflow.ellipsis),
                                            maxLines: 1),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(mediumBoardRadius),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: smallestPadding),
                                          child: Text.rich(
                                            TextSpan(
                                              children: [
                                                const TextSpan(text: 'Status: '),
                                                TextSpan(
                                                  text: client.onVacations ? 'OnVacation' : 'Available',
                                                  style: client.onVacations
                                                      ? const TextStyle(color: Colors.redAccent)
                                                      : const TextStyle(color: Colors.green),
                                                ),
                                              ],
                                            ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall!
                                                .copyWith(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: mediumPadding),
                                        child: CustomButton(
                                          onPressed: () => _clientDetailTap(client: client),
                                          title: 'Details',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: smallPadding,
                        bottom: smallPadding,
                      ),
                      child: FloatingActionButton(
                        onPressed: () => BlocProvider.of<ClientBloc>(context).add(Add()),
                        backgroundColor: buttonColors,
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: buttonSize.height * 0.7,
                        ),
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

  Future<bool> _clientDetailTap({required Client client}) async {
    return await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog.adaptive(
        actionsAlignment: MainAxisAlignment.spaceBetween,
        title: Text('Select ${client.name} Location'),
        contentPadding: const EdgeInsets.symmetric(vertical: smallPadding),
        content: ListView.builder(
          itemCount: client.locations.length,
          shrinkWrap: true,
          itemBuilder: (_, index) {
            Location clientLocation = client.locations[index];
            return ListTile(
              onTap: () => BlocProvider.of<ClientBloc>(context)
                  .add(LocationSelected(clientUid: client.uid, clientLocation: clientLocation)),
              title: Text(
                BlocProvider.of<ClientBloc>(context).addresses[client.uid][index],
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coordinates:',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black),
                  ),
                  Text(
                    'Latitude: ${double.parse(clientLocation.latitude).toStringAsFixed(7)}',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black87),
                  ),
                  Text(
                    'Longitude: ${double.parse(clientLocation.longitude).toStringAsFixed(7)}',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black87),
                  ),
                ],
              ),
              leading: const Icon(Icons.location_on_rounded),
            );
          },
        ),
        actions: [
          CustomButton(
            onPressed: () => Navigator.pop(dialogContext),
            title: 'Cancel',
          ),
        ],
      ),
    );
  }
}
