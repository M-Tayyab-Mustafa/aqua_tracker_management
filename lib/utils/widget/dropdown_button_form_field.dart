import 'package:flutter/material.dart';
import '../constants.dart';

class CustomDropdownButtonFormField extends StatelessWidget {
  const CustomDropdownButtonFormField({
    super.key,
    required this.items,
    required this.onChanged,
    this.selected,
    required this.defaultHintValue,
    required this.dropDownFormFieldValidator,
    this.filled,
    this.onTab,
  });

  final String defaultHintValue;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged onChanged;
  final String? selected;
  final String? Function(String? value) dropDownFormFieldValidator;
  final bool? filled;
  final Function()? onTab;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(smallPadding),
      child: DropdownButtonFormField(
        hint: DropdownMenuItem(
          value: defaultHintValue,
          child: Text(defaultHintValue, overflow: TextOverflow.ellipsis),
        ),
        onTap: onTab,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: filled,
          border: _border,
          enabledBorder: _border,
          focusedBorder: _border,
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(smallBorderRadius),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
        validator: dropDownFormFieldValidator,
        items: items,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: onChanged,
        value: selected,
      ),
    );
  }

  get _border => OutlineInputBorder(borderRadius: BorderRadius.circular(smallBorderRadius));
}
