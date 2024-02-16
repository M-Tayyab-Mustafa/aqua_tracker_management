import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../controller/manager/delivery_man/delivery_man_location/_bloc.dart';
import '../../../utils/widget/appbar.dart';
import '../../basic/error.dart';

class DeliveryManLocationScreen extends StatelessWidget {
  const DeliveryManLocationScreen({super.key});

  static const String name = 'Delivery Man Location';
  static const String path = 'delivery_man_location';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Delivery Man Location'),
      body: BlocBuilder<DeliveryManLocationBloc, DeliveryManLocationState>(
        builder: (context, state) {
          switch (state.runtimeType) {
            case const (Loading):
              return const Center(child: CircularProgressIndicator());
            case const (Loaded):
              (state as Loaded);
              return GoogleMap(
                onMapCreated: BlocProvider.of<DeliveryManLocationBloc>(context).onMapCreate,
                initialCameraPosition: state.initialCameraPosition,
                markers: state.markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                trafficEnabled: true,
                tiltGesturesEnabled: false,
              );
            default:
              return const ErrorScreen();
          }
        },
      ),
    );
  }
}
