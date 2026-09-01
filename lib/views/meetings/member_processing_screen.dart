import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ashgledger/core/theme/app_colors.dart';
import 'package:ashgledger/core/common/common_error_widget.dart';
import 'package:ashgledger/core/common/app_snackbar.dart';
import 'package:ashgledger/core/common/app_shimmer.dart';
import 'package:ashgledger/core/localization/app_localizations.dart';
import 'package:ashgledger/viewmodel/member_processing_viewmodel.dart';
import 'package:ashgledger/core/model/member_processing_data_model.dart';

class MemberProcessingScreen extends StatefulWidget {
  final int meetingId;
  final int memberId;
  final String meetingDate;

  const MemberProcessingScreen({
    super.key,
    required this.meetingId,
    required this.memberId,
    required this.meetingDate,
  });

  @override
  State<MemberProcessingScreen> createState() => _MemberProcessingScreenState();
}

class _MemberProcessingScreenState extends State<MemberProcessingScreen> {
  final _loanRepaymentCtrl = TextEditingController();
  final _depositAdditionCtrl = TextEditingController();
  final _finePaymentCtrl = TextEditingController();

  final _monthlyContributionCtrl = TextEditingController();
  final Map<int, TextEditingController> _specialLoanCtrls = {};

  TextEditingController _getSpecialLoanCtrl(int typeId) {
    return _specialLoanCtrls.putIfAbsent(typeId, () {
      final c = TextEditingController();
      c.addListener(_onFieldChanged);
      return c;
    });
  }

  final _notesCtrl = TextEditingController();
  // ignore: prefer_final_fields
  DateTime _selectedTransactionDate = DateTime.now();
  // ignore: prefer_final_fields
  bool _isEditMode = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    _loanRepaymentCtrl.addListener(_onFieldChanged);
    _depositAdditionCtrl.addListener(_onFieldChanged);
    _finePaymentCtrl.addListener(_onFieldChanged);
    _monthlyContributionCtrl.addListener(_onFieldChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadForm();
      }
    });
  }

  Future<void> _loadForm() async {
    _resetFormState();

    final vm = context.read<MemberProcessingViewModel>();

    await vm.fetchProcessingForm(widget.meetingId, widget.memberId);

    if (!mounted) return;

    final data = vm.formData;

    if (data != null && data.processingStatus == 'COMPLETED') {
      _populateControllers(data);
      _isInitialized = true;
    }
  }

  void _resetFormState() {
    _isInitialized = false;
    _isEditMode = false;

    _loanRepaymentCtrl.clear();
    _depositAdditionCtrl.clear();
    _finePaymentCtrl.clear();
    _monthlyContributionCtrl.clear();
    _notesCtrl.clear();

    for (final controller in _specialLoanCtrls.values) {
      controller.clear();
    }
  }

  void _populateControllers(MemberProcessingDataModel data) {
    _loanRepaymentCtrl.text = data.lastLoanRepayment > 0
        ? data.lastLoanRepayment.toStringAsFixed(2)
        : '';

    _depositAdditionCtrl.text = data.lastDepositAddition > 0
        ? data.lastDepositAddition.toStringAsFixed(2)
        : '';

    _finePaymentCtrl.text = data.lastFinePayment > 0
        ? data.lastFinePayment.toStringAsFixed(2)
        : '';

    _monthlyContributionCtrl.text = data.lastMonthlyContributionAddition > 0
        ? data.lastMonthlyContributionAddition.toStringAsFixed(2)
        : '';

    _notesCtrl.text = data.lastNotes ?? '';

    for (final controller in _specialLoanCtrls.values) {
      controller.clear();
    }

    for (final spl in data.specialLoanBalances) {
      if (spl.lastRepaymentAmount > 0) {
        _getSpecialLoanCtrl(spl.specialLoanTypeId).text = spl
            .lastRepaymentAmount
            .toStringAsFixed(2);
      }
    }
  }

  void _onFieldChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _loanRepaymentCtrl.removeListener(_onFieldChanged);
    _depositAdditionCtrl.removeListener(_onFieldChanged);
    _finePaymentCtrl.removeListener(_onFieldChanged);

    _monthlyContributionCtrl.removeListener(_onFieldChanged);
    _isInitialized = false;
    _isEditMode = false;

    _loanRepaymentCtrl.dispose();
    _depositAdditionCtrl.dispose();
    _finePaymentCtrl.dispose();
    _monthlyContributionCtrl.dispose();
    for (var c in _specialLoanCtrls.values) {
      c.dispose();
    }
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('member_collection_form'))),
      body: Consumer<MemberProcessingViewModel>(
        builder: (context, vm, _) {
          if (vm.loadState.isLoading ||
              vm.formData == null ||
              vm.loadedMemberId != widget.memberId) {
            return const MemberProcessingShimmerLoading();
          }
          if (vm.loadState.hasError) {
            return CommonErrorWidget(
              message: vm.loadState.message ?? 'Failed to load form',
              onRetry: () =>
                  vm.fetchProcessingForm(widget.meetingId, widget.memberId),
            );
          }

          final isCompleted = vm.formData!.processingStatus == 'COMPLETED';
          final isReadOnly = isCompleted && !_isEditMode;
          final isMl = l10n.locale.languageCode == 'ml';

          // Base balances BEFORE this meeting's payment was applied
          final baseLoan = isCompleted
              ? (vm.formData!.loanRemaining + vm.formData!.lastLoanRepayment)
              : vm.formData!.loanRemaining;
          final baseDeposit = isCompleted
              ? (vm.formData!.depositCurrent - vm.formData!.lastDepositAddition)
              : vm.formData!.depositCurrent;
          final baseFine = isCompleted
              ? (vm.formData!.fineRemaining + vm.formData!.lastFinePayment)
              : vm.formData!.fineRemaining;

          final baseContribution = isCompleted
              ? (vm.formData!.monthlyContributionCurrent -
                    vm.formData!.lastMonthlyContributionAddition)
              : vm.formData!.monthlyContributionCurrent;

          // Calculate entered amounts live
          final loanRepayment = double.tryParse(_loanRepaymentCtrl.text) ?? 0.0;
          final depositAddition =
              double.tryParse(_depositAdditionCtrl.text) ?? 0.0;
          final finePayment = double.tryParse(_finePaymentCtrl.text) ?? 0.0;

          final monthlyContribution =
              double.tryParse(_monthlyContributionCtrl.text) ?? 0.0;

          // Calculate updated total previews
          final updatedLoan = baseLoan - loanRepayment;
          final updatedDeposit = baseDeposit + depositAddition;
          final updatedFine = (baseFine - finePayment) < 0
              ? 0.0
              : (baseFine - finePayment);

          final updatedContribution = baseContribution + monthlyContribution;

          double totalSpecialLoans = 0.0;
          for (var entry in vm.formData!.specialLoanBalances) {
            final c = _specialLoanCtrls[entry.specialLoanTypeId];
            if (c != null) {
              totalSpecialLoans += double.tryParse(c.text) ?? 0.0;
            }
          }

          final totalCollectionToday =
              totalSpecialLoans +
              loanRepayment +
              depositAddition +
              finePayment +
              monthlyContribution;

          final updatedLoanText = loanRepayment > 0
              ? (isMl
                    ? 'പുതിയ വായ്പാ ബാക്കി: ₹${updatedLoan.toStringAsFixed(2)}'
                    : 'Updated Loan Total: ₹${updatedLoan.toStringAsFixed(2)}')
              : null;

          final updatedDepositText = depositAddition > 0
              ? (isMl
                    ? 'പുതിയ നിക്ഷേപം: ₹${updatedDeposit.toStringAsFixed(2)}'
                    : 'Updated Deposit Total: ₹${updatedDeposit.toStringAsFixed(2)}')
              : null;

          final updatedFineText = finePayment > 0
              ? (isMl
                    ? 'പുതിയ പിഴ അടവ്: ₹${updatedFine.toStringAsFixed(2)}'
                    : 'Updated Fine Total: ₹${updatedFine.toStringAsFixed(2)}')
              : null;

          final updatedContributionText = monthlyContribution > 0
              ? (isMl
                    ? 'പുതിയ ആകെ വിഹിതം: ₹${updatedContribution.toStringAsFixed(2)}'
                    : 'Updated Contribution Total: ₹${updatedContribution.toStringAsFixed(2)}')
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMemberBanner(vm.formData!, l10n),
                if (isCompleted && !_isEditMode) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isMl ? 'അടവ് പൂർത്തിയായി' : 'Payment Completed',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                isMl
                                    ? 'ഈ യോഗത്തിലെ അടവ് രേഖപ്പെടുത്തിയിട്ടുണ്ട്.'
                                    : 'Member payment recorded for this meeting.',
                                style: GoogleFonts.outfit(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (isCompleted && _isEditMode) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.edit_rounded,
                          color: Colors.orange,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isMl
                                ? 'അടവ് തിരുത്തുന്നു... സമർപ്പിക്കുമ്പോൾ മുൻ അടവുകൾ റദ്ദാക്കപ്പെടും.'
                                : 'Editing payment. Submitting will update the payment entries.',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (vm.formData!.interestCalculationRequired &&
                    !vm.formData!.interestCalculated)
                  _buildInterestRequiredWarning(vm.formData!, l10n),
                const SizedBox(height: 20),
                Text(
                  l10n.translate('financial_collection_entries'),
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 14),
                if (vm.formData!.interestCalculated)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.accountInterest.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.accountInterest.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calculate_rounded,
                          size: 24,
                          color: AppColors.accountInterest,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${l10n.translate('calculated_interest_title')} (${vm.formData!.activeInterestPeriod ?? "Period"})',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₹${vm.formData!.calculatedInterestAmount.toStringAsFixed(2)}',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accountInterest,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accountInterest.withValues(
                              alpha: 0.18,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.translate('added_to_loan'),
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accountInterest,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                _buildInputField(
                  title: l10n.translate('deposit_addition'),
                  controller: _depositAdditionCtrl,
                  color: AppColors.accountDeposit,
                  badgeText:
                      '${l10n.translate('current')}: ₹${baseDeposit.toStringAsFixed(2)}',
                  badgeColor: AppColors.accountDeposit,
                  badgeIcon: Icons.savings_rounded,
                  updatedText: updatedDepositText,
                  readOnly: isReadOnly,
                ),

                _buildInputField(
                  title: l10n.translate('loan_repayment'),
                  controller: _loanRepaymentCtrl,
                  color: AppColors.accountLoan,
                  badgeText:
                      '${l10n.translate('bal')}: ₹${baseLoan.toStringAsFixed(2)}',
                  badgeColor: AppColors.accountLoan,
                  badgeIcon: Icons.account_balance_wallet_rounded,
                  updatedText: updatedLoanText,
                  readOnly: isReadOnly,
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.arrow_circle_down_rounded,
                      color: AppColors.accountLoan,
                    ),
                    tooltip: l10n.translate('pay_full_loan'),
                    onPressed: () {
                      _loanRepaymentCtrl.text = baseLoan.toStringAsFixed(2);
                    },
                  ),
                ),

                ...vm.formData!.specialLoanBalances.map((spl) {
                  final ctrl = _getSpecialLoanCtrl(spl.specialLoanTypeId);
                  final splPayment = double.tryParse(ctrl.text) ?? 0.0;
                  final baseSplBal = isCompleted
                      ? (spl.currentBalance + spl.lastRepaymentAmount)
                      : spl.currentBalance;
                  final updatedSplBal = baseSplBal - splPayment;
                  final updatedSplText = splPayment > 0
                      ? (isMl
                            ? 'പുതിയ ബാക്കി തുക: ₹${updatedSplBal.toStringAsFixed(2)}'
                            : 'Updated Balance: ₹${updatedSplBal.toStringAsFixed(2)}')
                      : null;

                  return _buildInputField(
                    title:
                        '${spl.specialLoanTypeName} ${l10n.locale.languageCode == 'ml' ? 'അടവ്' : 'Repayment'}',
                    controller: ctrl,
                    color: Colors.deepOrange,
                    badgeText:
                        '${l10n.locale.languageCode == 'ml' ? 'ബാക്കി' : 'Bal'}: ₹${baseSplBal.toStringAsFixed(2)}',
                    badgeColor: Colors.deepOrange,
                    badgeIcon: Icons.card_giftcard_rounded,
                    updatedText: updatedSplText,
                    readOnly: isReadOnly,
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.arrow_circle_down_rounded,
                        color: Colors.deepOrange,
                      ),
                      onPressed: () {
                        ctrl.text = baseSplBal.toStringAsFixed(2);
                      },
                    ),
                  );
                }),

                _buildInputField(
                  title: l10n.translate('fine_payment'),
                  controller: _finePaymentCtrl,
                  color: AppColors.accountFine,
                  badgeText:
                      '${isMl ? "നിലവിലെ പിഴ" : "Current Fine"}: ₹${baseFine.toStringAsFixed(2)}',
                  badgeColor: AppColors.accountFine,
                  badgeIcon: Icons.gavel_rounded,
                  updatedText: updatedFineText,
                  readOnly: isReadOnly || baseFine <= 0,
                  suffixIcon: baseFine > 0
                      ? IconButton(
                          icon: const Icon(
                            Icons.arrow_circle_down_rounded,
                            color: AppColors.accountFine,
                          ),
                          tooltip: isMl
                              ? 'മുഴുവൻ പിഴയും അടയ്ക്കുക'
                              : 'Pay Full Fine',
                          onPressed: () {
                            _finePaymentCtrl.text = baseFine.toStringAsFixed(2);
                          },
                        )
                      : null,
                ),

                _buildInputField(
                  title: l10n.translate('contribution_addition'),
                  controller: _monthlyContributionCtrl,
                  color: AppColors.accountContribution,
                  badgeText:
                      '${l10n.translate('total')}: ₹${baseContribution.toStringAsFixed(2)}',
                  badgeColor: AppColors.accountContribution,
                  badgeIcon: Icons.calendar_today_rounded,
                  updatedText: updatedContributionText,
                  readOnly: isReadOnly,
                ),

                TextField(
                  controller: _notesCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.translate('notes_remarks'),
                    prefixIcon: const Icon(Icons.note_alt_rounded),
                  ),
                ),
                const SizedBox(height: 20),

                if (totalCollectionToday > 0)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            l10n.locale.languageCode == 'ml'
                                ? 'ഇന്നത്തെ ആകെ ശേഖരണം'
                                : 'Total Collection Today',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        Text(
                          '₹${totalCollectionToday.toStringAsFixed(2)}',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Consumer<MemberProcessingViewModel>(
        builder: (context, vm, _) {
          if (vm.loadState.isLoading || vm.formData == null) {
            return const SizedBox.shrink();
          }
          final data = vm.formData!;
          final isCompleted = data.processingStatus == 'COMPLETED';
          final isMl = l10n.locale.languageCode == 'ml';
          final baseFine = isCompleted
              ? (data.fineRemaining + data.lastFinePayment)
              : data.fineRemaining;

          final buttonColor = isCompleted && !_isEditMode
              ? Colors.orange.shade800
              : AppColors.primary;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: vm.submitState.isLoading
                      ? null
                      : () async {
                          if (isCompleted && !_isEditMode) {
                            setState(() {
                              _isEditMode = true;
                            });
                            return;
                          }

                          final enteredFine =
                              double.tryParse(_finePaymentCtrl.text) ?? 0.0;
                          if (enteredFine > 0 && baseFine <= 0) {
                            AppSnackbar.showError(
                              context,
                              isMl
                                  ? 'നിലവിൽ പിഴയില്ലാത്തതിനാൽ പിഴ തിരിച്ചടവ് സാധ്യമല്ല'
                                  : 'Cannot repay fine when current fine is ₹0.00',
                            );
                            return;
                          }
                          if (enteredFine > baseFine && baseFine > 0) {
                            AppSnackbar.showError(
                              context,
                              isMl
                                  ? 'പിഴ അടവ് തുക നിലവിലെ പിഴയെക്കാൾ കൂടുതലാണ്'
                                  : 'Fine repayment cannot exceed current fine (₹)',
                            );
                            return;
                          }
                          final interestPeriodToUse =
                              data.activeInterestPeriod ??
                              (data.pendingInterestPeriods.isNotEmpty
                                  ? data.pendingInterestPeriods.first
                                  : null);

                          final success = await vm.submitProcessing(
                            meetingId: widget.meetingId,
                            memberId: widget.memberId,
                            loanRepayment:
                                double.tryParse(_loanRepaymentCtrl.text) ?? 0.0,
                            interestPayment: 0.0,
                            depositAddition:
                                double.tryParse(_depositAdditionCtrl.text) ??
                                0.0,
                            finePayment:
                                double.tryParse(_finePaymentCtrl.text) ?? 0.0,

                            monthlyContributionAddition:
                                double.tryParse(
                                  _monthlyContributionCtrl.text,
                                ) ??
                                0.0,
                            specialLoanRepayments: data.specialLoanBalances
                                .map((spl) {
                                  final c =
                                      _specialLoanCtrls[spl.specialLoanTypeId];
                                  final amt = c != null
                                      ? (double.tryParse(c.text) ?? 0.0)
                                      : 0.0;
                                  return {
                                    'specialLoanTypeId': spl.specialLoanTypeId,
                                    'amount': amt,
                                  };
                                })
                                .where((e) => (e['amount'] as double) > 0)
                                .toList(),
                            notes: _notesCtrl.text.trim().isEmpty
                                ? null
                                : _notesCtrl.text.trim(),
                            transactionDate:
                                widget.meetingDate ??
                                _selectedTransactionDate
                                    .toIso8601String()
                                    .split("T")[0],
                            isUpdate: isCompleted,
                            interestPeriod: interestPeriodToUse,
                          );

                          if (context.mounted) {
                            if (success) {
                              AppSnackbar.showSuccess(
                                context,
                                isCompleted
                                    ? (isMl
                                          ? 'അടവുകൾ വിജയകരമായി പുതുക്കി!'
                                          : 'Payment updated successfully!')
                                    : (vm.submitState.message ??
                                          'Member payment recorded successfully'),
                              );
                              Navigator.pop(context, true);
                            } else {
                              AppSnackbar.showError(
                                context,
                                vm.submitState.message ?? 'Submission failed',
                              );
                            }
                          }
                        },
                  child: vm.submitState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isCompleted
                                  ? (_isEditMode
                                        ? Icons.save_rounded
                                        : Icons.edit_note_rounded)
                                  : Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isCompleted
                                  ? (_isEditMode
                                        ? (isMl
                                              ? 'പുതുക്കിയ അടവുകൾ സമർപ്പിക്കുക'
                                              : 'Submit Updated Payment')
                                        : (isMl
                                              ? 'അടവ് പുതുക്കുക / തിരുത്തുക'
                                              : 'Update / Edit Payment'))
                                  : l10n.translate('submit_payments'),
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMemberBanner(
    MemberProcessingDataModel data,
    AppLocalizations l10n,
  ) {
    final statusKey = 'status_${data.processingStatus.toLowerCase()}';
    final translatedStatus = l10n.translate(statusKey);
    final statusText = (translatedStatus != statusKey)
        ? translatedStatus
        : data.processingStatus;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            child: Text(
              data.memberNumber,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.fullName,
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${l10n.translate('processing_status')}: $statusText',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestRequiredWarning(
    MemberProcessingDataModel data,
    AppLocalizations l10n,
  ) {
    final periodText =
        data.activeInterestPeriod ??
        (data.pendingInterestPeriods.isNotEmpty
            ? data.pendingInterestPeriods.join(", ")
            : "current period");

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.locale.languageCode == 'ml'
                      ? '$periodText കാലയളവിലേക്ക് തിരിച്ചടവ് രേഖപ്പെടുത്തുന്നതിന് മുൻപ് പലിശ കണക്കാക്കണം.'
                      : 'Interest calculation required for period $periodText before processing repayments.',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Selector<MemberProcessingViewModel, bool>(
              selector: (_, vm) => vm.submitState.isLoading,
              builder: (context, isLoading, _) {
                return ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.calculate_rounded, size: 18),
                  label: Text(
                    isLoading
                        ? l10n.translate('calculating')
                        : l10n.translate('calculate_interest_button'),
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () => _calculateInterestDirectly(context, data, l10n),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _calculateInterestDirectly(
    BuildContext context,
    MemberProcessingDataModel data,
    AppLocalizations l10n,
  ) async {
    final period =
        data.activeInterestPeriod ??
        (data.pendingInterestPeriods.isNotEmpty
            ? data.pendingInterestPeriods.first
            : '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}');

    final success = await context
        .read<MemberProcessingViewModel>()
        .calculateInterest(
          widget.memberId,
          period,
          meetingId: widget.meetingId,
        );

    if (context.mounted) {
      if (success) {
        final successMsg = l10n.locale.languageCode == 'ml'
            ? '$period കാലയളവിലേക്ക് 1% പലിശ കണക്കാക്കി വായ്പയിൽ ചേർത്തു!'
            : '1% Interest calculated & added to loan balance for $period!';
        AppSnackbar.showSuccess(context, successMsg);
        final vm = context.read<MemberProcessingViewModel>();

        await vm.fetchProcessingForm(widget.meetingId, widget.memberId);

        if (!mounted) return;

        final refreshedData = vm.formData;
        if (refreshedData != null &&
            refreshedData.processingStatus == 'COMPLETED') {
          _populateControllers(refreshedData);
          _isInitialized = true;
        }
      } else {
        AppSnackbar.showError(
          context,
          context.read<MemberProcessingViewModel>().submitState.message ??
              'Calculation failed',
        );
      }
    }
  }

  Widget _buildInputField({
    required String title,
    required TextEditingController controller,
    required Color color,
    String? badgeText,
    Color? badgeColor,
    IconData? badgeIcon,
    Widget? suffixIcon,
    String? updatedText,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              if (badgeText != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? color).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (badgeIcon != null) ...[
                        Icon(badgeIcon, size: 13, color: badgeColor ?? color),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        badgeText,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: badgeColor ?? color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            readOnly: readOnly,
            enabled: !readOnly,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              suffixIcon: suffixIcon,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: color, width: 1.8),
              ),
            ),
          ),
          if (updatedText != null && updatedText.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.trending_flat_rounded,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    updatedText,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
