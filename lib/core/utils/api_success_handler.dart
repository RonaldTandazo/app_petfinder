import 'package:flutter/material.dart';
import 'package:app_petfinder/widgets/app_snackbar.dart';

class ApiSuccessHandler {
  static void handle(BuildContext context, { required String title, String? description }) {
    AppSnackBar.show(
      context,
      title: title,
      description: description,
      type: SnackBarType.success,
    );
  }
}