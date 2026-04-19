import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../res/app_colors.dart';

// ── Shared legal screen ────────────────────────────────────────────────────────

class LegalScreen extends StatelessWidget {
  final String title;
  final List<_LegalSection> sections;

  const LegalScreen({
    super.key,
    required this.title,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Last updated banner
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  'Last updated: April 2026',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryBlue.withOpacity(0.8),
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...sections.map((s) => _SectionWidget(section: s)),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _SectionWidget extends StatelessWidget {
  final _LegalSection section;
  const _SectionWidget({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(section.heading,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textBlue)),
          const SizedBox(height: 8),
          Text(section.body,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.grayText,
                  height: 1.6)),
        ],
      ),
    );
  }
}

class _LegalSection {
  final String heading;
  final String body;
  const _LegalSection(this.heading, this.body);
}

// ── Privacy Policy ─────────────────────────────────────────────────────────────

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalScreen(
      title: 'Privacy Policy',
      sections: const [
        _LegalSection(
          'Introduction',
          'Cashflow Dashboard ("we", "our", or "the app") is committed to protecting your personal information. This Privacy Policy explains how we collect, use, and safeguard your data when you use our application.',
        ),
        _LegalSection(
          'Information We Collect',
          '• Account information: email address used to create your account via Firebase Authentication.\n'
              '• Financial data: transaction records, client details, sales, and payment history that you manually enter into the app.\n'
              '• Usage data: basic app usage analytics to improve performance (no personally identifiable information).',
        ),
        _LegalSection(
          'How We Use Your Data',
          '• To provide and maintain the core features of the app — balance tracking, transaction history, client management, and analytics.\n'
              '• To authenticate your identity securely via Firebase.\n'
              '• To generate PDF reports that you explicitly request and download.\n'
              'We do NOT sell, rent, or share your financial data with any third parties.',
        ),
        _LegalSection(
          'Data Storage & Security',
          'All your data is stored securely in Google Firebase Firestore, protected by Firebase Security Rules that ensure only you can access your own data. Data is encrypted in transit (TLS) and at rest. We recommend using a strong password and enabling device-level security.',
        ),
        _LegalSection(
          'Data Retention',
          'Your data remains stored as long as your account is active. You may delete your account and all associated data at any time by contacting support. Exported PDF files are generated locally on your device and are not stored on our servers.',
        ),
        _LegalSection(
          'Third-Party Services',
          'We use the following third-party services:\n'
              '• Google Firebase (Authentication & Firestore) — subject to Google\'s Privacy Policy.\n'
              '• No advertising SDKs or tracking libraries are included in this app.',
        ),
        _LegalSection(
          'Your Rights',
          'You have the right to:\n'
              '• Access all data you have entered into the app.\n'
              '• Export your transaction data as a PDF at any time.\n'
              '• Request deletion of your account and all associated data.\n'
              '• Correct any inaccurate information.',
        ),
        _LegalSection(
          'Contact Us',
          'If you have any questions about this Privacy Policy or how your data is handled, please contact us at: support@cashflowdashboard.app',
        ),
      ],
    );
  }
}

// ── Terms of Service ───────────────────────────────────────────────────────────

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalScreen(
      title: 'Terms of Service',
      sections: const [
        _LegalSection(
          'Acceptance of Terms',
          'By downloading, installing, or using Cashflow Dashboard, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the application.',
        ),
        _LegalSection(
          'Description of Service',
          'Cashflow Dashboard is a personal and small business financial tracking tool that allows you to:\n'
              '• Record income, expenses, and fund transfers.\n'
              '• Manage client profiles and track sales/payments.\n'
              '• View analytics and generate PDF reports.\n'
              'The app is intended for informational and record-keeping purposes only and does not constitute financial, accounting, or legal advice.',
        ),
        _LegalSection(
          'User Responsibilities',
          '• You are solely responsible for the accuracy of data you enter into the app.\n'
              '• You must not use the app for any illegal, fraudulent, or unauthorized purpose.\n'
              '• You are responsible for maintaining the confidentiality of your account credentials.\n'
              '• You must not attempt to reverse-engineer, modify, or distribute the application.',
        ),
        _LegalSection(
          'Accuracy of Financial Data',
          'Cashflow Dashboard is a record-keeping tool. The app does not verify, audit, or validate the financial data you enter. All calculations are based solely on the data you provide. We are not responsible for any financial decisions made based on information displayed in the app.',
        ),
        _LegalSection(
          'Intellectual Property',
          'All content, design, code, and features of Cashflow Dashboard are the intellectual property of the developers. You are granted a limited, non-exclusive, non-transferable license to use the app for personal or business record-keeping purposes.',
        ),
        _LegalSection(
          'Limitation of Liability',
          'To the maximum extent permitted by law, Cashflow Dashboard and its developers shall not be liable for any indirect, incidental, special, or consequential damages arising from your use of the app, including but not limited to loss of data, financial loss, or business interruption.',
        ),
        _LegalSection(
          'Service Availability',
          'We strive to keep the app available at all times but do not guarantee uninterrupted access. We reserve the right to modify, suspend, or discontinue any part of the service at any time with reasonable notice.',
        ),
        _LegalSection(
          'Changes to Terms',
          'We may update these Terms of Service from time to time. Continued use of the app after changes are posted constitutes your acceptance of the revised terms. The "Last updated" date at the top of this page will reflect the most recent revision.',
        ),
        _LegalSection(
          'Governing Law',
          'These Terms of Service shall be governed by and construed in accordance with applicable local laws. Any disputes arising from these terms shall be resolved through good-faith negotiation.',
        ),
        _LegalSection(
          'Contact',
          'For questions about these Terms of Service, please contact: support@cashflowdashboard.app',
        ),
      ],
    );
  }
}
