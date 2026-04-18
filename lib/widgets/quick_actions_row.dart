import 'package:flutter/material.dart';
import '../res/app_colors.dart';
import 'quick_action_button.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        QuickActionButton(
          label: 'Send',
          icon: Icons.unfold_less_rounded,
          color: Colors.blue,
          onTap: () {},
        ),
        QuickActionButton(
          label: 'Receive',
          icon: Icons.unfold_more_rounded,
          gradient: const LinearGradient(
              colors: [Colors.tealAccent, Colors.green]),
          onTap: () {},
        ),
        QuickActionButton(
          label: 'Add Money',
          icon: Icons.add_rounded,
          gradient: AppColors.orangeGradient,
          onTap: () {},
        ),
      ],
    );
  }
}
