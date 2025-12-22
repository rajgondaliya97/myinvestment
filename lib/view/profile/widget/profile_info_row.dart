import 'package:flutter/material.dart';

import '../../../res/app_widget/custom_app_text.dart';

class ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const ProfileInfoRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText.medium(
          label,
          color: Colors.grey[500],
          fontSize: 14,
        ),
        Flexible(
          child: AppText.medium(
            value,
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}