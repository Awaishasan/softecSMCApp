import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../res/app_colors.dart';

class ActivityItem extends StatelessWidget {
  final String transactionId;
  final String title;
  final String subtitle;
  final String amount;
  final String time;
  final String type;
  final VoidCallback? onDelete;

  const ActivityItem({
    super.key,
    required this.transactionId,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.time,
    required this.type,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = type == 'income';
    final accentColor = isIncome ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.dividerGray.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          // ── Type icon ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // ── Title + subtitle ───────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlue,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.grayText),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // ── Amount + time ──────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isIncome ? Colors.green : Colors.redAccent,
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.grayText),
              ),
            ],
          ),
          const SizedBox(width: 4),

          // ── Three-dot menu ─────────────────────────────────────────
          _TransactionMenu(
            transactionId: transactionId,
            title: title,
            amount: amount,
            onDelete: onDelete,
          ),
        ],
      ),
    );
  }
}

// ── Popup menu widget ──────────────────────────────────────────────────────────

class _TransactionMenu extends StatelessWidget {
  final String transactionId;
  final String title;
  final String amount;
  final VoidCallback? onDelete;

  const _TransactionMenu({
    required this.transactionId,
    required this.title,
    required this.amount,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_TxAction>(
      icon: const Icon(Icons.more_vert,
          color: AppColors.grayText, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white,
      elevation: 4,
      onSelected: (action) => _handleAction(context, action),
      itemBuilder: (_) => [
        _menuItem(
          value: _TxAction.copyId,
          icon: Icons.copy_rounded,
          label: 'Copy Transaction ID',
          color: AppColors.textBlue,
        ),
        _menuItem(
          value: _TxAction.copyAmount,
          icon: Icons.attach_money_rounded,
          label: 'Copy Amount',
          color: AppColors.textBlue,
        ),
        const PopupMenuDivider(),
        _menuItem(
          value: _TxAction.viewDetails,
          icon: Icons.info_outline_rounded,
          label: 'View Details',
          color: AppColors.primaryBlue,
        ),
        const PopupMenuDivider(),
        _menuItem(
          value: _TxAction.delete,
          icon: Icons.delete_outline_rounded,
          label: 'Delete',
          color: Colors.redAccent,
        ),
      ],
    );
  }

  PopupMenuItem<_TxAction> _menuItem({
    required _TxAction value,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return PopupMenuItem<_TxAction>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, _TxAction action) {
    switch (action) {
      case _TxAction.copyId:
        Clipboard.setData(ClipboardData(text: transactionId));
        _snack('Transaction ID copied');
        break;

      case _TxAction.copyAmount:
        Clipboard.setData(ClipboardData(text: amount));
        _snack('Amount copied');
        break;

      case _TxAction.viewDetails:
        _showDetails(context);
        break;

      case _TxAction.delete:
        _confirmDelete(context);
        break;
    }
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      constraints: const BoxConstraints(maxWidth: 600),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Transaction Details',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlue)),
            const SizedBox(height: 16),
            _detailRow('Title', title),
            _detailRow('Amount', amount),
            _detailRow('Transaction ID', transactionId),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.grayText)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlue)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Transaction',
            style: TextStyle(color: AppColors.textBlue)),
        content: const Text(
            'Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.grayText)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              onDelete?.call();
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) {
    Get.snackbar(
      '',
      msg,
      titleText: const SizedBox.shrink(),
      messageText: Text(msg,
          style: const TextStyle(color: Colors.white, fontSize: 13)),
      backgroundColor: AppColors.primaryBlue,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
    );
  }
}

enum _TxAction { copyId, copyAmount, viewDetails, delete }
