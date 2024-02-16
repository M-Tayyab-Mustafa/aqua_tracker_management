import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../controller/sign_in/_bloc.dart';
import '../utils/constants.dart';
import '../utils/validation.dart';
import '../utils/widget/button.dart';
import '../utils/widget/dropdown_button_form_field.dart';
import '../utils/widget/text_field.dart';
import 'basic/disconnected.dart';
import 'basic/error.dart';
import 'basic/splashed.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});
  static const String name = 'Sign In';
  static const String path = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SignInBloc, SignInState>(
        builder: (context, state) {
          switch (state.runtimeType) {
            case const (Splashed):
              return const SplashedScreen();
            case const (Disconnected):
              return const DisconnectedScreen();
            case const (Loading):
              return const Center(child: CircularProgressIndicator());
            case const (Error):
              return const ErrorScreen();
            default:
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: screenSize.height * 0.25,
                      width: double.infinity,
                      child: Image.asset(
                        fit: BoxFit.fill,
                        'assets/login_background.png',
                      ),
                    ),
                    Form(
                      key: (state as Loaded).formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomDropdownButtonFormField(
                            dropDownFormFieldValidator: dropDownFormFieldValidatorForCompanyField,
                            defaultHintValue: 'Select company',
                            selected: BlocProvider.of<SignInBloc>(context).selectedCompany,
                            items: state.companies
                                .map(
                                  (company) => DropdownMenuItem(
                                    value: company.name,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(right: smallPadding),
                                          child: FittedBox(
                                            child: CachedNetworkImage(
                                              imageBuilder: (context, imageProvider) {
                                                return CircleAvatar(
                                                  radius: 20,
                                                  backgroundImage: imageProvider,
                                                  backgroundColor: Colors.transparent,
                                                );
                                              },
                                              fit: BoxFit.fill,
                                              imageUrl: company.logo,
                                              progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                                child: CircularProgressIndicator(
                                                  value: downloadProgress.progress,
                                                ),
                                              ),
                                              errorWidget: (context, url, error) =>
                                                  const Center(child: Icon(Icons.error)),
                                            ),
                                          ),
                                        ),
                                        Text(company.name),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (name) => BlocProvider.of<SignInBloc>(context).add(CompanyChange(name)),
                          ),
                          Visibility(
                            visible: state.branches.isNotEmpty,
                            child: CustomDropdownButtonFormField(
                              dropDownFormFieldValidator: dropDownFormFieldValidatorBranchField,
                              defaultHintValue: 'Select Branch',
                              selected: BlocProvider.of<SignInBloc>(context).selectedBranch,
                              items: state.branches
                                  .map(
                                    (branch) => DropdownMenuItem(
                                      value: branch,
                                      child: Text(branch),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (branch) => BlocProvider.of<SignInBloc>(context).add(BranchChange(branch)),
                            ),
                          ),
                          CustomDropdownButtonFormField(
                            dropDownFormFieldValidator: dropDownFormFieldValidatorForPostField,
                            defaultHintValue: 'Select Post',
                            selected: BlocProvider.of<SignInBloc>(context).selectedPost,
                            items: [
                              DropdownMenuItem(
                                value: managerPost,
                                child: Text(managerPost),
                              ),
                              DropdownMenuItem(
                                value: deliveryManPost,
                                child: Text(deliveryManPost),
                              ),
                            ],
                            onChanged: (post) => BlocProvider.of<SignInBloc>(context).add(PostChange(post)),
                          ),
                          EmailTextField(controller: state.emailController, title: 'Business Email'),
                          PasswordTextField(controller: state.passwordController),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () =>
                                  BlocProvider.of<SignInBloc>(context).add(ForgetPassword(context: context)),
                              child: const Text('Forget password?'),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: smallPadding),
                            child: CustomButton(
                              primaryColor: true,
                              onPressed: () => BlocProvider.of<SignInBloc>(context).add(SignIn()),
                              title: 'Sign In',
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}
