import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/common/common_error_widget.dart';
import '../../core/common/app_shimmer.dart';
import '../../core/localization/app_localizations.dart';
import '../../viewmodel/member_portal_viewmodel.dart';
import 'package:provider/provider.dart';

class MemberAllTransactionsScreen extends StatelessWidget {
  const MemberAllTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMl = l10n.locale.languageCode == 'ml';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMl ? 'എല്ലാ ഇടപാടുകളും' : 'All My Transactions',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<MemberPortalViewModel>(
        builder: (context, vm, _) {
          if (vm.loadState.isLoading) return const MemberListShimmerLoading();
          if (vm.loadState.hasError) {
            return CommonErrorWidget(
              message: vm.loadState.message ?? 'Failed to load transactions',
              onRetry: () => vm.fetchMyTransactionsPage(vm.currentPage),
            );
          }

          if (vm.myTransactions.isEmpty) {
            return Center(
              child: Text(
                isMl ? 'ഇടപാടുകളൊന്നും രേഖപ്പെടുത്തിയിട്ടില്ല.' : 'No transactions recorded yet.',
                style: GoogleFonts.outfit(color: AppColors.textSecondary),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => vm.fetchMyTransactionsPage(0),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.myTransactions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final tx = vm.myTransactions[index];
                      final isReversed = tx.isReversed;

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: isReversed ? Colors.red.shade200 : AppColors.divider),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                tx.accountType,
                                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                '₹${tx.amount.toStringAsFixed(2)}',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isReversed ? Colors.grey : AppColors.primaryDark,
                                  decoration: isReversed ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Date: ${tx.createdAt.contains('T') ? tx.createdAt.split('T')[0] : tx.createdAt} | Type: ${tx.transactionType}',
                                style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              if (tx.description != null && tx.description!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text('Notes: ${tx.description}', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textDark)),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Pagination Controls
              if (vm.totalPages > 1)
                SafeArea(
                  top: false,
                  bottom: true,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: const Border(top: BorderSide(color: AppColors.divider)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade200,
                            disabledForegroundColor: Colors.grey.shade400,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onPressed: vm.currentPage > 0
                              ? () => vm.fetchMyTransactionsPage(vm.currentPage - 1)
                              : null,
                          icon: const Icon(Icons.arrow_back_rounded, size: 16),
                          label: Text(l10n.translate('previous'), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                        ),
                        Text(
                          isMl
                              ? 'പേജ് ${vm.currentPage + 1} / ${vm.totalPages}'
                              : 'Page ${vm.currentPage + 1} of ${vm.totalPages}',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade200,
                            disabledForegroundColor: Colors.grey.shade400,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          onPressed: vm.currentPage < vm.totalPages - 1
                              ? () => vm.fetchMyTransactionsPage(vm.currentPage + 1)
                              : null,
                          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                          label: Text(l10n.translate('next'), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
