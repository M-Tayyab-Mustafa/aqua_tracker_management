// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:developer';
import 'package:aqua_tracker_managements/controller/client/add/_bloc.dart' as add_bloc;
import 'package:aqua_tracker_managements/controller/client/edit/_bloc.dart' as edit_bloc;
import 'package:aqua_tracker_managements/model/client.dart';
import 'package:aqua_tracker_managements/utils/constants.dart';
import 'package:aqua_tracker_managements/view/client/details/details.dart';
import 'package:aqua_tracker_managements/view/basic_screen/error.dart';
import 'package:aqua_tracker_managements/utils/widgets/error_dialog.dart';
import 'package:aqua_tracker_managements/utils/widgets/loading_dialog.dart';
import 'package:aqua_tracker_managements/utils/widgets/custom_location_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:go_router/go_router.dart';
import '../../model/location.dart' as location;
import '../../utils/widgets/button.dart';
import '../../utils/widgets/text_field.dart';

part '_event.dart';

part '_state.dart';

class ClientBloc extends Bloc<ClientEvent, ClientState> {
  late List<Client> clients;
  Map<String, dynamic> addresses = {};

  ClientBloc(BuildContext context) : super(Loading()) {
    init();

    on<Add>((event, emit) async {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => BlocProvider(
          create: (context) => add_bloc.AddClientBloc(),
          child: BlocBuilder<add_bloc.AddClientBloc, add_bloc.AddClientState>(
            builder: (context, state) {
              switch (state.runtimeType) {
                case const (add_bloc.Loading):
                  return const LoadingDialog();
                case const (add_bloc.Loaded):
                  (state as add_bloc.Loaded);
                  return AlertDialog.adaptive(
                    title: const Text('Add Client'),
                    contentPadding: const EdgeInsets.symmetric(horizontal: smallPadding),
                    content: Form(key: state.emailFormKey, child: EmailTextField(controller: state.emailController)),
                    actionsAlignment: MainAxisAlignment.spaceBetween,
                    actions: [
                      CustomButton(onPressed: () => Navigator.pop(dialogContext), title: 'Cancel'),
                      CustomButton(
                          onPressed: () => BlocProvider.of<add_bloc.AddClientBloc>(context)
                              .add(add_bloc.EmailChecking(dialogContext: dialogContext)),
                          title: 'Next',
                          primaryColor: true),
                    ],
                  );
                case const (add_bloc.CreateUser):
                  (state as add_bloc.CreateUser);
                  return AlertDialog.adaptive(
                    title: const Text('Add Client'),
                    contentPadding: const EdgeInsets.symmetric(horizontal: smallPadding),
                    content: SingleChildScrollView(
                      child: Form(
                        key: state.formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            NameTextField(controller: state.nameController),
                            ContactTextField(hintText: 'Client Contact', controller: state.contactController),
                            CustomLocationPicker(
                                title: 'Client Location',
                                latitudeController: state.latitudeController,
                                longitudeController: state.longitudeController),
                            PasswordTextField(controller: state.passwordController),
                            ConfirmPasswordTextField(
                                controller: state.confirmPasswordController,
                                passwordController: state.passwordController),
                          ],
                        ),
                      ),
                    ),
                    actionsAlignment: MainAxisAlignment.spaceBetween,
                    actions: [
                      CustomButton(onPressed: () => Navigator.pop(dialogContext), title: 'Cancel'),
                      CustomButton(
                          onPressed: () => BlocProvider.of<add_bloc.AddClientBloc>(context)
                              .add(add_bloc.SubmitNewClient(dialogContext: dialogContext)),
                          title: 'Submit',
                          primaryColor: true),
                    ],
                  );
                default:
                  return const ErrorScreen();
              }
            },
          ),
        ),
      ).then((returnValue) {
        if (returnValue != null) {
          _reInit;
        }
      });
    });

    on<LocationSelected>((event, emit) {
      context.goNamed(
        ClientDetailScreen.name,
        extra: {'client_uid': event.clientUid, 'client_location': event.clientLocation},
      );
    });

    on<Edit>((event, emit) async {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => BlocProvider(
          create: (context) => edit_bloc.EditClientBloc(context, uid: event.client.uid),
          child: Builder(builder: (context) {
            return BlocBuilder<edit_bloc.EditClientBloc, edit_bloc.EditClientState>(
              builder: (context, state) {
                switch (state.runtimeType) {
                  case const (edit_bloc.Loading):
                    return const LoadingDialog();
                  case const (edit_bloc.Loaded):
                    (state as edit_bloc.Loaded);
                    return AlertDialog.adaptive(
                      title: const Text('Edit Client'),
                      actionsAlignment: MainAxisAlignment.spaceBetween,
                      contentPadding: const EdgeInsets.symmetric(vertical: mediumPadding),
                      content: Form(
                        key: state.formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              NameTextField(controller: state.editNameController),
                              ContactTextField(hintText: 'Contact', controller: state.editContactController),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: smallPadding),
                                child: Text('Locations',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                              ),
                              ...state.editClientLocations.map((location) => ListTile(
                                    title: Text(state.editAddresses[state.editClientLocations.indexOf(location)],
                                        style: Theme.of(context).textTheme.titleSmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Coordinates:',
                                            style:
                                                Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black)),
                                        Text('Latitude: ${double.parse(location.latitude).toStringAsFixed(7)}',
                                            style:
                                                Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black87)),
                                        Text('Longitude: ${double.parse(location.longitude).toStringAsFixed(7)}',
                                            style:
                                                Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black87)),
                                      ],
                                    ),
                                    leading: const Icon(Icons.location_on_rounded),
                                    trailing: IconButton(
                                        onPressed: () => BlocProvider.of<edit_bloc.EditClientBloc>(context).add(
                                            edit_bloc.DeleteClientLocation(
                                                index: state.editClientLocations.indexOf(location))),
                                        icon: const Icon(Icons.remove_circle_outline),
                                        color: Colors.redAccent),
                                  )),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: smallPadding, left: mediumPadding, right: mediumPadding),
                                  child: CustomButton(
                                    onPressed: () => BlocProvider.of<edit_bloc.EditClientBloc>(context).add(
                                        edit_bloc.AddClientLocation(
                                            client: event.client, dialogContext: dialogContext)),
                                    title: 'Add Location',
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        CustomButton(onPressed: () => Navigator.pop(dialogContext), title: 'Cancel'),
                        CustomButton(
                            onPressed: () => BlocProvider.of<edit_bloc.EditClientBloc>(context)
                                .add(edit_bloc.EditConfirm(dialogContext: dialogContext)),
                            title: 'Confirm',
                            primaryColor: true),
                      ],
                    );
                  default:
                    return const ErrorDialog();
                }
              },
            );
          }),
        ),
      ).then((returnValue) {
        if (returnValue != null) {
          _reInit;
        }
      });
    });

    on<Delete>((event, emit) async {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog.adaptive(
          title: const Text('Delete'),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          content: Text(
              'Are you sure? You want to delete ${event.client.name}, if you delete user you wont be able to recover its data.'),
          actions: [
            CustomButton(onPressed: () => Navigator.pop(dialogContext), title: 'Cancel'),
            CustomButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                loading;
                Map<String, dynamic> toDeleteField = {event.client.uid: FieldValue.delete()};
                try {
                  await firebaseCompanyDoc.then((doc) {
                    doc.collection(fBBranchesCollectionKey).doc(event.client.branch).get().then((branchSnapshot) async {
                      await auth.FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                              email: event.client.email, password: branchSnapshot.data()![event.client.uid])
                          .then((userCredential) async {
                        await userCredential.user!.delete();
                        await doc.collection(fBBranchesCollectionKey).doc(event.client.branch).update(toDeleteField);
                        await doc
                            .collection('clients')
                            .doc(event.client.uid)
                            .collection('reports')
                            .get()
                            .then((reportsQuerySnapshot) async {
                          for (QueryDocumentSnapshot documentSnapshot in reportsQuerySnapshot.docs) {
                            await documentSnapshot.reference.delete();
                          }
                        });
                        await doc.collection('clients').doc(event.client.uid).delete();
                        _reInit;
                      });
                    });
                  });
                } catch (exception) {
                  log(exception.toString());
                  error;
                }
              },
              title: 'Confirm',
              primaryColor: true,
            ),
          ],
        ),
      );
    });
  }

  get _reInit {
    addresses.clear();
    loading;
    init();
  }

  init() {
    try {
      firebaseCompanyDoc.then((doc) => doc.collection('clients').get().then((clientCollection) async {
            clients = clientCollection.docs.map((clientDoc) => Client.fromMap(clientDoc.data())).toList();
            for (Client client in clients) {
              List<String> address = [];
              for (location.Location clientLocation in client.locations) {
                var placeMarker = await geocoding.placemarkFromCoordinates(
                    double.parse(clientLocation.latitude), double.parse(clientLocation.longitude));
                address.add(
                    '${placeMarker.first.street}, ${placeMarker.first.subLocality}, ${placeMarker.first.locality}');
              }
              addresses.addAll({client.uid: address});
            }
            loaded;
          }));
    } catch (exception) {
      log(exception.toString());
      showErrorToast(msg: 'Something went wrong! Try again later.');
      error;
    }
  }

  get loading => emit(Loading());

  get loaded => emit(Loaded(clients: clients));
  get error => emit(Error());
}
