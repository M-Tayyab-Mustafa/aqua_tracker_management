// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../custom_location_picker/custom_location_picker.dart';
import '../../model/client.dart';
import '../../model/location.dart' as location;
import '../../model/user.dart';
import '../../screen/basic/error.dart';
import '../../screen/client/details/details.dart';
import '../../utils/constants.dart';
import '../../utils/local_storage/hive.dart';
import '../../utils/widget/button.dart';
import '../../utils/widget/error_dialog.dart';
import '../../utils/widget/loading_dialog.dart';
import '../../utils/widget/text_field.dart';
import 'add/_bloc.dart' as add_bloc;
import 'edit/_bloc.dart' as edit_bloc;

part '_event.dart';
part '_state.dart';

class ClientBloc extends Bloc<ClientEvent, ClientState> {
  final firebaseFs = FirebaseFirestore.instance;
  late User user;
  List<Client> clients = [];

  ClientBloc(BuildContext context) : super(Loading()) {
    _init;
    on<LocationSelected>((event, emit) {
      context.pushNamed(
        ClientDetailScreen.name,
        extra: {'client_uid': event.clientUid, 'client_location': event.clientLocation},
      );
    });
    on<Edit>((event, emit) async {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => BlocProvider(
          create: (context) => edit_bloc.EditClientBloc(uid: event.client.uid),
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
                      contentPadding: EdgeInsets.symmetric(vertical: mediumPadding),
                      content: Form(
                        key: state.formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              NameTextField(controller: state.nameController),
                              ContactTextField(hintText: 'Contact', controller: state.contactController),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: smallPadding),
                                child: Text(
                                  'Locations',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                                ),
                              ),
                              ...state.locations.map(
                                (location) => ListTile(
                                  title: Text(
                                    location.address,
                                    style: Theme.of(context).textTheme.titleSmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Coordinates:',
                                        style: Theme.of(context).textTheme.bodyMedium!,
                                      ),
                                      Text(
                                        'Latitude: ${double.parse(location.latitude).toStringAsFixed(7)}',
                                        style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black87),
                                      ),
                                      Text(
                                        'Longitude: ${double.parse(location.longitude).toStringAsFixed(7)}',
                                        style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                  leading: const Icon(Icons.location_on_rounded),
                                  trailing: state.locations.length == 1
                                      ? null
                                      : IconButton(
                                          onPressed: () => BlocProvider.of<edit_bloc.EditClientBloc>(context)
                                              .add(edit_bloc.DeleteLocation(location: location)),
                                          icon: const Icon(Icons.remove_circle_outline),
                                          color: Colors.redAccent,
                                        ),
                                ),
                              ),
                              Center(
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(bottom: smallPadding, left: mediumPadding, right: mediumPadding),
                                  child: CustomButton(
                                    onPressed: () => BlocProvider.of<edit_bloc.EditClientBloc>(context)
                                        .add(edit_bloc.AddLocation(client: event.client, dialogContext: dialogContext)),
                                    title: 'Add Location',
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      actions: [
                        CustomButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          title: 'Cancel',
                        ),
                        CustomButton(
                          onPressed: () => BlocProvider.of<edit_bloc.EditClientBloc>(context)
                              .add(edit_bloc.EditConfirm(dialogContext: dialogContext, client: event.client)),
                          title: 'Confirm',
                          primaryColor: true,
                        ),
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
                _loading;
                Navigator.pop(dialogContext);
                try {
                  var clientDoc = firebaseFs
                      .collection(fBCompanyCollectionKey)
                      .doc(event.client.companyName)
                      .collection(fBClientsCollectionKey)
                      .doc(event.client.uid);
                  await auth.FirebaseAuth.instance
                      .signInWithEmailAndPassword(email: event.client.email, password: event.client.password)
                      .then((userCredential) async {
                    await userCredential.user!.delete();
                    await clientDoc.collection('reports').get().then((reportsQuerySnapshot) async {
                      for (QueryDocumentSnapshot documentSnapshot in reportsQuerySnapshot.docs) {
                        await documentSnapshot.reference.delete();
                      }
                    });
                    await clientDoc.delete();
                    _reInit;
                  });
                } catch (exception) {
                  log(exception.toString());
                  _error;
                }
              },
              title: 'Confirm',
              primaryColor: true,
            ),
          ],
        ),
      );
    });
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
                case const (add_bloc.EmailChecking):
                  (state as add_bloc.EmailChecking);
                  return AlertDialog.adaptive(
                    title: const Text('Add Client'),
                    contentPadding: EdgeInsets.symmetric(horizontal: smallPadding),
                    content: Form(key: state.emailFormKey, child: EmailTextField(controller: state.emailController)),
                    actionsAlignment: MainAxisAlignment.spaceBetween,
                    actions: [
                      CustomButton(onPressed: () => Navigator.pop(dialogContext), title: 'Cancel'),
                      CustomButton(
                        title: 'Next',
                        primaryColor: true,
                        onPressed: () => BlocProvider.of<add_bloc.AddClientBloc>(context)
                            .add(add_bloc.SubmitEmail(dialogContext: dialogContext)),
                      ),
                    ],
                  );
                case const (add_bloc.AddClient):
                  (state as add_bloc.AddClient);
                  return AlertDialog.adaptive(
                    title: const Text('Add Client'),
                    actionsAlignment: MainAxisAlignment.spaceBetween,
                    contentPadding: EdgeInsets.symmetric(horizontal: smallestPadding),
                    content: SingleChildScrollView(
                      child: Form(
                        key: state.formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            NameTextField(controller: state.nameController),
                            ContactTextField(hintText: 'Contact', controller: state.contactController),
                            CustomLocationPicker(
                              title: 'Location',
                              latitudeController: state.latitudeController,
                              longitudeController: state.longitudeController,
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      CustomButton(onPressed: () => Navigator.pop(dialogContext), title: 'Cancel'),
                      CustomButton(
                        onPressed: () => BlocProvider.of<add_bloc.AddClientBloc>(context)
                            .add(add_bloc.SubmitClient(dialogContext: dialogContext)),
                        title: 'Submit',
                        primaryColor: true,
                      ),
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
          _loading;
          _init;
        }
      });
    });
  }
  Future<void> get _init async {
    try {
      await LocalDatabase.getUser().then((user) async {
        this.user = user;
        await firebaseFs
            .collection(fBCompanyCollectionKey)
            .doc(user.companyName)
            .collection(fBClientsCollectionKey)
            .get()
            .then((clientCollection) {
          if (clientCollection.docs.isNotEmpty) {
            List<Client> allClients = clientCollection.docs.map((map) => Client.fromMap(map.data())).toList();
            for (var client in allClients) {
              if (client.branch == user.branch) {
                clients.add(client);
              }
            }
          }
          _loaded;
        });
      });
    } catch (exception) {
      log(exception.toString());
      showErrorToast(msg: 'Something went wrong! Try again later.');
      _error;
    }
  }

  get _reInit {
    _loading;
    clients.clear();
    _init;
  }

  get _loading => emit(Loading());
  get _loaded => emit(Loaded(clients: clients));
  get _error => emit(Error());
}
