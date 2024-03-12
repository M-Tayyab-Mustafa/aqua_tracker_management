part of '_bloc.dart';

@immutable
abstract class SignInEvent {}

final class OnCompanyChange extends SignInEvent {
  final String company;
  OnCompanyChange(this.company);
}

final class OnPostChange extends SignInEvent {
  final String post;
  OnPostChange(this.post);
}

final class OnBranchChange extends SignInEvent {
  final String branch;
  OnBranchChange(this.branch);
}

final class SignIn extends SignInEvent {}

final class ForgetPassword extends SignInEvent {}
