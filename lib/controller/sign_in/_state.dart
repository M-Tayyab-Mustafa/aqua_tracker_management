part of '_bloc.dart';

@immutable
abstract final class SignInState {}

final class Loading extends SignInState {}

final class Splashed extends SignInState {}

final class Disconnected extends SignInState {}

final class Error extends SignInState {}

final class Loaded extends SignInState {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final List<Company> companies;
  final List<String> branches;

  Loaded({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.companies,
    required this.branches,
  });
}
