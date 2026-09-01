import '../../core/model/special_loan_type_model.dart';
import '../../viewmodel/settings_viewmodel.dart';
import '../../core/di/service_locator.dart';
import '../transactions/transaction_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ashgledger/core/theme/app_colors.dart';
import 'package:ashgledger/core/common/common_error_widget.dart';
import 'package:ashgledger/core/common/app_snackbar.dart';
import 'package:ashgledger/core/common/app_formatters.dart';
import 'package:ashgledger/viewmodel/member_viewmodel.dart';
import 'package:ashgledger/core/model/member_model.dart';
import 'package:ashgledger/views/members/edit_member_dialog.dart';
import 'package:ashgledger/core/model/member_account_model.dart';
import 'package:ashgledger/core/model/financial_transaction_model.dart';
import '../../core/common/app_shimmer.dart';
import '../../core/localization/app_localizations.dart';

class MemberDetailScreen extends StatelessWidget {
  final int memberId;

  const MemberDetailScreen({super.key, required this.memberId});

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
            return const MemberDetailShimmerLoading();
          }

          final member = vm.selectedMember!;

          return RefreshIndicator(
            onRefresh: () =>
                context.read<MemberViewModel>().loadMemberDetail(memberId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProfileHeader(context, member, l10n),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.translate('account_balances'),
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildActionMenu(context, member, l10n),
                  ],
                ),
                const SizedBox(height: 12),
                Selector<MemberViewModel, List<MemberAccountModel>>(
                  selector: (_, vm) => vm.accounts,
                  builder: (context, accounts, _) {
                    return Column(
                      children: accounts
                          .map((acc) => _buildAccountTile(acc, l10n))
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        l10n.translate('transaction_history'),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TransactionListScreen(
                              initialQuery: member.memberNumber,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        l10n.translate('view_all'),
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Selector<MemberViewModel, List<FinancialTransactionModel>>(
                  selector: (_, vm) => vm.transactions,
                  builder: (context, transactions, _) {
                    if (transactions.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(l10n.translate('no_transactions')),
                        ),
                      );
                    }
                    return Column(
                      children: transactions
                          .map((tx) => _buildTxTile(context, tx, l10n))
                          .toList(),
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

  Widget _buildProfileHeader(
    BuildContext context,
    MemberModel member,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Text(
              member.memberNumber,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member.phone ?? l10n.translate('no_phone'),
                  style: GoogleFonts.outfit(color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.edit_rounded, size: 20),
            tooltip: l10n.translate('edit_profile'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => EditMemberDialog(member: member),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(
    BuildContext context,
    MemberModel member,
    AppLocalizations l10n,
  ) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.tune_rounded,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      elevation: 4,
      shadowColor: Colors.black26,
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 290),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      onSelected: (value) {
        if (value == 'DEPOSIT')
          _showAmountDialog(
            context,
            member.id,
            l10n.translate('add_deposit'),
            (amt, dt, description) =>
                context.read<MemberViewModel>().addDeposit(
                  member.id,
                  amt,
                  transactionDate: dt,
                  description: description,
                ),
          );
        if (value == 'LOAN')
          _showAmountDialog(
            context,
            member.id,
            l10n.translate('issue_loan'),
            (amt, dt, description) => context.read<MemberViewModel>().issueLoan(
              member.id,
              amt,
              transactionDate: dt,
              description: description,
            ),
          );
        if (value == 'FINE')
          _showAmountDialog(
            context,
            member.id,
            l10n.translate('add_fine'),
            (amt, dt, description) => context.read<MemberViewModel>().addFine(
              member.id,
              amt,
              transactionDate: dt,
              description: description,
            ),
          );
        if (value == 'CONTRIBUTION')
          _showAmountDialog(
            context,
            member.id,
            l10n.translate('add_contribution'),
            (amt, dt, description) =>
                context.read<MemberViewModel>().addContribution(
                  member.id,
                  amt,
                  transactionDate: dt,
                  description: description,
                ),
          );
        if (value == 'AID') {
          _showAmountDialog(
            context,
            member.id,
            l10n.translate('add_aid'),
            (amt, dt, description) =>
                context.read<MemberViewModel>().addFinancialAid(
                  member.id,
                  amt,
                  transactionDate: dt,
                  description: description == ""
                      ? "FictionalAid : ${member.fullName}"
                      : description,
                ),
          );
        }
        if (value == 'SPECIAL_LOAN')
          _showIssueSpecialLoanDialog(context, member.id, l10n);
      },
      itemBuilder: (context) => [
        _buildMenuItem(
          value: 'DEPOSIT',
          title: l10n.translate('add_deposit'),
          icon: Icons.savings_rounded,
          color: AppColors.accountDeposit,
        ),
        _buildMenuItem(
          value: 'LOAN',
          title: l10n.translate('issue_loan'),
          icon: Icons.add_card_rounded,
          color: AppColors.accountLoan,
        ),
        _buildMenuItem(
          value: 'FINE',
          title: l10n.translate('add_fine'),
          icon: Icons.gavel_rounded,
          color: AppColors.accountFine,
        ),
        _buildMenuItem(
          value: 'CONTRIBUTION',
          title: l10n.translate('add_contribution'),
          icon: Icons.calendar_today_rounded,
          color: AppColors.accountContribution,
        ),
        _buildMenuItem(
          value: 'SPECIAL_LOAN',
          title: l10n.locale.languageCode == 'ml'
              ? 'സ്പെഷ്യൽ വായ്പ നൽകുക'
              : 'Issue Special Loan',
          icon: Icons.assignment_rounded,
          color: Colors.deepOrange,
        ),
        _buildMenuItem(
          value: 'AID',
          title: l10n.translate('add_aid'),
          icon: Icons.volunteer_activism_rounded,
          color: AppColors.accountFinancialAid,
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required String value,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return PopupMenuItem<String>(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTile(MemberAccountModel acc, AppLocalizations l10n) {
    Color color = AppColors.primary;
    if (acc.accountType == 'LOAN') color = AppColors.accountLoan;
    if (acc.accountType == 'DEPOSIT') color = AppColors.accountDeposit;
    if (acc.accountType == 'FINE') color = AppColors.accountFine;
    if (acc.accountType == 'FINANCIAL_AID')
      color = AppColors.accountFinancialAid;
    if (acc.accountType == 'MONTHLY_CONTRIBUTION')
      color = AppColors.accountContribution;
    if (acc.accountType == 'INTEREST') color = AppColors.accountInterest;
    if (acc.accountType == 'SPECIAL_LOAN') color = Colors.deepOrange;

    String title = l10n.translate(acc.accountType);
    if (acc.accountType == 'SPECIAL_LOAN') {
      title =
          acc.specialLoanTypeName != null && acc.specialLoanTypeName!.isNotEmpty
          ? acc.specialLoanTypeName!
          : (l10n.locale.languageCode == 'ml'
                ? 'സ്പെഷ്യൽ വായ്പ'
                : 'Special Loan');
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(
            acc.accountType == 'SPECIAL_LOAN'
                ? Icons.assignment_rounded
                : Icons.account_balance_wallet_rounded,
            color: color,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: acc.accountType == 'SPECIAL_LOAN'
            ? Text(
                l10n.locale.languageCode == 'ml'
                    ? 'സ്പെഷ്യൽ വായ്പ'
                    : 'Special Loan Account',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        trailing: Text(
          '₹${acc.currentBalance.toStringAsFixed(2)}',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildTxTile(
    BuildContext context,
    FinancialTransactionModel tx,
    AppLocalizations l10n,
  ) {
    Color typeColor = AppColors.primary;
    if (tx.accountType == 'LOAN') typeColor = AppColors.accountLoan;
    if (tx.accountType == 'DEPOSIT') typeColor = AppColors.accountDeposit;
    if (tx.accountType == 'FINE') typeColor = AppColors.accountFine;
    if (tx.accountType == 'FINANCIAL_AID')
      typeColor = AppColors.accountFinancialAid;
    if (tx.accountType == 'MONTHLY_CONTRIBUTION')
      typeColor = AppColors.accountContribution;
    if (tx.accountType == 'INTEREST') typeColor = AppColors.accountInterest;

    final isReversal = tx.transactionType == 'REVERSAL' || tx.isReversed;
    final formattedType = AppFormatters.formatTransactionType(
      tx.transactionType,
      l10n,
    );
    final formattedAccount = AppFormatters.formatAccountType(
      tx.accountType,
      l10n,
    );
    final formattedDate = AppFormatters.formatDateTime(tx.createdAt);
    final formattedDescription = AppFormatters.formatDescription(
      tx.description,
      l10n,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
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
                      color: isReversal ? Colors.purple : AppColors.textDark,
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
                    color: isReversal ? Colors.purple : typeColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    formattedDate,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (!isReversal) ...[
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showReverseDialog(context, tx),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.undo_rounded,
                            size: 14,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.translate('reverse_action'),
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (formattedDescription.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
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
            ],
          ],
        ),
      ),
    );
  }

  void _showReverseDialog(BuildContext context, FinancialTransactionModel tx) {
    final reasonCtrl = TextEditingController();
    final l10n = AppLocalizations.of(context);
    final accountTypeLabel = AppFormatters.formatAccountType(
      tx.accountType,
      l10n,
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '${l10n.translate('reverse_transaction_title')} #${tx.id}',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.translate('reverse_transaction_title')}: $accountTypeLabel (₹${tx.amount.toStringAsFixed(2)})',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonCtrl,
              decoration: InputDecoration(
                labelText: l10n.translate('reason_for_reversal'),
                hintText: 'e.g. Incorrect entry recorded',
                prefixIcon: const Icon(Icons.notes_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.translate('cancel'),
              style: GoogleFonts.outfit(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final reason = reasonCtrl.text.trim();
              if (reason.isEmpty) return;
              Navigator.pop(dialogContext);

              final success = await context
                  .read<MemberViewModel>()
                  .reverseTransaction(tx.memberId, tx.id, reason);
              if (context.mounted) {
                if (success) {
                  AppSnackbar.showSuccess(
                    context,
                    'Transaction #${tx.id} reversed successfully!',
                  );
                } else {
                  AppSnackbar.showError(
                    context,
                    context.read<MemberViewModel>().actionState.message ??
                        'Reversal failed',
                  );
                }
              }
            },
            child: Text(
              l10n.translate('reverse_action'),
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showAmountDialog(
    BuildContext context,
    int memberId,
    String title,
    Future<bool> Function(double, String, String) action,
  ) {
    final amountCtrl = TextEditingController();
    final descriptionCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final dateStr =
              "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              title,
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount (₹)',
                    prefixIcon: Icon(Icons.payments_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Transaction Date',
                      suffixIcon: Icon(Icons.calendar_month_rounded),
                    ),
                    child: Text(
                      dateStr,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: descriptionCtrl,
                  keyboardType: TextInputType.text,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description_rounded),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.translate('cancel')),
              ),
              ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountCtrl.text);
                  if (amount == null || amount <= 0) return;
                  final formattedDate =
                      "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                  final success = await action(
                    amount,
                    formattedDate,
                    descriptionCtrl.text,
                  );
                  if (dialogContext.mounted) {
                    if (success)
                      AppSnackbar.showSuccess(
                        dialogContext,
                        '$title Recorded!',
                      );
                    Navigator.pop(dialogContext);
                  }
                },
                child: Text(l10n.translate('save')),
              ),
            ],
          );
        },
      ),
    );
  }
}

void _showIssueSpecialLoanDialog(
  BuildContext context,
  int memberId,
  AppLocalizations l10n,
) {
  final isMl = l10n.locale.languageCode == 'ml';
  final amountCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  DateTime selectedDate = DateTime.now();
  SpecialLoanTypeModel? selectedType;

  showDialog(
    context: context,
    builder: (dialogContext) => ChangeNotifierProvider(
      create: (_) => sl<SettingsViewModel>()..fetchSpecialLoanTypes(),
      child: Consumer<SettingsViewModel>(
        builder: (context, vm, _) {
          final activeTypes = vm.specialLoanTypes
              .where((t) => t.isActive)
              .toList();
          if (activeTypes.isNotEmpty && selectedType == null) {
            selectedType = activeTypes.first;
          }

          return StatefulBuilder(
            builder: (ctx, setState) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                isMl ? 'സ്പെഷ്യൽ വായ്പ നൽകുക' : 'Issue Special Loan',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (activeTypes.isEmpty)
                    Text(
                      isMl
                          ? 'സെറ്റിംഗ്സിൽ സ്പെഷ്യൽ വായ്പ തരങ്ങൾ ചേർക്കുക.'
                          : 'Please add special loan types in Settings first.',
                      style: GoogleFonts.outfit(color: Colors.red),
                    )
                  else
                    DropdownButtonFormField<SpecialLoanTypeModel>(
                      initialValue: selectedType,
                      decoration: InputDecoration(
                        labelText: isMl ? 'വായ്പ തരം' : 'Loan Type',
                        border: const OutlineInputBorder(),
                      ),
                      items: activeTypes.map((t) {
                        return DropdownMenuItem<SpecialLoanTypeModel>(
                          value: t,
                          child: Text(
                            t.name,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedType = val),
                    ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: isMl ? 'തുക (₹)' : 'Amount (₹)',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    decoration: InputDecoration(
                      labelText: isMl ? 'വിവരണം' : 'Notes',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(isMl ? 'റദ്ദാക്കുക' : 'Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: selectedType == null
                      ? null
                      : () async {
                          final amt = double.tryParse(amountCtrl.text) ?? 0.0;
                          if (amt <= 0) return;
                          final formattedDate = selectedDate.toString().split(
                            ' ',
                          )[0];
                          final success = await context
                              .read<MemberViewModel>()
                              .issueLoan(
                                memberId,
                                amt,
                                specialLoanTypeId: selectedType!.id,
                                description: notesCtrl.text.trim(),
                                transactionDate: formattedDate,
                              );
                          if (dialogContext.mounted) {
                            if (success)
                              AppSnackbar.showSuccess(
                                dialogContext,
                                'Special Loan Issued!',
                              );
                            Navigator.pop(dialogContext);
                          }
                        },
                  child: Text(isMl ? 'നൽകുക' : 'Issue'),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
