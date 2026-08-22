import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ashgledger/core/theme/app_colors.dart';
import 'package:ashgledger/core/common/common_error_widget.dart';
import 'package:ashgledger/core/common/app_snackbar.dart';
import 'package:ashgledger/viewmodel/member_viewmodel.dart';
import 'package:ashgledger/core/model/member_model.dart';
import 'package:ashgledger/core/model/member_account_model.dart';
import 'package:ashgledger/core/model/financial_transaction_model.dart';
import '../../core/common/app_shimmer.dart';


import '../../core/localization/app_localizations.dart';

class MemberDetailScreen extends StatelessWidget {
  final int memberId;

  const MemberDetailScreen({super.key, required this.memberId});

  Widget _buildShimmerSkeleton() {
    return AppShimmer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ShimmerBox(width: double.infinity, height: 100, borderRadius: 20),
          const SizedBox(height: 20),
          const ShimmerBox(width: 180, height: 20, borderRadius: 4),
          const SizedBox(height: 12),
          ...List.generate(6, (_) => const ShimmerListTile()),
          const SizedBox(height: 20),
          const ShimmerBox(width: 180, height: 20, borderRadius: 4),
          const SizedBox(height: 12),
          ...List.generate(4, (_) => const ShimmerListTile()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberViewModel>().loadMemberDetail(memberId);
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('member_details'))),
      body: Consumer<MemberViewModel>(
        builder: (context, vm, _) {
          if (vm.loadState.isLoading || vm.selectedMember == null) {
            if (vm.loadState.hasError) {
              return CommonErrorWidget(
                message: vm.loadState.message ?? 'Failed to load details',
                onRetry: () => vm.loadMemberDetail(memberId),
              );
            }
            return _buildShimmerSkeleton();
          }

          final member = vm.selectedMember!;

          return RefreshIndicator(
            onRefresh: () => context.read<MemberViewModel>().loadMemberDetail(memberId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProfileHeader(member, l10n),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.translate('account_balances'), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                    _buildActionMenu(context, member, l10n),
                  ],
                ),
                const SizedBox(height: 12),
                Selector<MemberViewModel, List<MemberAccountModel>>(
                  selector: (_, vm) => vm.accounts,
                  builder: (context, accounts, _) {
                    return Column(
                      children: accounts.map((acc) => _buildAccountTile(acc, l10n)).toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(l10n.translate('transaction_history'), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Selector<MemberViewModel, List<FinancialTransactionModel>>(
                  selector: (_, vm) => vm.transactions,
                  builder: (context, transactions, _) {
                    if (transactions.isEmpty) {
                      return Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(l10n.translate('no_transactions'))));
                    }
                    return Column(
                      children: transactions.map((tx) => _buildTxTile(tx, l10n)).toList(),
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

  Widget _buildProfileHeader(MemberModel member, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Text(member.memberNumber, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.fullName, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(member.phone ?? l10n.translate('no_phone'), style: GoogleFonts.outfit(color: Colors.white70)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, MemberModel member, AppLocalizations l10n) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.tune_rounded, color: AppColors.primary),
      onSelected: (value) {
        if (value == 'LOAN') _showAmountDialog(context, member.id, l10n.translate('issue_loan'), (amt) => context.read<MemberViewModel>().issueLoan(member.id, amt));
        if (value == 'DEPOSIT') _showAmountDialog(context, member.id, l10n.translate('add_deposit'), (amt) => context.read<MemberViewModel>().addDeposit(member.id, amt));
        if (value == 'FINE') _showAmountDialog(context, member.id, l10n.translate('add_fine'), (amt) => context.read<MemberViewModel>().addFine(member.id, amt));
        if (value == 'CONTRIBUTION') _showAmountDialog(context, member.id, l10n.translate('add_contribution'), (amt) => context.read<MemberViewModel>().addContribution(member.id, amt));
        if (value == 'AID') _showAmountDialog(context, member.id, l10n.translate('add_aid'), (amt) => context.read<MemberViewModel>().addFinancialAid(member.id, amt));
        if (value == 'INTEREST') _showInterestDialog(context, member.id, l10n);
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'DEPOSIT', child: ListTile(leading: const Icon(Icons.savings_rounded, color: AppColors.accountDeposit), title: Text(l10n.translate('add_deposit')))),
        PopupMenuItem(value: 'LOAN', child: ListTile(leading: const Icon(Icons.add_card_rounded, color: AppColors.accountLoan), title: Text(l10n.translate('issue_loan')))),
        PopupMenuItem(value: 'FINE', child: ListTile(leading: const Icon(Icons.gavel_rounded, color: AppColors.accountFine), title: Text(l10n.translate('add_fine')))),
        PopupMenuItem(value: 'CONTRIBUTION', child: ListTile(leading: const Icon(Icons.account_balance_rounded, color: AppColors.accountContribution), title: Text(l10n.translate('add_contribution')))),
        PopupMenuItem(value: 'AID', child: ListTile(leading: const Icon(Icons.volunteer_activism_rounded, color: AppColors.accountFinancialAid), title: Text(l10n.translate('add_aid')))),
        PopupMenuItem(value: 'INTEREST', child: ListTile(leading: const Icon(Icons.calculate_rounded, color: AppColors.accountInterest), title: Text(l10n.translate('calc_interest_action')))),
      ],
    );
  }

  Widget _buildAccountTile(MemberAccountModel acc, AppLocalizations l10n) {
    Color color = AppColors.primary;
    if (acc.accountType == 'LOAN') color = AppColors.accountLoan;
    if (acc.accountType == 'DEPOSIT') color = AppColors.accountDeposit;
    if (acc.accountType == 'FINE') color = AppColors.accountFine;
    if (acc.accountType == 'FINANCIAL_AID') color = AppColors.accountFinancialAid;
    if (acc.accountType == 'MONTHLY_CONTRIBUTION') color = AppColors.accountContribution;
    if (acc.accountType == 'INTEREST') color = AppColors.accountInterest;

    final translatedAccountType = l10n.translate(acc.accountType);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.account_balance_wallet_rounded, color: color),
        title: Text(translatedAccountType, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        trailing: Text(
          '₹${acc.currentBalance.toStringAsFixed(2)}',
          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ),
    );
  }


  Widget _buildTxTile(FinancialTransactionModel tx, AppLocalizations l10n) {
    final translatedType = l10n.translate(tx.accountType);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text('${tx.transactionType} - $translatedType', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        subtitle: Text(tx.createdAt, style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
        trailing: Text('₹${tx.amount.toStringAsFixed(2)}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showAmountDialog(BuildContext context, int memberId, String title, Future<bool> Function(double) action) {
    final amountCtrl = TextEditingController();
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: amountCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount (₹)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.translate('cancel'))),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountCtrl.text);
              if (amount == null || amount <= 0) return;
              final success = await action(amount);
              if (context.mounted) {
                if (success) AppSnackbar.showSuccess(context, '$title Recorded!');
                Navigator.pop(context);
              }
            },
            child: Text(l10n.translate('save')),
          )
        ],
      ),
    );
  }

  void _showInterestDialog(BuildContext context, int memberId, AppLocalizations l10n) {
    final periodCtrl = TextEditingController(text: '2026-09');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.translate('calc_interest_dialog_title')),
        content: TextField(
          controller: periodCtrl,
          decoration: InputDecoration(labelText: '${l10n.translate('interest_period')} (YYYY-MM)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.translate('cancel'))),
          ElevatedButton(
            onPressed: () async {
              final success = await context.read<MemberViewModel>().calculateInterest(memberId, periodCtrl.text.trim());
              if (context.mounted) {
                if (success) AppSnackbar.showSuccess(context, 'Interest Calculated!');
                Navigator.pop(context);
              }
            },
            child: Text(l10n.translate('calculate')),
          )
        ],
      ),
    );
  }
}

