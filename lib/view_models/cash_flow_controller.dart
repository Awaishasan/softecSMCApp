import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/transaction_model.dart';
import '../services/cash_flow_service.dart';


enum DateRangeFilter { last7, last30, custom }

class CashFlowController extends GetxController {
  final CashFlowService _service = CashFlowService();

  double totalBalance = 0;
  double monthlySales = 0;
  double monthlyExpenses = 0;
  double pendingReceivables = 0;
  double pendingPayables = 0;


  List<TransactionModel> transactions = []; // recent 10 for home
  List<TransactionModel> allTransactions = []; // full list for analytics


  int typeFilter = 0; // 0=All 1=Income 2=Expense
  DateRangeFilter dateFilter = DateRangeFilter.last7;
  DateTime? customFrom;
  DateTime? customTo;
  String searchQuery = '';

  // ── Loading ────────────────────────────────────────────────────────────────
  bool isSummaryLoading = true;
  bool isSubmitting = false;

  StreamSubscription? _txSub;
  StreamSubscription? _allTxSub;


  DateTime get _windowStart {
    final now = DateTime.now();
    switch (dateFilter) {
      case DateRangeFilter.last7:
        return DateTime(now.year, now.month, now.day - 6);
      case DateRangeFilter.last30:
        return DateTime(now.year, now.month, now.day - 29);
      case DateRangeFilter.custom:
        return customFrom ?? DateTime(now.year, now.month, now.day - 6);
    }
  }

  DateTime get _windowEnd {
    final now = DateTime.now();
    if (dateFilter == DateRangeFilter.custom && customTo != null) {
      return DateTime(
          customTo!.year, customTo!.month, customTo!.day, 23, 59, 59);
    }
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }


  List<TransactionModel> get displayedTransactions {
    return allTransactions.where((t) {
      // date window
      if (t.createdAt.isBefore(_windowStart) ||
          t.createdAt.isAfter(_windowEnd)) return false;
      // type filter
      if (typeFilter == 1 && t.type != TransactionType.income) return false;
      if (typeFilter == 2 &&
          t.type != TransactionType.expense &&
          t.type != TransactionType.transfer) return false;
      // search
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        return t.title.toLowerCase().contains(q) ||
            t.subtitle.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  // ── Chart data: bars for the selected window ───────────────────────────────
  // Returns a list of (label, income, expense) per day/week bucket
  List<ChartBucket> get chartBuckets {
    final start = _windowStart;
    final end = _windowEnd;
    final days = end.difference(start).inDays + 1;

    if (days <= 31) {
      return List.generate(days, (i) {
        final day = start.add(Duration(days: i));
        final inc = _sumForDay(day, TransactionType.income);
        final exp = _sumForDay(day, TransactionType.expense) +
            _sumForDay(day, TransactionType.transfer);
        const names = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
        return ChartBucket(
            label: names[day.weekday % 7], income: inc, expense: exp);
      });
    } else {
      return [];
    }
  }

  double _sumForDay(DateTime day, TransactionType type) {
    return allTransactions
        .where((t) =>
            t.type == type &&
            t.createdAt.year == day.year &&
            t.createdAt.month == day.month &&
            t.createdAt.day == day.day)
        .fold(0.0, (s, t) => s + t.amount);
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  void setTypeFilter(int index) {
    typeFilter = index;
    update();
  }

  void setDateFilter(DateRangeFilter f) {
    dateFilter = f;
    update();
  }

  void setCustomDateRange(DateTime from, DateTime to) {
    customFrom = from;
    customTo = to;
    dateFilter = DateRangeFilter.custom;
    update();
  }

  void setSearchQuery(String q) {
    searchQuery = q;
    update();
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadSummary();
    _listenTransactions();
    _listenAllTransactions();
  }

  @override
  void onClose() {
    _txSub?.cancel();
    _allTxSub?.cancel();
    super.onClose();
  }

  Future<void> _loadSummary() async {
    isSummaryLoading = true;
    update();
    try {
      final data = await _service.fetchSummary();
      totalBalance = (data['totalBalance'] as num?)?.toDouble() ?? 0;
      monthlySales = (data['monthlySales'] as num?)?.toDouble() ?? 0;
      monthlyExpenses = (data['monthlyExpenses'] as num?)?.toDouble() ?? 0;
      pendingReceivables =
          (data['pendingReceivables'] as num?)?.toDouble() ?? 0;
      pendingPayables = (data['pendingPayables'] as num?)?.toDouble() ?? 0;
    } catch (_) {
      _toast('Failed to load summary', isError: true);
    }
    isSummaryLoading = false;
    update();
  }

  void _listenTransactions() {
    _txSub = _service.transactionsStream().listen((list) {
      transactions = list;
      update();
    });
  }

  void _listenAllTransactions() {
    _allTxSub = _service.allTransactionsStream().listen((list) {
      allTransactions = list;
      update();
    });
  }

  // ── Transaction operations ─────────────────────────────────────────────────
  Future<void> recordSend({
    required String title,
    required String subtitle,
    required double amount,
  }) async {
    await _submit(
        title: title,
        subtitle: subtitle,
        amount: amount,
        type: TransactionType.expense,
        successMsg: 'Payment sent successfully');
  }

  Future<void> recordReceive({
    required String title,
    required String subtitle,
    required double amount,
  }) async {
    await _submit(
        title: title,
        subtitle: subtitle,
        amount: amount,
        type: TransactionType.income,
        successMsg: 'Payment received successfully');
  }

  Future<void> addMoney({
    required String source,
    required double amount,
  }) async {
    await _submit(
        title: 'Funds Added',
        subtitle: source,
        amount: amount,
        type: TransactionType.transfer,
        successMsg: 'Money added successfully');
  }

  Future<void> _submit({
    required String title,
    required String subtitle,
    required double amount,
    required TransactionType type,
    required String successMsg,
  }) async {
    isSubmitting = true;
    update();
    try {
      await _service.addTransaction(
          title: title, subtitle: subtitle, amount: amount, type: type);
      await _loadSummary();
      _toast(successMsg);
    } catch (_) {
      _toast('Operation failed. Try again.', isError: true);
    }
    isSubmitting = false;
    update();
  }

  void _toast(String msg, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      textColor: Colors.white,
    );
  }
}

// Simple data holder for chart buckets
class ChartBucket {
  final String label;
  final double income;
  final double expense;
  const ChartBucket(
      {required this.label, required this.income, required this.expense});
}
