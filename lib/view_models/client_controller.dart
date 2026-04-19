import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/client_model.dart';
import '../models/client_sale_model.dart';
import '../services/client_service.dart';

// Filter options for client list
enum ClientFilter { all, hasBalance, regular, vip }

class ClientController extends GetxController {
  final ClientService _service = ClientService();

  // ── State ──────────────────────────────────────────────────────────────────
  List<ClientModel> allClients = [];
  Map<String, List<ClientSaleModel>> salesCache = {}; // clientId → sales
  Map<String, StreamSubscription> _saleSubs = {};

  // Paid sales across all clients (for home card + paid screen)
  List<Map<String, dynamic>> allPaidSales = [];
  StreamSubscription? _paidSalesSub;

  String searchQuery = '';
  ClientFilter activeFilter = ClientFilter.all;
  bool isLoading = true;
  bool isSubmitting = false;

  StreamSubscription? _clientSub;

  // ── Computed ───────────────────────────────────────────────────────────────

  List<ClientModel> get displayedClients {
    var list = allClients;

    // type filter
    switch (activeFilter) {
      case ClientFilter.hasBalance:
        list = list.where((c) => c.hasBalance).toList();
        break;
      case ClientFilter.regular:
        list = list.where((c) => c.type == ClientType.regular).toList();
        break;
      case ClientFilter.vip:
        list = list.where((c) => c.type == ClientType.vip).toList();
        break;
      case ClientFilter.all:
        break;
    }

    // search
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              c.phone.contains(q))
          .toList();
    }

    return list;
  }

  // Top 3 clients by total spend
  List<ClientModel> get topClients {
    final sorted = [...allClients]
      ..sort((a, b) => b.totalSpend.compareTo(a.totalSpend));
    return sorted.take(3).toList();
  }

  // Clients with outstanding balance (defaulters)
  List<ClientModel> get defaulters =>
      allClients.where((c) => c.hasBalance).toList();

  double get totalOutstanding =>
      allClients.fold(0, (s, c) => s + c.outstandingBalance);

  /// Total amount paid by clients (fully paid sales only)
  double get totalClientPayments =>
      allPaidSales.fold(0.0, (s, sale) =>
          s + ((sale['paidAmount'] as num?)?.toDouble() ?? 0));

  // ── Actions ────────────────────────────────────────────────────────────────

  void setSearch(String q) {
    searchQuery = q;
    update();
  }

  void setFilter(ClientFilter f) {
    activeFilter = f;
    update();
  }

  Future<void> addClient({
    required String name,
    required String phone,
    required String email,
    required String address,
    required ClientType type,
  }) async {
    isSubmitting = true;
    update();
    try {
      await _service.addClient(ClientModel(
        id: '',
        name: name,
        phone: phone,
        email: email,
        address: address,
        type: type,
        joinDate: DateTime.now(),
        userId: '',
      ));
      _toast('Client added');
    } catch (_) {
      _toast('Failed to add client', isError: true);
    }
    isSubmitting = false;
    update();
  }

  Future<void> deleteClient(String clientId) async {
    try {
      await _service.deleteClient(clientId);
      _toast('Client removed');
    } catch (_) {
      _toast('Failed to delete client', isError: true);
    }
  }

  Future<void> addSale({
    required String clientId,
    required String itemDescription,
    required double totalAmount,
    required double paidAmount,
    required SalePaymentStatus status,
    DateTime? dueDate,
  }) async {
    isSubmitting = true;
    update();
    try {
      await _service.addSale(ClientSaleModel(
        id: '',
        clientId: clientId,
        itemDescription: itemDescription,
        totalAmount: totalAmount,
        paidAmount: paidAmount,
        status: status,
        date: DateTime.now(),
        dueDate: dueDate,
        userId: '',
      ));
      _toast('Sale recorded');
    } catch (_) {
      _toast('Failed to record sale', isError: true);
    }
    isSubmitting = false;
    update();
  }

  Future<void> recordPayment({
    required String clientId,
    required String saleId,
    required double paymentAmount,
    required double currentPaid,
    required double totalAmount,
  }) async {
    isSubmitting = true;
    update();
    try {
      await _service.recordPayment(
        clientId: clientId,
        saleId: saleId,
        paymentAmount: paymentAmount,
        currentPaid: currentPaid,
        totalAmount: totalAmount,
      );
      _toast('Payment recorded');
    } catch (_) {
      _toast('Failed to record payment', isError: true);
    }
    isSubmitting = false;
    update();
  }

  // Subscribe to a specific client's sales (called from detail screen)
  void subscribeSales(String clientId) {
    if (_saleSubs.containsKey(clientId)) return;
    _saleSubs[clientId] =
        _service.salesStream(clientId).listen((sales) {
      salesCache[clientId] = sales;
      update();
    });
  }

  void unsubscribeSales(String clientId) {
    _saleSubs[clientId]?.cancel();
    _saleSubs.remove(clientId);
  }

  List<ClientSaleModel> salesFor(String clientId) =>
      salesCache[clientId] ?? [];

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _clientSub = _service.clientsStream().listen((list) {
      allClients = list;
      isLoading = false;
      update();
    });
    _paidSalesSub = _service.allPaidSalesStream().listen((list) {
      allPaidSales = list;
      update();
    });
  }

  @override
  void onClose() {
    _clientSub?.cancel();
    _paidSalesSub?.cancel();
    for (final sub in _saleSubs.values) {
      sub.cancel();
    }
    super.onClose();
  }

  void _toast(String msg, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      textColor: Colors.white,
    );
  }
}
