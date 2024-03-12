import 'package:flutter/material.dart';

import '../constants.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      content: SizedBox(
        height: screenSize.height * 0.3,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
