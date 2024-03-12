import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../utils/constants.dart';
import '../../controller/location_picker_dialog/location_pick_from_map/_bloc.dart';

class LocationPickFromMapScreen extends StatelessWidget {
  const LocationPickFromMapScreen({super.key});

  static const String name = 'location_pick_from_map';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LocationPickFromMapBloc, LocationPickFromMapState>(
        builder: (context, state) {
          switch (state.runtimeType) {
            case const (Loading):
              return const Center(child: CircularProgressIndicator());
            default:
              (state as Loaded);
              return Scaffold(
                body: Stack(
                  children: [
                    GoogleMap(
                      myLocationEnabled: true,
                      onMapCreated: BlocProvider.of<LocationPickFromMapBloc>(context).onMapCreated,
                      tiltGesturesEnabled: false,
                      zoomGesturesEnabled: false,
                      zoomControlsEnabled: false,
                      initialCameraPosition: CameraPosition(
                          target: BlocProvider.of<LocationPickFromMapBloc>(context).currentUserLocation, zoom: 15.0),
                      markers: state.markers,
                      onTap: (argument) =>
                          BlocProvider.of<LocationPickFromMapBloc>(context).add(AddMarkerEvent(location: argument)),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ],
                ),
                floatingActionButton: state.markers.isEmpty
                    ? null
                    : FloatingActionButton(
                        onPressed: () => Navigator.pop(context, state.markers.first.position),
                        backgroundColor: buttonColors,
                        child: Padding(
                          padding: const EdgeInsets.all(smallestPadding),
                          child: FittedBox(
                            child: Text(
                              'Confirm',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
              );
          }
        },
      ),
    );
  }
}
