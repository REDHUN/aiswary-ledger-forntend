import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/model/completed_meeting_register_model.dart';
import '../../core/model/meeting_model.dart';
import '../../core/repository/meeting_repository.dart';
import '../../core/di/service_locator.dart';
import '../../viewmodel/meeting_viewmodel.dart';

class MeetingRegisterBookScreen extends StatefulWidget {
  const MeetingRegisterBookScreen({super.key});

  @override
  State<MeetingRegisterBookScreen> createState() => _MeetingRegisterBookScreenState();
}

class _MeetingRegisterBookScreenState extends State<MeetingRegisterBookScreen> {
  MeetingModel? _selectedMeeting;
  CompletedMeetingRegisterModel? _registerData;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initMeetingData();
    });
  }

  Future<void> _initMeetingData() async {
    final meetingVm = context.read<MeetingViewModel>();
    if (meetingVm.meetings.isEmpty) {
      await meetingVm.fetchMeetings();
    }
    if (meetingVm.meetings.isNotEmpty) {
      final initial = meetingVm.meetings.firstWhere(
        (m) => m.status == 'COMPLETED',
        orElse: () => meetingVm.meetings.first,
      );
      setState(() {
        _selectedMeeting = initial;
      });
      _loadRegisterBook(initial.id);
    }
  }

  Future<void> _loadRegisterBook(int meetingId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final repo = sl<MeetingRepository>();
      final data = await repo.getMeetingRegisterBook(meetingId);
      if (mounted) {
        setState(() {
          _registerData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          'രജിസ്റ്റർ ബുക്ക് (Register Book)',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<MeetingViewModel>(
        builder: (context, meetingVm, _) {
          final meetings = meetingVm.meetings;

          if (meetingVm.loadState.isLoading && meetings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meeting Selector Dropdown
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.borderLight),
                  ),
                  color: AppColors.bgCard,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.history_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'മീറ്റിംഗ് തിരഞ്ഞെടുക്കുക (Select Meeting):',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<MeetingModel>(
                          initialValue: _selectedMeeting,
                          isExpanded: true,
                          decoration: InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: meetings.map((m) {
                            return DropdownMenuItem<MeetingModel>(
                              value: m,
                              child: Text(
                                'Meeting #${m.meetingNumber} (${m.meetingDate}) [${m.status}]',
                                style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedMeeting = val;
                              });
                              _loadRegisterBook(val.id);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                if (_isLoading)
                  const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                else if (_errorMessage != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(_errorMessage!, style: GoogleFonts.outfit(color: Colors.red)),
                    ),
                  )
                else if (_registerData != null)
                  _buildRegisterBookDetails(context, _registerData!)
                else
                  Center(child: Text('മീറ്റിംഗ് ഡാറ്റ ലഭ്യമല്ല', style: GoogleFonts.outfit())),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRegisterBookDetails(BuildContext context, CompletedMeetingRegisterModel reg) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'മീറ്റിംഗ് രജിസ്റ്റർ ബുക്ക്',
                          style: GoogleFonts.outfit(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    'മീറ്റിംഗ് #${reg.meetingNumber}',
                    style: GoogleFonts.outfit(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'തീയതി: ${reg.meetingDate} | പിരീഡ്: ${reg.interestPeriod}',
              style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12),
            ),
            const Divider(color: AppColors.borderLight, height: 24),
            
            // Collection Items Breakdown
            _buildDetailRow('വായ്പ തിരികെ അടവ് (Loan Repayments)', reg.totalLoanRepaymentsCollected, AppColors.success),
            const SizedBox(height: 10),
            _buildDetailRow('നിക്ഷേപം (Deposits)', reg.totalDepositsCollected, AppColors.info),
            const SizedBox(height: 10),
            _buildDetailRow('പ്രതിമാസ വരിസംഖ്യ (Monthly Contribution)', reg.totalMonthlyContributionsCollected, AppColors.accountContribution),
            const SizedBox(height: 10),
            if (reg.specialLoanBreakdown.isNotEmpty) ...[
              for (var item in reg.specialLoanBreakdown) ...[
                _buildDetailRow('${item.specialLoanTypeName} അടവ്', item.amount, AppColors.accountFinancialAid),
                const SizedBox(height: 10),
              ]
            ] else ...[
              _buildDetailRow('പ്രത്യേക വായ്പ തിരികെ അടവ്', reg.totalSpecialLoanRepaymentsCollected, AppColors.accountFinancialAid),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 10),
            _buildDetailRow('പിഴ (Fines)', reg.totalFinesCollected, AppColors.accountFine),
            const SizedBox(height: 10),
            _buildDetailRow('സാമ്പത്തിക സഹായം (Financial Aid -)', reg.totalFinancialAidDisbursed, AppColors.error),
            if (reg.totalGroupExpenses > 0) ...[
              const SizedBox(height: 10),
              _buildDetailRow('ഗ്രൂപ്പ് ചെലവുകൾ (Group Expenses -)', reg.totalGroupExpenses, Colors.deepOrangeAccent),
            ],
            
            const Divider(color: AppColors.borderLight, height: 24),

            // Summary Totals Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'ആകെ സ്വീകരിച്ച തുക (Net Collection):',
                          style: GoogleFonts.outfit(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${reg.totalNetMeetingCollections.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'മിച്ച തുക (Surplus Fund):',
                          style: GoogleFonts.outfit(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${reg.surplusAmount.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, double amount, Color amountColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.outfit(color: AppColors.textDark, fontSize: 13, fontWeight: FontWeight.w500),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(color: amountColor, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
