import 'package:flutter/material.dart';
import '../res/app_colors.dart';
import '../views/cash_flow/send_money_sheet.dart';
import 'quick_action_button.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  void _showSheet(BuildContext context, Widget sheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      constraints: const BoxConstraints(maxWidth: 600),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => sheet,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        
        return Center(
          child: Wrap(
            spacing: isWide ? 40 : 20,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              QuickActionButton(
                label: 'Send',
                icon: Icons.arrow_upward_rounded,
                color: Colors.blue,
                onTap: () => _showSheet(context, SendMoneySheet()),
              ),
              QuickActionButton(
                label: 'Receive',
                icon: Icons.arrow_downward_rounded,
                gradient: const LinearGradient(
                    colors: [Colors.tealAccent, Colors.green]),
                onTap: () => _showSheet(context, ReceiveMoneySheet()),
              ),
              QuickActionButton(
                label: 'Add Money',
                icon: Icons.add_rounded,
                gradient: AppColors.orangeGradient,
                onTap: () => _showSheet(context, AddMoneySheet()),
              ),
            ],
          ),
        );
      },
    );
  }
}
