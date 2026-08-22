import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ashgledger/core/theme/app_colors.dart';
import 'package:ashgledger/core/common/common_error_widget.dart';
import 'package:ashgledger/core/common/app_snackbar.dart';
import 'package:ashgledger/viewmodel/member_processing_viewmodel.dart';
import 'package:ashgledger/core/model/member_processing_data_model.dart';

class MemberProcessingScreen extends StatefulWidget {
  final int meetingId;
  final int memberId;

  const MemberProcessingScreen({
    super.key,
    required this.meetingId,
    required this.memberId,
  });

  @override
  State<MemberProcessingScreen> createState() => _MemberProcessingScreenState();
}

class _MemberProcessingScreenState extends State<MemberProcessingScreen> {
  final _loanRepaymentCtrl = TextEditingController();
  final _depositAdditionCtrl = TextEditingController();
  final _finePaymentCtrl = TextEditingController();
  final _financialAidPaymentCtrl = TextEditingController();
  final _monthlyContributionCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MemberProcessingViewModel>().fetchProcessingForm(widget.meetingId, widget.memberId);
    });
  }

  @override
  void dispose() {
    _loanRepaymentCtrl.dispose();
    _depositAdditionCtrl.dispose();
    _finePaymentCtrl.dispose();
    _financialAidPaymentCtrl.dispose();
    _monthlyContributionCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Collection Form'),
      ),
      body: Consumer<MemberProcessingViewModel>(
        builder: (context, vm, _) {
          if (vm.loadState.isLoading) return const Center(child: CircularProgressIndicator());
          if (vm.loadState.hasError) {
            return CommonErrorWidget(
              message: vm.loadState.message ?? 'Failed to load form',
              onRetry: () => vm.fetchProcessingForm(widget.meetingId, widget.memberId),
            );
          }

          final data = vm.formData;
          if (data == null) return const SizedBox.shrink();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMemberBanner(data),
                const SizedBox(height: 16),
                if (data.interestCalculationRequired && !data.interestCalculated)
                  _buildInterestRequiredWarning(data),
                const SizedBox(height: 20),
                Text('Financial Collection Entries', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 14),

                _buildInputField(
                  title: 'Loan Repayment (₹)',
                  controller: _loanRepaymentCtrl,
                  color: AppColors.accountLoan,
                  badgeText: 'Bal: ₹${data.loanRemaining.toStringAsFixed(2)}',
                  badgeColor: AppColors.accountLoan,
                  badgeIcon: Icons.account_balance_wallet_rounded,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_circle_down_rounded, color: AppColors.accountLoan),
                    tooltip: 'Pay Full Loan',
                    onPressed: () {
                      _loanRepaymentCtrl.text = data.loanRemaining.toStringAsFixed(2);
                    },
                  ),
                ),

                _buildInputField(
                  title: 'Savings Deposit Addition (₹)',
                  controller: _depositAdditionCtrl,
                  color: AppColors.accountDeposit,
                  badgeText: 'Current: ₹${data.depositCurrent.toStringAsFixed(2)}',
                  badgeColor: AppColors.accountDeposit,
                  badgeIcon: Icons.savings_rounded,
                ),

                _buildInputField(
                  title: 'Fine Payment (₹)',
                  controller: _finePaymentCtrl,
                  color: AppColors.accountFine,
                  badgeText: 'Due: ₹${data.fineRemaining.toStringAsFixed(2)}',
                  badgeColor: AppColors.accountFine,
                  badgeIcon: Icons.gavel_rounded,
                ),

                _buildInputField(
                  title: 'Financial Aid Payment (₹)',
                  controller: _financialAidPaymentCtrl,
                  color: AppColors.accountFinancialAid,
                  badgeText: 'Due: ₹${data.financialAidRemaining.toStringAsFixed(2)}',
                  badgeColor: AppColors.accountFinancialAid,
                  badgeIcon: Icons.volunteer_activism_rounded,
                ),

                _buildInputField(
                  title: 'Monthly Contribution Addition (₹)',
                  controller: _monthlyContributionCtrl,
                  color: AppColors.accountContribution,
                  badgeText: 'Total: ₹${data.monthlyContributionCurrent.toStringAsFixed(2)}',
                  badgeColor: AppColors.accountContribution,
                  badgeIcon: Icons.calendar_today_rounded,
                ),

                TextField(
                  controller: _notesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Notes / Remarks (Optional)',
                    prefixIcon: Icon(Icons.note_alt_rounded),
                  ),
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: vm.submitState.isLoading
                        ? null
                        : () async {
                            final success = await vm.submitProcessing(
                              meetingId: widget.meetingId,
                              memberId: widget.memberId,
                              loanRepayment: double.tryParse(_loanRepaymentCtrl.text) ?? 0.0,
                              interestPayment: 0.0,
                              depositAddition: double.tryParse(_depositAdditionCtrl.text) ?? 0.0,
                              finePayment: double.tryParse(_finePaymentCtrl.text) ?? 0.0,
                              financialAidPayment: double.tryParse(_financialAidPaymentCtrl.text) ?? 0.0,
                              monthlyContributionAddition: double.tryParse(_monthlyContributionCtrl.text) ?? 0.0,
                              notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
                            );

                            if (context.mounted) {
                              if (success) {
                                AppSnackbar.showSuccess(context, 'Member processing recorded successfully!');
                                Navigator.pop(context);
                              } else {
                                AppSnackbar.showError(context, vm.submitState.message ?? 'Submission failed');
                              }
                            }
                          },
                    child: vm.submitState.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('Submit Collections', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMemberBanner(MemberProcessingDataModel data) {
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
            child: Text(data.memberNumber, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.fullName, style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text('Processing Status: ${data.processingStatus}', style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestRequiredWarning(MemberProcessingDataModel data) {
    final periodText = data.activeInterestPeriod ??
        (data.pendingInterestPeriods.isNotEmpty ? data.pendingInterestPeriods.join(", ") : "current period");

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
              const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Interest calculation required for period $periodText before processing repayments.',
                  style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textDark, fontWeight: FontWeight.w500, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.calculate_rounded, size: 18),
              label: Text('Calculate Interest', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
              onPressed: () => _showInterestDialog(context, data),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String title,
    required TextEditingController controller,
    required Color color,
    String? badgeText,
    Color? badgeColor,
    IconData? badgeIcon,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
              ),
              if (badgeText != null)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: (badgeColor ?? color).withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (badgeIcon != null) ...[
                          Icon(badgeIcon, size: 12, color: badgeColor ?? color),
                          const SizedBox(width: 4),
                        ],
                        Flexible(
                          child: Text(
                            badgeText,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: badgeColor ?? color,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: '0.00',
              prefixIcon: Icon(Icons.payments_rounded, color: color),
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
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
        ],
      ),
    );
  }

  void _showInterestDialog(BuildContext context, MemberProcessingDataModel data) {
    final defaultPeriod = data.activeInterestPeriod ??
        (data.pendingInterestPeriods.isNotEmpty
            ? data.pendingInterestPeriods.first
            : '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}');
    final periodCtrl = TextEditingController(text: defaultPeriod);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Calculate 1% Interest', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calculate 1% monthly interest for ${data.fullName}. Calculated interest will be added directly to the loan balance.',
              style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: periodCtrl,
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                labelText: 'Interest Period (YYYY-MM)',
                prefixIcon: Icon(Icons.calendar_month_rounded, color: AppColors.primary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: GoogleFonts.outfit(color: AppColors.primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final period = periodCtrl.text.trim();
              if (period.isEmpty) return;
              Navigator.pop(dialogContext);

              final success = await context.read<MemberProcessingViewModel>().calculateInterest(
                    widget.memberId,
                    period,
                    meetingId: widget.meetingId,
                  );
              if (context.mounted) {
                if (success) {
                  AppSnackbar.showSuccess(context, 'Interest calculated & added to loan balance for $period!');
                  context.read<MemberProcessingViewModel>().fetchProcessingForm(widget.meetingId, widget.memberId);
                } else {
                  AppSnackbar.showError(
                    context,
                    context.read<MemberProcessingViewModel>().submitState.message ?? 'Calculation failed',
                  );
                }
              }
            },
            child: Text('Calculate', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
