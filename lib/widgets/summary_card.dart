import 'package:flutter/material.dart';
import '../res/app_colors.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color iconColor;
  final double progress; // 0.0 – 1.0, computed dynamically
  final String progressText;

  const SummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.progress,
    required this.progressText,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (progress.clamp(0.0, 1.0) * 100).toInt();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    final double padding = isSmallScreen ? 8.0 : 10.0;
    final double iconSize = isSmallScreen ? 16.0 : 20.0;
    final double titleFontSize = isSmallScreen ? 11.0 : 13.0;
    final double amountFontSize = isSmallScreen ? 13.0 : 15.0;
    final double progressTextFontSize = isSmallScreen ? 9.0 : 11.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: iconSize),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        amount,
                        style: TextStyle(
                          fontSize: amountFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.trending_up,
                            size: isSmallScreen ? 11 : 13,
                            color: iconColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            progressText,
                            style: TextStyle(
                              fontSize: progressTextFontSize,
                              color: iconColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontSize: titleFontSize,
                color: AppColors.grayText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ── Animated progress bar ──────────────────────────────────
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                minHeight: 6,
              ),
            ),
          ),

          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$pct%',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.grayText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
