#Images 
Onbaording Screen 
<img width="830" height="894" alt="WhatsApp Image 2026-06-21 at 12 11 58 PM" src="https://github.com/user-attachments/assets/2a1e2f0d-bafe-485e-8cc7-e70fdedb10ed" />
Main Screen 
<img width="830" height="894" alt="WhatsApp Image 2026-06-21 at 12 11 59 PM (2)" src="https://github.com/user-attachments/assets/9a75162e-34b2-431a-b567-891839f3c746" />
Transaction View 
<img width="830" height="894" alt="WhatsApp Image 2026-06-21 at 12 11 59 PM" src="https://github.com/user-attachments/assets/a19f4d82-f5f1-4beb-ba9c-97b0f0375f20" />
Analytics 
<img width="830" height="894" alt="WhatsApp Image 2026-06-21 at 12 11 59 PM (1)" src="https://github.com/user-attachments/assets/09d5a733-2afc-4109-9640-6c434714dad4" />
Inout form feilds
<img width="830" height="894" alt="WhatsApp Image 2026-06-21 at 12 12 00 PM" src="https://github.com/user-attachments/assets/d36a96e4-0e79-4998-bb0f-8f5983c66e61" />
User profile View 
<img width="806" height="894" alt="WhatsApp Image 2026-06-21 at 12 12 00 PM (1)" src="https://github.com/user-attachments/assets/f5efe702-c8e1-44ba-a58f-41aeb73d7f18" />


# Small Business Cash Flow Dashboard

A lightweight Flutter mobile application that helps small business owners track their sales, expenses, receivables, and payables in one place — giving a real-time view of their cash position and enabling faster financial decisions.

---

## Problem Statement

Small businesses often struggle to track incoming payments, outgoing expenses, and their real cash position in one place. Manual spreadsheet tracking is time-consuming, error-prone, and makes it hard to spot cash flow problems before they become critical.

---

## Solution

A clean, intuitive Flutter dashboard that consolidates all financial data in real time — powered by Firebase — so business owners can see exactly where their money is at any given moment.

---

## Features

- Track all incoming payments and revenue in one view
- Log and categorize outgoing costs instantly
- See money owed to you and when it is due
- Know what bills are outstanding before they are overdue
- Real-time net cash position calculated automatically
- Firebase real-time sync — data updates instantly across devices
- Secure login for each business owner via Firebase Authentication
- Reliable, scalable cloud storage through Cloud Firestore

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (Dart) |
| Backend | Firebase |
| Database | Cloud Firestore |
| Authentication | Firebase Auth |
| State Management | Provider / GetX |
| IDE | Android Studio / VS Code |

---

## Screenshots

> Screenshots coming soon

<!--
Once you have screenshots, replace this section:

| Dashboard | Sales | Expenses |
|-----------|-------|----------|
| ![Dashboard](assets/screenshots/dashboard.png) | ![Sales](assets/screenshots/sales.png) | ![Expenses](assets/screenshots/expenses.png) |

| Receivables | Payables | Cash Summary |
|-------------|----------|--------------|
| ![Receivables](assets/screenshots/receivables.png) | ![Payables](assets/screenshots/payables.png) | ![Summary](assets/screenshots/summary.png) |
-->

---

## Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── models/
│   ├── sale_model.dart
│   ├── expense_model.dart
│   ├── receivable_model.dart
│   └── payable_model.dart
├── screens/
│   ├── dashboard_screen.dart
│   ├── sales_screen.dart
│   ├── expenses_screen.dart
│   ├── receivables_screen.dart
│   ├── payables_screen.dart
│   └── auth/
│       ├── login_screen.dart
│       └── register_screen.dart
├── services/
│   ├── firebase_service.dart
│   └── auth_service.dart
└── widgets/
    ├── summary_card.dart
    └── transaction_tile.dart
```

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart `>=3.0.0`
- A Firebase project (free tier works fine)
- Android Studio or VS Code

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/Awaishasan/E_billing_System.git
   cd E_billing_System
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Set up Firebase
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Add an Android/iOS app and download `google-services.json` or `GoogleService-Info.plist`
   - Place the file in `android/app/` or `ios/Runner/`
   - Enable Firestore and Firebase Authentication (Email/Password)

4. Run the app
   ```bash
   flutter run
   ```

---

## Expected Impact

- Business owners get a single real-time view of their financial health
- Eliminates manual spreadsheet tracking and saves hours per week
- Helps avoid cash flow blind spots by surfacing pending receivables and payables
- Enables faster, more confident financial decisions without needing an accountant

---

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

---

## License

This project is open source and available under the [MIT License](LICENSE).

---

## Author

**Awais Hassan**
Flutter & Mobile App Developer
- Email: muhammadawaishassan1@gmail.com
- LinkedIn: [awais-hassan-368833302](https://www.linkedin.com/in/awais-hassan-368833302/)
- GitHub: [Awaishasan](https://github.com/Awaishasan)
