import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/client_model.dart';
import '../../res/app_colors.dart';
import '../../view_models/client_controller.dart';
import 'widgets/add_client_sheet.dart';
import 'widgets/client_card.dart';
import 'client_detail_screen.dart';
import 'paid_clients_screen.dart';

class ClientsTab extends StatelessWidget {
  const ClientsTab({super.key});

  void _showAddClient(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const AddClientSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientController>(
      builder: (ctrl) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddClient(context),
            backgroundColor: AppColors.primaryBlue,
            child: const Icon(Icons.person_add_rounded, color: Colors.white),
          ),
          body: ctrl.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryBlue))
              : CustomScrollView(
                  slivers: [

                    SliverToBoxAdapter(
                      child: _ClientsHeader(ctrl: ctrl),
                    ),


                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: _SearchBar(ctrl: ctrl),
                      ),
                    ),


                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _FilterChips(ctrl: ctrl),
                      ),
                    ),


                    ctrl.displayedClients.isEmpty
                        ? SliverFillRemaining(
                            child: _EmptyState(
                              hasSearch: ctrl.searchQuery.isNotEmpty,
                            ),
                          )
                        : SliverPadding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (_, i) {
                                  final client = ctrl.displayedClients[i];
                                  return ClientCard(
                                    client: client,
                                    onTap: () => Get.to(
                                      () => ClientDetailScreen(
                                          client: client),
                                      transition: Transition.rightToLeft,
                                    ),
                                    onDelete: () =>
                                        _confirmDelete(context, ctrl,
                                            client.id, client.name),
                                  );
                                },
                                childCount: ctrl.displayedClients.length,
                              ),
                            ),
                          ),
                  ],
                ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, ClientController ctrl,
      String clientId, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Client',
            style: TextStyle(color: AppColors.textBlue)),
        content: Text('Remove "$name" and all their data?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.grayText))),
          TextButton(
            onPressed: () {
              Get.back();
              ctrl.deleteClient(clientId);
            },
            child: const Text('Remove',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}



class _ClientsHeader extends StatelessWidget {
  final ClientController ctrl;
  const _ClientsHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.navyGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Clients',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text('${ctrl.allClients.length} total customers',
              style: const TextStyle(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 16),
          Row(
            children: [
              _HeaderStat(
                label: 'Total Receivable',
                value: 'Rs ${ctrl.totalOutstanding.toStringAsFixed(0)}',
                icon: Icons.account_balance_wallet_outlined,
                color: Colors.orangeAccent,
              ),
              const SizedBox(width: 8),
              _HeaderStat(
                label: 'Defaulters',
                value: '${ctrl.defaulters.length}',
                icon: Icons.warning_amber_rounded,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 8),
              // ── Payments Received — tappable ──────────────────────
              _HeaderStat(
                label: 'Payments',
                value: 'Rs ${ctrl.totalClientPayments.toStringAsFixed(0)}',
                icon: Icons.check_circle_outline_rounded,
                color: Colors.greenAccent,
                onTap: () => Get.to(
                  () => const PaidClientsScreen(),
                  transition: Transition.rightToLeft,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _HeaderStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: onTap != null
                ? Border.all(color: Colors.white.withOpacity(0.2))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 16),
                  if (onTap != null) ...[
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white38, size: 10),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  overflow: TextOverflow.ellipsis),
              Text(label,
                  style: const TextStyle(
                      fontSize: 9, color: Colors.white60),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}


class _SearchBar extends StatelessWidget {
  final ClientController ctrl;
  const _SearchBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: ctrl.setSearch,
      decoration: InputDecoration(
        hintText: 'Search by name or phone...',
        hintStyle: const TextStyle(color: AppColors.grayText, fontSize: 14),
        prefixIcon: const Icon(Icons.search_rounded,
            color: AppColors.grayText, size: 20),
        suffixIcon: ctrl.searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.grayText, size: 18),
                onPressed: () => ctrl.setSearch(''),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
      ),
    );
  }
}



class _FilterChips extends StatelessWidget {
  final ClientController ctrl;
  const _FilterChips({required this.ctrl});

  static const _filters = [
    (ClientFilter.all, 'All'),
    (ClientFilter.hasBalance, 'Has Balance'),
    (ClientFilter.regular, 'Regular'),
    (ClientFilter.vip, 'VIP'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((entry) {
          final (filter, label) = entry;
          final selected = ctrl.activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => ctrl.setFilter(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryBlue
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? AppColors.primaryBlue
                        : AppColors.dividerGray,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color:
                        selected ? Colors.white : AppColors.grayText,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}



class _EmptyState extends StatelessWidget {
  final bool hasSearch;
  const _EmptyState({required this.hasSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasSearch
                ? Icons.search_off_rounded
                : Icons.people_outline_rounded,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            hasSearch ? 'No clients found' : 'No clients yet',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.grayText),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearch
                ? 'Try a different name or phone'
                : 'Tap + to add your first client',
            style: const TextStyle(
                fontSize: 13, color: AppColors.grayText),
          ),
        ],
      ),
    );
  }
}
