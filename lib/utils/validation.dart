String? emailValidation(String? value) {
  if (value == null || value.isEmpty) {
    return 'This field can\'t be empty';
  } else if (!(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value))) {
    return 'Enter Correct Email';
  } else {
    return null;
  }
}

String? passwordValidation(String? value) {
  if (value == null || value.isEmpty) {
    return 'This field can\'t be empty';
  } else if (value.length < 8) {
    return 'Password must be more than 7 characters';
  }
  //! Enable before Build
  //  else if (!(RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])[A-Za-z\d\W_]$').hasMatch(value))) {
  //   return 'Please Enter Strong Password';
  // }
  else {
    return null;
  }
}

String? confirmPasswordValidation(String? value, String passwordValue) {
  if (value == null || value.isEmpty) {
    return 'This field can\'t be empty';
  } else if (value.length < 8) {
    return 'Password must be more than 7 characters';
  } else if (value != passwordValue) {
    return 'Password not match';
  } else {
    return null;
  }
}

String? dropDownFormFieldValidatorForCompanyField(String? value) {
  if (value == null || value.isEmpty || value == 'Select company') {
    return 'Please Select your company';
  } else {
    return null;
  }
}

String? dropDownFormFieldValidatorForPostField(String? value) {
  if (value == null || value.isEmpty || value == 'Select Post') {
    return 'Please Select Post Of Employee';
  } else {
    return null;
  }
}

String? dropDownFormFieldValidatorBranchField(String? value) {
  if (value == null || value.isEmpty || value == 'Select Branch') {
    return 'Please Select Branch';
  } else {
    return null;
  }
}

String? simpleFieldValidation(String? value) {
  if (value == null || value.isEmpty) {
    return 'This field can\'t be empty';
  } else {
    return null;
  }
}

String? companyNameValidation(String? value, List companiesDocs) {
  if (value == null || value.isEmpty) {
    return 'This field can\'t be empty';
  } else if (companiesDocs.isNotEmpty) {
    for (var doc in companiesDocs) {
      if (doc.id == value) {
        return 'Company Name Already Existed';
      }
    }
  }
  return null;
}

String? companyBranchesValidation(String? value, List branches) {
  if (value == null || value.isEmpty) {
    return 'This field can\'t be empty';
  } else if (branches.isNotEmpty) {
    for (var branch in branches) {
      if (branch.id == value) {
        return 'Branch Name Already Existed';
      }
    }
  }
  return null;
}

String? phoneValidation(String? value) {
  if (value == null || value.isEmpty) {
    return 'This field can\'t be empty';
  } else if (value.length <= 4) {
    return 'This field can\'t be empty';
  } else if (value.length >= 4 && value.length < 14) {
    return 'Please Enter Correct Number';
  } else {
    return null;
  }
}
