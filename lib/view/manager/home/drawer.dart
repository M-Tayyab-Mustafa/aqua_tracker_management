import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../controller/manager/home/_bloc.dart';
import '../../../utils/constants.dart';
import '../../../utils/widgets/button.dart';
import '../../../utils/widgets/text_field.dart';
import 'profile_avatar.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        switch (state.runtimeType) {
          case const (Loading):
            return const Center(child: CircularProgressIndicator());
          case const (Loaded):
            (state as Loaded);
            return Drawer(
              child: Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: Stack(
                      children: [
                        Center(
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/profile_background.jpg'),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(largeBorderRadius),
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: smallPadding),
                                child: Text(
                                  'Aqua Tracker',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(
                                        color: Theme.of(context).primaryColor,
                                        fontFamily: customFontFamily,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ),
                            ListTile(
                              leading: ProfileAvatar(
                                  radius: BlocProvider.of<HomeBloc>(context)
                                          .profileAvatarRadius *
                                      1.2),
                              title: Text(
                                state.user.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                              ),
                              subtitle: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    child: Text(
                                      state.user.email.toUpperCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textScaler: const TextScaler.linear(1.0),
                                    ),
                                  ),
                                  FittedBox(
                                    child: Text(
                                      state.user.contact,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                      textScaler: const TextScaler.linear(1.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 9,
                    child: Stack(
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/app_icon.png',
                            opacity: const AlwaysStoppedAnimation(0.3),
                          ),
                        ),
                        Column(
                          children: [
                            Column(
                              children: [
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.person_sharp),
                                  title: const Text('Change Your Name',
                                      textScaler: TextScaler.linear(1.0)),
                                  trailing:
                                      const Icon(Icons.arrow_forward_rounded),
                                  onTap: () => showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (dialogContext) =>
                                        AlertDialog.adaptive(
                                      actionsAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      title: const Text('Change You\'r Name'),
                                      contentPadding: EdgeInsets.zero,
                                      content: Form(
                                          key: state.nameFormKey,
                                          child: NameTextField(
                                              hintText: 'Name',
                                              controller:
                                                  state.nameController)),
                                      actions: [
                                        CustomButton(
                                            onPressed: () =>
                                                Navigator.pop(dialogContext),
                                            title: 'Cancel'),
                                        CustomButton(
                                          primaryColor: true,
                                          onPressed: () =>
                                              BlocProvider.of<HomeBloc>(context)
                                                  .add(ChangeName(
                                                      dialogContext:
                                                          dialogContext)),
                                          title: 'Confirm',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.email),
                                  title: const Text('Change Your Email',
                                      textScaler: TextScaler.linear(1.0)),
                                  trailing:
                                      const Icon(Icons.arrow_forward_rounded),
                                  onTap: () => showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (dialogContext) =>
                                        AlertDialog.adaptive(
                                      title: const Text('Change You\'r Email'),
                                      contentPadding: EdgeInsets.zero,
                                      actionsAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      content: Form(
                                          key: state.emailFormKey,
                                          child: EmailTextField(
                                              controller:
                                                  state.emailController)),
                                      actions: [
                                        CustomButton(
                                            onPressed: () =>
                                                Navigator.pop(dialogContext),
                                            title: 'Cancel'),
                                        CustomButton(
                                            onPressed: () =>
                                                BlocProvider.of<HomeBloc>(
                                                        context)
                                                    .add(ChangeEmail(
                                                        dialogContext:
                                                            dialogContext)),
                                            title: 'Confirm',
                                            primaryColor: true),
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.phone),
                                  title: const Text('Change Your Contact',
                                      textScaler: TextScaler.linear(1.0)),
                                  trailing:
                                      const Icon(Icons.arrow_forward_rounded),
                                  onTap: () => showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (dialogContext) =>
                                        AlertDialog.adaptive(
                                      title:
                                          const Text('Change You\'r Contact'),
                                      contentPadding: EdgeInsets.zero,
                                      actionsAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      content: Form(
                                          key: state.contactFormKey,
                                          child: ContactTextField(
                                              hintText: 'Contact',
                                              controller:
                                                  state.contactController)),
                                      actions: [
                                        CustomButton(
                                            onPressed: () =>
                                                Navigator.pop(dialogContext),
                                            title: 'Cancel'),
                                        CustomButton(
                                            onPressed: () =>
                                                BlocProvider.of<HomeBloc>(
                                                        context)
                                                    .add(ChangeContact(
                                                        dialogContext:
                                                            dialogContext)),
                                            title: 'Confirm',
                                            primaryColor: true),
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(),
                                ListTile(
                                  onTap: () =>
                                      BlocProvider.of<HomeBloc>(context)
                                          .add(AboutUs()),
                                  leading: const Icon(Icons.question_mark),
                                  title: const Text('About Us',
                                      textScaler: TextScaler.linear(1.0)),
                                  trailing:
                                      const Icon(Icons.arrow_forward_rounded),
                                ),
                                const Divider(),
                              ],
                            ),
                            Expanded(
                              child: Center(
                                child: CustomButton(
                                  primaryColor: true,
                                  onPressed: () =>
                                      BlocProvider.of<HomeBloc>(context)
                                          .add(SignOut()),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.logout_outlined,
                                          color: Colors.white),
                                      Text('Sign Out',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          default:
            return const Drawer(
                child: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}
