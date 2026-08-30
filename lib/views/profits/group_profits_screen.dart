import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/common/app_shimmer.dart';
import '../../core/common/common_error_widget.dart';
import '../../core/localization/app_localizations.dart';
import '../../viewmodel/group_profit_viewmodel.dart';
import 'add_group_profit_dialog.dart';

class GroupProfitsScreen extends StatefulWidget {
  const GroupProfitsScreen({super.key});

  @override
  State<GroupProfitsScreen> createState() => _GroupProfitsScreenState();
}

class _GroupProfitsScreenState extends State<GroupProfitsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProfitViewModel>().fetchGroupProfits();
    });
  }

  void _openAddProfitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AddGroupProfitDialog(),
    ).then((val) {
      if (val == true && context.mounted) {
        context.read<GroupProfitViewModel>().fetchGroupProfits();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMl = l10n.locale.languageCode == 'ml';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMl ? 'ഗ്രൂപ്പ് ലാഭങ്ങൾ' : 'Group Profits',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => _openAddProfitDialog(context),
            tooltip: isMl ? 'ലാഭം രേഖപ്പെടുത്തുക' : 'Record Profit',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF047857),
        foregroundColor: Colors.white,
        onPressed: () => _openAddProfitDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          isMl ? 'ലാഭം ലഭിച്ചു' : 'Add Profit',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<GroupProfitViewModel>(
        builder: (context, vm, _) {
          if (vm.loadState.isLoading && vm.groupProfits.isEmpty) {
            return const MemberListShimmerLoading();
          }

          if (vm.loadState.hasError && vm.groupProfits.isEmpty) {
            return CommonErrorWidget(
              message: vm.loadState.message ?? (isMl ? 'ഡാറ്റ ലോഡ് ചെയ്യാൻ കഴിഞ്ഞില്ല' : 'Failed to load group profits'),
              onRetry: () => vm.fetchGroupProfits(),
            );
          }

          final profits = vm.groupProfits;
          final totalProfitAmount = profits.fold<double>(0, (sum, item) => sum + item.amount);

          return RefreshIndicator(
            onRefresh: () => vm.fetchGroupProfits(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Total Summary Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF047857), Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF047857).withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.trending_up_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMl ? 'മൊത്തം ഗ്രൂപ്പ് ലാഭങ്ങൾ' : 'Total Group Profits',
                              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${totalProfitAmount.toStringAsFixed(2)}',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Section Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isMl ? 'രേഖപ്പെടുത്തിയ ലാഭങ്ങൾ (${profits.length})' : 'Recorded Profits (${profits.length})',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    TextButton.icon(
                      onPressed: () => _openAddProfitDialog(context),
                      icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: Color(0xFF047857)),
                      label: Text(
                        isMl ? 'പുതിയത്' : 'New',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF047857)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (profits.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.trending_up_rounded, size: 54, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          isMl ? 'ഗ്രൂപ്പ് ലാഭങ്ങൾ ഇതുവരെ രേഖപ്പെടുത്തിയിട്ടില്ല.' : 'No group profits recorded yet.',
                          style: GoogleFonts.outfit(fontSize: 15, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF047857),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _openAddProfitDialog(context),
                          icon: const Icon(Icons.add_rounded),
                          label: Text(isMl ? 'ലാഭം രേഖപ്പെടുത്തുക' : 'Record Profit'),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: profits.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = profits[index];
                      return Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: AppColors.borderLight),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Color(0xFFECFDF5),
                                child: Icon(Icons.trending_up_rounded, color: Color(0xFF047857)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isMl ? 'തീയതി: ${item.profitDate}' : 'Date: ${item.profitDate}',
                                      style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                    if (item.description != null && item.description!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        item.description!,
                                        style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade700),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Text(
                                '+₹${item.amount.toStringAsFixed(2)}',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: const Color(0xFF047857),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
