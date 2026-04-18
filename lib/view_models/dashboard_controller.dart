import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardController extends GetxController {
  int selectedIndex = 0;

  // Dashboard Data
  double totalBalance = 12847.50;
  double monthlySales = 8450.00;
  double monthlyExpenses = 2847.00;
  double pendingReceivables = 3200.00;
  double pendingPayables = 1450.00;

  // UI State
  bool isSearchVisible = false;
  final TextEditingController searchTextController = TextEditingController();

  void changeTabIndex(int index) {
    selectedIndex = index;
    update();
  }

  void toggleSearch() {
    isSearchVisible = !isSearchVisible;
    if (!isSearchVisible) {
      searchTextController.clear();
    }
    update();
  }

  String getUserDisplayName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      // Get name before @
      return user.email!.split('@')[0];
    }
    return 'User';
  }

  // Transaction List Data
  final transactions = [
    {
      'title': 'Invoice #204',
      'subtitle': 'Sale - Global Tech',
      'amount': '+2,500.00',
      'type': 'income',
      'time': '2 hours ago'
    },
    {
      'title': 'Office Supplies',
      'subtitle': 'Expense - Amazon',
      'amount': '-150.75',
      'type': 'expense',
      'time': '5 hours ago'
    },
    {
      'title': 'Rent Payment',
      'subtitle': 'Expense - City Real Estate',
      'amount': '-1,200.00',
      'type': 'expense',
      'time': '1 day ago'
    },
    {
      'title': 'Service Fee',
      'subtitle': 'Income - Client A',
      'amount': '+450.00',
      'type': 'income',
      'time': '2 days ago'
    },
  ];
}
