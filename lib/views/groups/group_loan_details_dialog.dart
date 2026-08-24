import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/model/group_loan_summary_model.dart';

class GroupLoanDetailsDialog extends StatelessWidget {
  final GroupLoanSummaryModel loan;

  const GroupLoanDetailsDialog({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isMl = l10n.locale.languageCode == 'ml';

    final isSpecial = loan.accountType == 'SPECIAL_LOAN';
    final typeName = isSpecial ? (loan.specialLoanTypeName ?? 'Special Loan') : (isMl ? 'സാധാരണ വായ്പ' : 'Standard Loan');
    final double pct = loan.totalAmount > 0 ? (loan.totalRepaidAmount / loan.totalAmount).clamp(0.0, 1.0) : 0.0;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: isSpecial ? Colors.deepOrange.withValues(alpha: 0.12) : AppColors.primary.withValues(alpha: 0.12),
            child: Icon(
              isSpecial ? Icons.assignment_turned_in_rounded : Icons.monetization_on_rounded,
              color: isSpecial ? Colors.deepOrange : AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loan.groupName ?? 'Group Loan',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$typeName • ${loan.transactionDate}',
                  style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 1),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _buildStatTile(
                      isMl ? 'ആകെ വായ്പ' : 'Total Loan',
                      '₹${loan.totalAmount.toStringAsFixed(2)}',
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildStatTile(
                      isMl ? 'തിരിച്ചടച്ചത്' : 'Total Repaid',
                      '₹${loan.totalRepaidAmount.toStringAsFixed(2)}',
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _buildStatTile(
                      isMl ? 'ബാക്കി തുക' : 'Remaining',
                      '₹${loan.totalRemainingBalance.toStringAsFixed(2)}',
                      Colors.deepOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            isMl ? 'മൊത്തം തിരിച്ചടവ് പുരോഗതി' : 'Overall Repayment Progress',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(pct * 100).toStringAsFixed(1)}%',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                isMl ? 'അംഗങ്ങളുടെ തിരിച്ചടവ് വിവരങ്ങൾ (${loan.memberDetails.length}):' : 'Member Repayments (${loan.memberDetails.length}):',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),

              if (loan.memberDetails.isEmpty)
                Text(
                  isMl ? 'അംഗങ്ങളുടെ വിവരങ്ങൾ ലഭ്യമല്ല' : 'Member breakdown details not available',
                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: loan.memberDetails.length,
                  itemBuilder: (context, index) {
                    final item = loan.memberDetails[index];
                    final double memberPct = item.issuedAmount > 0 ? (item.repaidAmount / item.issuedAmount).clamp(0.0, 1.0) : 0.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: item.isFullyRepaid ? Colors.green.withValues(alpha: 0.4) : AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.memberNumber} - ${item.fullName}',
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (item.isFullyRepaid) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isMl ? 'പൂർത്തിയായി' : 'Paid',
                                    style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Issued: ₹${item.issuedAmount.toStringAsFixed(2)}',
                                    style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Repaid: ₹${item.repaidAmount.toStringAsFixed(2)}',
                                    style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'Due: ₹${item.currentBalance.toStringAsFixed(2)}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: item.currentBalance > 0 ? Colors.deepOrange : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: memberPct,
                              minHeight: 4,
                              backgroundColor: Colors.grey.shade100,
                              valueColor: AlwaysStoppedAnimation<Color>(item.isFullyRepaid ? Colors.green : AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(isMl ? 'അടയ്ക്കുക' : 'Close'),
        ),
      ],
    );
  }

  Widget _buildStatTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
