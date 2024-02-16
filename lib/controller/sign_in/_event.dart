part of '_bloc.dart';

@immutable
abstract final class SignInEvent {}

final class ForgetPassword extends SignInEvent {
  final BuildContext context;

  ForgetPassword({required this.context});
}

final class CompanyChange extends SignInEvent {
  final String company;
  CompanyChange(this.company);
}

final class PostChange extends SignInEvent {
  final String post;
  PostChange(this.post);
}

final class BranchChange extends SignInEvent {
  final String branch;
  BranchChange(this.branch);
}

final class SignIn extends SignInEvent {}
