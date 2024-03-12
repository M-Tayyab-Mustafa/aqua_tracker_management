part of '_bloc.dart';

@immutable
abstract class SignInState {}

final class Splash extends SignInState {}

final class Disconnected extends SignInState {}

final class Loading extends SignInState {}

final class Error extends SignInState {}

final class NotVerified extends SignInState {}

final class Loaded extends SignInState {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> fpFormKey;
  final TextEditingController fpController;
  final List<Company> companies;
  final List<String>? branches;

  Loaded({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.fpFormKey,
    required this.fpController,
    required this.companies,
    required this.branches,
  });
}
