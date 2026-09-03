import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/di/service_locator.dart';
import '../../core/model/broadcast_notification_model.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodel/language_viewmodel.dart';
import '../../viewmodel/notification_viewmodel.dart';

class SendNotificationScreen extends StatelessWidget {
  final String? initialTitle;
  final String? initialBody;
  final String? initialType;

  const SendNotificationScreen({
    super.key,
    this.initialTitle,
    this.initialBody,
    this.initialType,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<NotificationViewModel>(),
      child: _SendNotificationBody(
        initialTitle: initialTitle,
        initialBody: initialBody,
        initialType: initialType,
      ),
    );
  }
}

class _SendNotificationBody extends StatefulWidget {
  final String? initialTitle;
  final String? initialBody;
  final String? initialType;

  const _SendNotificationBody({
    this.initialTitle,
    this.initialBody,
    this.initialType,
  });

  @override
  State<_SendNotificationBody> createState() => _SendNotificationBodyState();
}

class _SendNotificationBodyState extends State<_SendNotificationBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  String _selectedType = 'ANNOUNCEMENT';
  int? _selectedTemplateIndex;

  final List<Map<String, String>> _types = [
    {'value': 'ANNOUNCEMENT', 'labelEn': 'Announcement', 'labelMl': 'പൊതു അറിയിപ്പ്'},
    {'value': 'MEETING_REMINDER', 'labelEn': 'Meeting Reminder', 'labelMl': 'യോഗ അറിയിപ്പ്'},
    {'value': 'PAYMENT_REMINDER', 'labelEn': 'Payment Reminder', 'labelMl': 'അടവ് ഓർമ്മപ്പെടുത്തൽ'},
    {'value': 'SCHEDULE_UPDATE', 'labelEn': 'Schedule Update', 'labelMl': 'സമയ മാറ്റം'},
    {'value': 'GENERAL', 'labelEn': 'General Notice', 'labelMl': 'സാധാരണ അറിയിപ്പ്'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _bodyController = TextEditingController(text: widget.initialBody ?? '');
    if (widget.initialType != null && widget.initialType!.isNotEmpty) {
      _selectedType = widget.initialType!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _applyTemplate(NotificationTemplate template, int index, bool isMl) {
    setState(() {
      _selectedTemplateIndex = index;
      _titleController.text = isMl ? template.titleMl : template.titleEn;
      _bodyController.text = isMl ? template.bodyMl : template.bodyEn;
      _selectedType = template.type;
    });
  }

  Future<void> _handleSend(BuildContext context, bool isMl) async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.campaign_rounded, color: AppColors.primary, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isMl ? 'അറിയിപ്പ് അയക്കണോ?' : 'Send Broadcast Notification?',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          isMl
              ? 'ഈ അറിയിപ്പ് എല്ലാ രജിസ്റ്റർ ചെയ്ത അംഗങ്ങളുടെ ഫോണുകളിലേക്കും തത്സമയം അയക്കുന്നതാണ്. തുടരണോ?'
              : 'This notification will be broadcast to all registered member devices immediately. Continue?',
          style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isMl ? 'റദ്ദാക്കുക' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isMl ? 'അയക്കുക' : 'Send Now'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final vm = context.read<NotificationViewModel>();
    final result = await vm.sendBroadcast(
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      type: _selectedType,
    );

    if (!context.mounted) return;

    if (result != null) {
      _showResultDialog(context, result, isMl);
    } else if (vm.loadState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.loadState.message ?? (isMl ? 'അറിയിപ്പ് അയക്കാൻ കഴിഞ്ഞില്ല' : 'Failed to send broadcast')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showResultDialog(BuildContext context, BroadcastNotificationResult result, bool isMl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              result.failureCount == 0
                  ? Icons.check_circle_rounded
                  : (result.successCount > 0 ? Icons.info_rounded : Icons.error_rounded),
              color: result.failureCount == 0
                  ? AppColors.success
                  : (result.successCount > 0 ? Colors.orange : AppColors.error),
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isMl ? 'അറിയിപ്പ് സ്റ്റാറ്റസ്' : 'Broadcast Status',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.message ??
                    (isMl
                        ? 'അറിയിപ്പ് അയക്കൽ പ്രക്രിയ പൂർത്തിയായി.'
                        : 'Broadcast process completed.'),
                style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textDark),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    _buildStatRow(
                      isMl ? 'ലക്ഷ്യമിട്ട ഫോണുകൾ' : 'Total Targeted',
                      '${result.totalTargeted}',
                      Icons.devices_rounded,
                      Colors.blueGrey,
                    ),
                    const Divider(height: 16),
                    _buildStatRow(
                      isMl ? 'വിജയകരമായി ലഭിച്ചത്' : 'Success Count',
                      '${result.successCount}',
                      Icons.done_all_rounded,
                      AppColors.success,
                    ),
                    const Divider(height: 16),
                    _buildStatRow(
                      isMl ? 'പരാജയപ്പെട്ടത്' : 'Failed Count',
                      '${result.failureCount}',
                      Icons.warning_amber_rounded,
                      result.failureCount > 0 ? AppColors.error : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              if (result.errors.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  isMl ? 'വിശദാംശങ്ങൾ:' : 'Details:',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark),
                ),
                const SizedBox(height: 4),
                ...result.errors.map(
                  (err) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $err',
                      style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(isMl ? 'ശരി' : 'Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMl = context.watch<LanguageViewModel>().isMalayalam;
    final vm = context.watch<NotificationViewModel>();
    final isLoading = vm.loadState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text(
          isMl ? 'അറിയിപ്പുകൾ അയക്കുക' : 'Broadcast Notification',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Top Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.headerGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMl ? 'പുഷ് അറിയിപ്പുകൾ' : 'Instant Push Broadcast',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isMl
                              ? 'എല്ലാ അംഗങ്ങളുടെയും ഫോണുകളിലേക്ക് അറിയിപ്പുകൾ ഉടൻ എത്തിക്കാം.'
                              : 'Broadcast important alerts directly to all member devices.',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Templates Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isMl ? 'മാതൃകകൾ (Quick Templates)' : 'Quick Templates',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                if (_selectedTemplateIndex != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTemplateIndex = null;
                        _titleController.clear();
                        _bodyController.clear();
                        _selectedType = 'ANNOUNCEMENT';
                      });
                    },
                    child: Text(
                      isMl ? 'മായ്ക്കുക' : 'Clear',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(NotificationViewModel.templates.length, (index) {
                  final template = NotificationViewModel.templates[index];
                  final isSelected = _selectedTemplateIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        isMl ? template.labelMl : template.labelEn,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textDark,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.borderLight,
                        ),
                      ),
                      onSelected: (_) => _applyTemplate(template, index, isMl),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),

            // Notification Form Card
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.borderLight),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notification Type Selector
                    Text(
                      isMl ? 'അറിയിപ്പ് തരം (Type)' : 'Notification Type',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                        color: AppColors.bgLight,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedType,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
                          items: _types.map((type) {
                            return DropdownMenuItem<String>(
                              value: type['value'],
                              child: Text(
                                isMl ? type['labelMl']! : type['labelEn']!,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedType = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title Input
                    Text(
                      isMl ? 'തലക്കെട്ട് (Title)' : 'Title',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      maxLength: 100,
                      decoration: InputDecoration(
                        hintText: isMl ? 'ഉദാ: യോഗ അറിയിപ്പ്' : 'e.g. Important Announcement',
                        hintStyle: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 13),
                        prefixIcon: const Icon(Icons.title_rounded, color: AppColors.primary),
                        suffixIcon: _titleController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () => setState(() => _titleController.clear()),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: AppColors.bgLight,
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return isMl ? 'തലക്കെട്ട് നൽകുക' : 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Message / Body Input
                    Text(
                      isMl ? 'സന്ദേശം (Message Body)' : 'Message Body',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _bodyController,
                      maxLines: 4,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: isMl
                            ? 'അംഗങ്ങൾക്കായി സന്ദേശം ഇവിടെ എഴുതുക...'
                            : 'Enter the message content to broadcast...',
                        hintStyle: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 13),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 60),
                          child: Icon(Icons.message_rounded, color: AppColors.primary),
                        ),
                        suffixIcon: _bodyController.text.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 60),
                                child: IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () => setState(() => _bodyController.clear()),
                                ),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: AppColors.bgLight,
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return isMl ? 'സന്ദേശം നൽകുക' : 'Please enter message body';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Live Preview Section
            Text(
              isMl ? 'അറിയിപ്പ് പ്രിവ്യൂ (Live Preview)' : 'Live Notification Preview',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 14),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ഐശ്വര്യ സംഘം (Aiswarya Ledger)',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Just now',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _titleController.text.trim().isNotEmpty
                        ? _titleController.text.trim()
                        : (isMl ? '[തലക്കെട്ട് ഇവിടെ ദൃശ്യമാകും]' : '[Title preview]'),
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _titleController.text.trim().isNotEmpty
                          ? AppColors.textDark
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _bodyController.text.trim().isNotEmpty
                        ? _bodyController.text.trim()
                        : (isMl ? '[സന്ദേശം ഇവിടെ ദൃശ്യമാകും]' : '[Message preview]'),
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: _bodyController.text.trim().isNotEmpty
                          ? AppColors.textSecondary
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Send Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              onPressed: isLoading ? null : () => _handleSend(context, isMl),
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(
                isLoading
                    ? (isMl ? 'അയക്കുന്നു...' : 'Sending...')
                    : (isMl ? 'അറിയിപ്പ് അയക്കുക (Send Broadcast)' : 'Send Broadcast Notification'),
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
