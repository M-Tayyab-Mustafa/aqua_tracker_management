import 'package:aqua_tracker_management/utils/widget/appbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import '../../../controller/manager/home/_bloc.dart';
import '../../../utils/constants.dart';
import '../../../utils/widget/card.dart';
import '../../../utils/widget/custom_avatars.dart';
import '../../basic/error.dart';
import 'drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String name = 'Manager Home';
  static const String path = '/manager_home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<HomeBloc>(context).initial(this, context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: BlocProvider.of<HomeBloc>(context).scaffoldKey,
      endDrawer: const CustomDrawer(),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          switch (state.runtimeType) {
            case const (Loading):
              return const Material(child: Center(child: CircularProgressIndicator.adaptive()));
            case const (Loaded):
              (state as Loaded);
              return Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomAppBar(
                          title: 'Home',
                          actions: [
                            Padding(
                              padding: EdgeInsets.only(right: smallestPadding),
                              child: CustomNetworkAvatar(
                                onTap: () =>
                                    BlocProvider.of<HomeBloc>(context).scaffoldKey.currentState!.openEndDrawer(),
                                radius: kTextTabBarHeight * 0.9,
                                imageUrl: state.user.imageUrl,
                              ),
                            ),
                          ],
                        ),
                        ImageSlideshow(
                          height: state.addSize,
                          indicatorBottomPadding: mediumPadding,
                          isLoop: true,
                          autoPlayInterval: 40000,
                          indicatorRadius: 5,
                          initialPage: 0,
                          indicatorColor: Theme.of(context).colorScheme.primary,
                          disableUserScrolling: false,
                          indicatorBackgroundColor: Colors.white,
                          children: state.listOfAds
                              .map(
                                (bannerAd) => Padding(
                                  padding: EdgeInsets.all(smallPadding),
                                  child: Material(
                                    borderRadius: BorderRadius.circular(smallBorderRadius),
                                    elevation: 5,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(smallBorderRadius),
                                      child: CachedNetworkImage(
                                        fit: BoxFit.fill,
                                        imageUrl: bannerAd,
                                        progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                          child: CircularProgressIndicator(
                                            value: downloadProgress.progress,
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(angle(angle: state.rotationTween.value)),
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
                              offset: Offset.zero,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                        child: Opacity(
                          opacity: state.opacityTween.value,
                          child: Stack(
                            children: [
                              Center(
                                child: Image.asset(
                                  'assets/app_icon.png',
                                  opacity: const AlwaysStoppedAnimation(0.3),
                                ),
                              ),
                              Center(
                                child: GridView(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: smallPadding,
                                    mainAxisSpacing: smallPadding,
                                    childAspectRatio: 1.3,
                                  ),
                                  children: [
                                    HomeScreenCard(
                                      image: 'assets/icons/clients.png',
                                      title: 'Clients',
                                      onTab: () => BlocProvider.of<HomeBloc>(context).add(Client()),
                                    ),
                                    HomeScreenCard(
                                      image: 'assets/icons/delivery_man_locations.png',
                                      title: 'Delivery Mans Location',
                                      onTab: () => BlocProvider.of<HomeBloc>(context).add(DeliveryManLocation()),
                                    ),
                                    HomeScreenCard(
                                      image: 'assets/icons/delivery_man.png',
                                      title: 'Delivery Mans',
                                      onTab: () => BlocProvider.of<HomeBloc>(context).add(DeliveryMan()),
                                    ),
                                    HomeScreenCard(
                                      image: 'assets/icons/expenses.png',
                                      title: 'Expenses',
                                      onTab: () => BlocProvider.of<HomeBloc>(context).add(Expenses()),
                                    ),
                                    HomeScreenCard(
                                      image: 'assets/icons/today_sale.png',
                                      title: 'Sales',
                                      onTab: () => BlocProvider.of<HomeBloc>(context).add(Sales()),
                                    ),
                                    HomeScreenCard(
                                      image: 'assets/icons/company_ads.png',
                                      title: 'Announcement',
                                      onTab: () => BlocProvider.of<HomeBloc>(context).add(Announcements()),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
}

class HomeScreenCard extends StatelessWidget {
  const HomeScreenCard({super.key, this.image, this.icon = Icons.add, required this.title, required this.onTab});
  final String? image;
  final IconData icon;
  final String title;
  final GestureTapCallback onTab;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 8,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CustomCard(
                width: constraints.maxWidth * 0.5,
                onTap: onTab,
                child: Padding(
                  padding: EdgeInsets.all(smallestPadding),
                  child: Center(
                    child: image != null
                        ? Image.asset(
                            image!,
                            color: Colors.white,
                            fit: BoxFit.fill,
                          )
                        : FittedBox(
                            child: Icon(
                              icon,
                              size: constraints.maxWidth * 0.5,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          flex: 5,
          child: Center(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: smallPadding),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          )),
        ),
      ],
    );
  }
}
