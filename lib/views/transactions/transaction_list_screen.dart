import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ashgledger/core/theme/app_colors.dart';
import 'package:ashgledger/core/common/common_error_widget.dart';
import 'package:ashgledger/core/common/app_shimmer.dart';
import 'package:ashgledger/core/common/app_date_picker.dart';
import 'package:ashgledger/core/common/app_formatters.dart';
import 'package:ashgledger/core/localization/app_localizations.dart';
import 'package:ashgledger/core/di/service_locator.dart';
import 'package:ashgledger/core/repository/dashboard_repository.dart';
import 'package:ashgledger/viewmodel/transaction_list_viewmodel.dart';
import 'package:ashgledger/core/model/financial_transaction_model.dart';

class TransactionListScreen extends StatelessWidget {
  final String? initialQuery;
  final String? initialAccountType;

  const TransactionListScreen({super.key, this.initialQuery, this.initialAccountType});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionListViewModel(sl<DashboardRepository>()),
      child: _TransactionListScreenBody(
        initialQuery: initialQuery,
        initialAccountType: initialAccountType,
      ),
    );
  }
}

class _TransactionListScreenBody extends StatefulWidget {
  final String? initialQuery;
  final String? initialAccountType;

  const _TransactionListScreenBody({this.initialQuery, this.initialAccountType});

  @override
  State<_TransactionListScreenBody> createState() => _TransactionListScreenBodyState();
}

class _TransactionListScreenBodyState extends State<_TransactionListScreenBody> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final vm = context.read<TransactionListViewModel>();
        if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
          vm.setSearchQuery(widget.initialQuery!);
        }
        if (widget.initialAccountType != null && widget.initialAccountType!.isNotEmpty) {
          vm.setAccountTypeFilter(widget.initialAccountType!);
        }
        if ((widget.initialQuery == null || widget.initialQuery!.isEmpty) &&
            (widget.initialAccountType == null || widget.initialAccountType!.isEmpty)) {
          vm.fetchTransactions(page: 0);
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange(BuildContext context, TransactionListViewModel vm) async {
    final DateTimeRange? picked = await AppDatePicker.pickDateRange(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: vm.startDate != null && vm.endDate != null
          ? DateTimeRange(
              start: DateTime.parse(vm.startDate!),
              end: DateTime.parse(vm.endDate!),
            )
          : null,
    );

    if (picked != null) {
      final startStr = "${picked.start.year}-${picked.start.month.toString().padLeft(2, '0')}-${picked.start.day.toString().padLeft(2, '0')}";
      final endStr = "${picked.end.year}-${picked.end.month.toString().padLeft(2, '0')}-${picked.end.day.toString().padLeft(2, '0')}";
      vm.setDateRange(startStr, endStr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.translate('recent_transactions'),
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        actions: [
          Consumer<TransactionListViewModel>(
            builder: (context, vm, _) => IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => vm.fetchTransactions(page: vm.currentPage),
            ),
          ),
        ],
      ),
      body: Consumer<TransactionListViewModel>(
        builder: (context, vm, _) {
          return Column(
            children: [
              _buildSearchBar(context, vm, l10n),
              _buildCategoryChips(context, vm, l10n),
              _buildSubFiltersRow(context, vm, l10n),
              const Divider(height: 1, color: AppColors.borderLight),
              Expanded(
                child: _buildTransactionList(context, vm, l10n),
              ),
              _buildPaginationControls(context, vm),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, TransactionListViewModel vm, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: l10n.locale.languageCode == 'ml'
              ? 'അംഗത്തിൻ്റെ പേര്, നമ്പർ, വിവരണം തിരയുക...'
              : 'Search by member, number, description...',
          hintStyle: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMuted),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    vm.setSearchQuery('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.bgLight,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (val) {
          vm.setSearchQuery(val);
        },
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context, TransactionListViewModel vm, AppLocalizations l10n) {
    final categories = [
      {'key': null, 'label': l10n.translate('all')},
      {'key': 'LOAN', 'label': AppFormatters.formatAccountType('LOAN', l10n)},
      {'key': 'DEPOSIT', 'label': AppFormatters.formatAccountType('DEPOSIT', l10n)},
      {'key': 'FINE', 'label': AppFormatters.formatAccountType('FINE', l10n)},
      {'key': 'MONTHLY_CONTRIBUTION', 'label': AppFormatters.formatAccountType('MONTHLY_CONTRIBUTION', l10n)},
      {'key': 'FINANCIAL_AID', 'label': AppFormatters.formatAccountType('FINANCIAL_AID', l10n)},
      {'key': 'INTEREST', 'label': AppFormatters.formatAccountType('INTEREST', l10n)},
    ];

    return Container(
      height: 44,
      color: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = categories[index];
          final String? key = item['key'];
          final String label = item['label'] ?? '';
          final isSelected = vm.selectedAccountType == key;

          return ChoiceChip(
            label: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textDark,
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.bgLight,
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.borderLight,
              ),
            ),
            onSelected: (_) {
              vm.setAccountTypeFilter(key);
            },
          );
        },
      ),
    );
  }

  Widget _buildSubFiltersRow(BuildContext context, TransactionListViewModel vm, AppLocalizations l10n) {
    final hasDateFilter = vm.startDate != null && vm.endDate != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              side: BorderSide(color: hasDateFilter ? AppColors.primary : AppColors.borderLight),
              backgroundColor: hasDateFilter ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: () => _selectDateRange(context, vm),
            icon: Icon(Icons.date_range_rounded, size: 14, color: hasDateFilter ? AppColors.primary : AppColors.textSecondary),
            label: Text(
              hasDateFilter ? "${vm.startDate} ~ ${vm.endDate}" : (l10n.locale.languageCode == 'ml' ? 'തീയതി' : 'Date Range'),
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: hasDateFilter ? FontWeight.bold : FontWeight.w500,
                color: hasDateFilter ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Text(
              l10n.locale.languageCode == 'ml' ? 'മാറ്റിയവ ഒഴിവാക്കുക' : 'Active Only',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: vm.isReversed == false ? FontWeight.bold : FontWeight.w500,
                color: vm.isReversed == false ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            selected: vm.isReversed == false,
            onSelected: (val) {
              vm.setReversedFilter(val ? false : null);
            },
            showCheckmark: false,
            backgroundColor: Colors.transparent,
            selectedColor: AppColors.primary.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: vm.isReversed == false ? AppColors.primary : AppColors.borderLight),
            ),
          ),
          const Spacer(),
          if (vm.hasActiveFilters)
            TextButton.icon(
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: () {
                _searchController.clear();
                vm.clearAllFilters();
              },
              icon: const Icon(Icons.clear_all_rounded, size: 14, color: Colors.red),
              label: Text(
                l10n.locale.languageCode == 'ml' ? 'മറ്റുക' : 'Reset',
                style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context, TransactionListViewModel vm, AppLocalizations l10n) {
    if (vm.loadState.isLoading) return const TransactionListShimmerLoading();
    if (vm.loadState.hasError) {
      return CommonErrorWidget(
        message: vm.loadState.message ?? 'Failed to load transactions',
        onRetry: () => vm.fetchTransactions(page: 0),
      );
    }

    if (vm.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              l10n.translate('no_recent_transactions'),
              style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => vm.fetchTransactions(page: vm.currentPage),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vm.transactions.length,
        itemBuilder: (context, index) {
          final tx = vm.transactions[index];
          return _buildTransactionCard(context, tx);
        },
      ),
    );
  }

  Widget _buildPaginationControls(BuildContext context, TransactionListViewModel vm) {
    final l10n = AppLocalizations.of(context);
    final hasPrev = vm.currentPage > 0;
    final hasNext = vm.currentPage < vm.totalPages - 1;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.borderLight)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -2),
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
              onPressed: hasPrev ? () => vm.previousPage() : null,
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: Text(l10n.translate('previous'), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
            Text(
              l10n.locale.languageCode == 'ml'
                  ? 'പേജ് ${vm.currentPage + 1} / ${vm.totalPages}'
                  : 'Page ${vm.currentPage + 1} of ${vm.totalPages}',
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
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
              onPressed: hasNext ? () => vm.nextPage() : null,
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: Text(l10n.translate('next'), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, FinancialTransactionModel tx) {
    final l10n = AppLocalizations.of(context);
    Color typeColor = AppColors.primary;
    if (tx.accountType == 'LOAN') typeColor = AppColors.accountLoan;
    if (tx.accountType == 'DEPOSIT') typeColor = AppColors.accountDeposit;
    if (tx.accountType == 'FINE') typeColor = AppColors.accountFine;
    if (tx.accountType == 'FINANCIAL_AID') typeColor = AppColors.accountFinancialAid;
    if (tx.accountType == 'MONTHLY_CONTRIBUTION') typeColor = AppColors.accountContribution;
    if (tx.accountType == 'INTEREST') typeColor = AppColors.accountInterest;

    final isReversal = tx.transactionType == 'REVERSAL';
    final isAlreadyReversed = tx.isReversed;
    final formattedType = AppFormatters.formatTransactionType(tx.transactionType, l10n);
    final formattedAccount = AppFormatters.formatAccountType(tx.accountType, l10n);
    final formattedDate = AppFormatters.formatDateTime(tx.createdAt);
    final formattedDescription = AppFormatters.formatDescription(tx.description, l10n);
    final memberName = (tx.memberName != null && tx.memberName!.isNotEmpty) ? tx.memberName! : 'Member #${tx.memberId}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    formattedAccount,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: typeColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '#${tx.id} - $formattedType',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isReversal ? Colors.purple : (isAlreadyReversed ? AppColors.textMuted : AppColors.textDark),
                      decoration: isAlreadyReversed ? TextDecoration.lineThrough : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '₹${tx.amount.toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isReversal ? Colors.purple : (isAlreadyReversed ? AppColors.textMuted : typeColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$memberName  •  $formattedDate',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (isAlreadyReversed)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Reversed',
                      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                    ),
                  ),
              ],
            ),
            if (formattedDescription.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  formattedDescription,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
