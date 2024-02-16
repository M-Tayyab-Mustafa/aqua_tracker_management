import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../validation.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.suffixIcon,
    this.prefixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.validator,
    this.textInputAction,
    this.onChanged,
    this.maxLength,
    this.filled,
    this.fillColor,
    this.enableInteractiveSelection,
    this.focusNode,
    this.maxLines = 1,
    this.counterText,
  });

  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final bool enabled;
  final ValueChanged? onChanged;
  final int? maxLength;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;
  final Widget? prefixIcon;
  final TextInputAction? textInputAction;
  final bool? filled;
  final Color? fillColor;
  final bool? enableInteractiveSelection;
  final FocusNode? focusNode;
  final int? maxLines;
  final String? counterText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(smallPadding),
      child: TextFormField(
        focusNode: focusNode,
        validator: validator,
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        enabled: enabled,
        onChanged: onChanged,
        maxLength: maxLength,
        maxLines: maxLines,
        enableInteractiveSelection: enableInteractiveSelection,
        decoration: InputDecoration(
          counterText: counterText,
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          label: FittedBox(child: Text(hintText)),
          border: _border,
          enabledBorder: _border,
          focusedBorder: _border,
          filled: filled,
          fillColor: fillColor,
          disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(smallBorderRadius), borderSide: const BorderSide(color: Colors.grey)),
        ),
      ),
    );
  }

  get _border => OutlineInputBorder(
        borderRadius: BorderRadius.circular(smallBorderRadius),
      );
}

class LocationTextField extends StatelessWidget {
  const LocationTextField({
    super.key,
    required this.latitudeController,
    required this.longitudeController,
    this.textInputAction = TextInputAction.next,
  });
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            focusNode: FocusNode(skipTraversal: true),
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(CupertinoIcons.arrow_left_right),
            hintText: 'Latitude',
            controller: latitudeController,
            keyboardType: TextInputType.number,
            validator: simpleFieldValidation,
          ),
        ),
        Expanded(
          child: CustomTextField(
            focusNode: FocusNode(skipTraversal: true),
            textInputAction: textInputAction,
            prefixIcon: const Icon(CupertinoIcons.arrow_up_down),
            hintText: 'Longitude',
            controller: longitudeController,
            keyboardType: TextInputType.number,
            validator: simpleFieldValidation,
          ),
        ),
      ],
    );
  }
}

class EmailTextField extends StatelessWidget {
  const EmailTextField({
    super.key,
    required this.controller,
    this.title = 'Email',
    this.filled,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
  });
  final TextEditingController controller;
  final String title;
  final bool? filled;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      focusNode: focusNode,
      textInputAction: textInputAction,
      prefixIcon: const Icon(Icons.email_outlined),
      hintText: title,
      controller: controller,
      validator: emailValidation,
      keyboardType: TextInputType.emailAddress,
      fillColor: Colors.white,
      filled: filled,
    );
  }
}

class PasswordTextField extends StatefulWidget {
  const PasswordTextField({super.key, required this.controller, this.filled});
  final TextEditingController controller;
  final bool? filled;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool obscurePassword = true;
  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      textInputAction: TextInputAction.done,
      prefixIcon: const Icon(Icons.lock_outline),
      hintText: 'Password',
      controller: widget.controller,
      obscureText: obscurePassword,
      keyboardType: TextInputType.visiblePassword,
      fillColor: Colors.white,
      filled: widget.filled,
      enableInteractiveSelection: false,
      validator: passwordValidation,
      suffixIcon: IconButton(
        onPressed: () => setState(() => obscurePassword = !obscurePassword),
        icon: Icon(
          obscurePassword ? CupertinoIcons.eye_slash_fill : CupertinoIcons.eye_fill,
        ),
      ),
    );
  }
}

class ConfirmPasswordTextField extends StatefulWidget {
  const ConfirmPasswordTextField({super.key, required this.controller, required this.passwordController, this.filled});
  final TextEditingController controller;
  final TextEditingController passwordController;
  final bool? filled;

  @override
  State<ConfirmPasswordTextField> createState() => _ConfirmPasswordTextFieldState();
}

class _ConfirmPasswordTextFieldState extends State<ConfirmPasswordTextField> {
  bool obscurePassword = true;
  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      textInputAction: TextInputAction.done,
      prefixIcon: const Icon(Icons.lock_outline),
      hintText: 'Confirm Password',
      controller: widget.controller,
      obscureText: obscurePassword,
      fillColor: Colors.white,
      filled: widget.filled,
      keyboardType: TextInputType.visiblePassword,
      validator: (value) => confirmPasswordValidation(value, widget.passwordController.text),
      suffixIcon: IconButton(
        onPressed: () => setState(() => obscurePassword = !obscurePassword),
        icon: Icon(
          obscurePassword ? CupertinoIcons.eye_slash_fill : CupertinoIcons.eye_fill,
        ),
      ),
    );
  }
}

class ContactTextField extends StatelessWidget {
  const ContactTextField({super.key, required this.hintText, required this.controller, this.filled});
  final String hintText;
  final TextEditingController controller;
  final bool? filled;
  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      maxLength: 14,
      counterText: '',
      prefixIcon: const Icon(Icons.phone_outlined),
      hintText: hintText,
      fillColor: Colors.white,
      filled: filled,
      controller: controller,
      validator: phoneValidation,
      onChanged: (value) {
        if (value.length <= 4) {
          controller.text = '+92 ';
        }
      },
    );
  }
}

class NameTextField extends StatelessWidget {
  const NameTextField({super.key, required this.controller, this.hintText = 'Name'});
  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      textInputAction: TextInputAction.next,
      prefixIcon: const Icon(Icons.person),
      hintText: hintText,
      validator: simpleFieldValidation,
      keyboardType: TextInputType.name,
      controller: controller,
    );
  }
}
