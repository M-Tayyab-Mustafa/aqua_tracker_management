import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../controller/manager/home/_bloc.dart';
import '../../../utils/constants.dart';
import '../../../utils/widgets/appbar.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import '../../basic_screen/error.dart';
import 'card.dart';
import 'drawer.dart';
import 'profile_avatar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String name = '/home_screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<HomeBloc>(context).initial(this, context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const CustomDrawer(),
      key: BlocProvider.of<HomeBloc>(context).scaffoldKey,
      appBar: CustomAppBar(
        title: 'Home',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: smallestPadding),
            child: GestureDetector(
              onTap: () => BlocProvider.of<HomeBloc>(context)
                  .scaffoldKey
                  .currentState!
                  .openEndDrawer(),
              child: ProfileAvatar(
                  radius:
                      BlocProvider.of<HomeBloc>(context).profileAvatarRadius),
            ),
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          switch (state.runtimeType) {
            case const (Loading):
              return const Material(
                  child: Center(child: CircularProgressIndicator()));

            case const (Loaded):
              (state as Loaded);
              return Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ImageSlideshow(
                        indicatorBottomPadding: mediumPadding,
                        isLoop: true,
                        autoPlayInterval: autoTimeInterval,
                        indicatorRadius: 5,
                        initialPage: 0,
                        indicatorColor: Theme.of(context).colorScheme.primary,
                        disableUserScrolling: false,
                        indicatorBackgroundColor: Colors.white,
                        height: state.addsHeightTween.value,
                        children: state.listOfAds
                            .map(
                              (bannerAd) => Padding(
                                padding: const EdgeInsets.all(smallPadding),
                                child: Material(
                                  borderRadius:
                                      BorderRadius.circular(smallBorderRadius),
                                  elevation: 5,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        smallBorderRadius),
                                    child: CachedNetworkImage(
                                      imageUrl: bannerAd,
                                      fit: BoxFit.cover,
                                      progressIndicatorBuilder: (context, url,
                                              downloadProgress) =>
                                          Center(
                                              child: CircularProgressIndicator(
                                                  value: downloadProgress
                                                      .progress)),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      Center(
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(
                            angle(angle: state.rotationTween.value),
                          ),
                          child: Container(
                            height: state.heightTween.value,
                            width: state.widthTween.value,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                state.borderRadiusTween.value,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: state.boxShadowTween.value,
                                  offset: const Offset(-1, -1),
                                  color: Colors.black45,
                                ),
                                BoxShadow(
                                  blurRadius: state.boxShadowTween.value,
                                  offset: const Offset(1, 1),
                                  color: Colors.black12,
                                ),
                              ],
                            ),
                            child: Opacity(
                              opacity: state.opacityTween.value,
                              child: Stack(
                                children: [
                                  Center(
                                    child: Image.asset(
                                      'assets/images/app_icon.png',
                                      opacity:
                                          const AlwaysStoppedAnimation(0.3),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(smallPadding),
                                    child: GridView(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: smallPadding,
                                        mainAxisSpacing: smallPadding,
                                        childAspectRatio: 0.78,
                                      ),
                                      children: [
                                        HomeScreenCard(
                                          image: 'assets/icons/clients.png',
                                          title: 'Clients',
                                          onTab: () =>
                                              BlocProvider.of<HomeBloc>(context)
                                                  .add(Client()),
                                        ),
                                        HomeScreenCard(
                                          image:
                                              'assets/icons/delivery_man_locations.png',
                                          title: 'Delivery Mans Location',
                                          onTab: () =>
                                              BlocProvider.of<HomeBloc>(context)
                                                  .add(DeliveryManLocation()),
                                        ),
                                        HomeScreenCard(
                                          image:
                                              'assets/icons/delivery_man.png',
                                          title: 'Delivery Mans',
                                          onTab: () =>
                                              BlocProvider.of<HomeBloc>(context)
                                                  .add(DeliveryMan()),
                                        ),
                                        HomeScreenCard(
                                          image: 'assets/icons/expenses.png',
                                          title: 'Expenses',
                                          onTab: () =>
                                              BlocProvider.of<HomeBloc>(context)
                                                  .add(Expenses()),
                                        ),
                                        HomeScreenCard(
                                          image: 'assets/icons/today_sale.png',
                                          title: 'Sales',
                                          onTab: () =>
                                              BlocProvider.of<HomeBloc>(context)
                                                  .add(Sales()),
                                        ),
                                        HomeScreenCard(
                                          image: 'assets/icons/company_ads.png',
                                          title: 'Announcement',
                                          onTab: () =>
                                              BlocProvider.of<HomeBloc>(context)
                                                  .add(Announcements()),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            default:
              return const ErrorScreen();
          }
        },
      ),
    );
  }
}
