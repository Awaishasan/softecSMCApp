import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/client_model.dart';
import '../../res/app_colors.dart';
import '../../view_models/client_controller.dart';
import 'widgets/add_sale_sheet.dart';
import 'widgets/client_balance_card.dart';
import 'widgets/client_sales_list.dart';
import 'widgets/client_stats_row.dart';
import '../../services/pdf_export_service.dart';
import '../../services/auth_services.dart';

class ClientDetailScreen extends StatefulWidget {
  final ClientModel client;
  const ClientDetailScreen({super.key, required this.client});

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  Set<String> selectedSaleIds = {};

  @override
  void initState() {
    super.initState();
    // Start streaming this client's sales
    Get.find<ClientController>().subscribeSales(widget.client.id);
  }

  void _toggleSelection(String id) {
    setState(() {
      if (selectedSaleIds.contains(id)) {
        selectedSaleIds.remove(id);
      } else {
        selectedSaleIds.add(id);
      }
    });
  }

  void _selectAll(List<String> allIds) {
    setState(() {
      selectedSaleIds.addAll(allIds);
    });
  }

  void _clearSelection() {
    setState(() {
      selectedSaleIds.clear();
    });
  }

  Future<void> _exportSelected(ClientController ctrl, {bool printDirectly = false}) async {
    final allSales = ctrl.salesFor(widget.client.id);
    final selectedSales = allSales.where((s) => selectedSaleIds.contains(s.id)).toList();
    if (selectedSales.isEmpty) return;

    final auth = AuthServices();
    final userName = auth.currentUser?.email?.split('@')[0] ?? 'Admin';

    await PdfExportService.exportPurchaseInvoices(
      sales: selectedSales,
      client: widget.client,
      userName: userName,
      printDirectly: printDirectly,
    );
    _clearSelection();
  }

  @override
  void dispose() {
    Get.find<ClientController>().unsubscribeSales(widget.client.id);
    super.dispose();
  }

  void _showAddSale(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      constraints: const BoxConstraints(maxWidth: 600),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => AddSaleSheet(
        clientId: widget.client.id,
        clientName: widget.client.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientController>(
      builder: (ctrl) {

        final client = ctrl.allClients.firstWhere(
          (c) => c.id == widget.client.id,
          orElse: () => widget.client,
        );

        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: CustomScrollView(
            slivers: [
              if (selectedSaleIds.isNotEmpty)
                SliverAppBar(
                  pinned: true,
                  backgroundColor: AppColors.primaryBlue,
                  leading: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _clearSelection,
                  ),
                  title: Text('${selectedSaleIds.length} Selected', style: const TextStyle(color: Colors.white, fontSize: 18)),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.select_all, color: Colors.white),
                      onPressed: () {
                        final allIds = ctrl.salesFor(client.id).map((e) => e.id).toList();
                        _selectAll(allIds);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.print, color: Colors.white),
                      onPressed: () => _exportSelected(ctrl, printDirectly: true),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () => _exportSelected(ctrl),
                    ),
                  ],
                )
              else
                _ClientAppBar(client: client),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      _ContactCard(client: client),
                      const SizedBox(height: 16),


                      ClientStatsRow(client: client),
                      const SizedBox(height: 16),


                      ClientBalanceCard(client: client, ctrl: ctrl),
                      const SizedBox(height: 24),


                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Purchase History',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textBlue)),
                          Text(
                            '${ctrl.salesFor(client.id).length} records',
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.grayText),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),


                      ClientSalesList(
                        clientId: client.id, 
                        ctrl: ctrl,
                        client: client,
                        selectedSaleIds: selectedSaleIds,
                        onSelect: _toggleSelection,
                        onLongPress: (id) {
                          if (selectedSaleIds.isEmpty) {
                            _toggleSelection(id);
                          }
                        },
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
            ),
          ),


          floatingActionButton: selectedSaleIds.isNotEmpty 
            ? null 
            : FloatingActionButton.extended(
            heroTag: null,
            onPressed: () => _showAddSale(context),
            backgroundColor: AppColors.primaryBlue,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text('Add Sale',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}



class _ClientAppBar extends StatelessWidget {
  final ClientModel client;
  const _ClientAppBar({required this.client});

  Color get _typeColor {
    switch (client.type) {
      case ClientType.vip:
        return Colors.amber;
      case ClientType.regular:
        return Colors.blue;
      case ClientType.walkIn:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppColors.primaryBlue,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.navyGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      client.name.isNotEmpty
                          ? client.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(client.name,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(client.phone,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.white70)),
                        const SizedBox(height: 8),
                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _typeColor.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _typeColor.withOpacity(0.5)),
                          ),
                          child: Text(
                            client.typeLabel,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _typeColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class _ContactCard extends StatelessWidget {
  final ClientModel client;
  const _ContactCard({required this.client});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          if (client.email.isNotEmpty)
            _ContactRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: client.email),
          if (client.email.isNotEmpty && client.address.isNotEmpty)
            const Divider(height: 16, color: AppColors.dividerGray),
          if (client.address.isNotEmpty)
            _ContactRow(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value: client.address),
          if (client.email.isNotEmpty || client.address.isNotEmpty)
            const Divider(height: 16, color: AppColors.dividerGray),
          _ContactRow(
            icon: Icons.calendar_today_outlined,
            label: 'Client since',
            value:
                '${client.joinDate.day}/${client.joinDate.month}/${client.joinDate.year}',
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ContactRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.iconBlue),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.grayText)),
            Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textBlue)),
          ],
        ),
      ],
    );
  }
}
