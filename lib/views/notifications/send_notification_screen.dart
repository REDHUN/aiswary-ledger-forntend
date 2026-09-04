import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/di/service_locator.dart';
import '../../core/model/member_model.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodel/language_viewmodel.dart';
import '../../viewmodel/member_viewmodel.dart';
import '../../viewmodel/notification_viewmodel.dart';

class SendNotificationScreen extends StatelessWidget {
  final String? initialTitle;
  final String? initialBody;
  final String? initialType;
  final int? initialMemberId;

  const SendNotificationScreen({
    super.key,
    this.initialTitle,
    this.initialBody,
    this.initialType,
    this.initialMemberId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<NotificationViewModel>()),
        ChangeNotifierProvider(create: (_) => sl<MemberViewModel>()..fetchMembers()),
      ],
      child: _SendNotificationBody(
        initialTitle: initialTitle,
        initialBody: initialBody,
        initialType: initialType,
        initialMemberId: initialMemberId,
      ),
    );
  }
}

class _SendNotificationBody extends StatefulWidget {
  final String? initialTitle;
  final String? initialBody;
  final String? initialType;
  final int? initialMemberId;

  const _SendNotificationBody({
    this.initialTitle,
    this.initialBody,
    this.initialType,
    this.initialMemberId,
  });

  @override
  State<_SendNotificationBody> createState() => _SendNotificationBodyState();
}

class _SendNotificationBodyState extends State<_SendNotificationBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late final TextEditingController _refIdController;

  String _selectedType = 'ANNOUNCEMENT';
  int? _selectedTemplateIndex;
  bool _isBroadcast = true;
  MemberModel? _selectedMember;

  final List<Map<String, dynamic>> _types = [
    {
      'value': 'ANNOUNCEMENT',
      'labelEn': 'Announcement',
      'labelMl': 'പൊതു അറിയിപ്പ്',
      'icon': Icons.campaign_rounded,
      'color': Colors.purple,
    },
    {
      'value': 'MEETING',
      'labelEn': 'Meeting Notice',
      'labelMl': 'യോഗ അറിയിപ്പ്',
      'icon': Icons.event_note_rounded,
      'color': Colors.blue,
    },
    {
      'value': 'PAYMENT',
      'labelEn': 'Payment Reminder',
      'labelMl': 'അടവ് ഓർമ്മപ്പെടുത്തൽ',
      'icon': Icons.account_balance_wallet_rounded,
      'color': Colors.green,
    },
    {
      'value': 'LOAN',
      'labelEn': 'Loan Update',
      'labelMl': 'വായ്പ അറിയിപ്പ്',
      'icon': Icons.monetization_on_rounded,
      'color': Colors.amber.shade800,
    },
    {
      'value': 'FINE',
      'labelEn': 'Fine Alert',
      'labelMl': 'പിഴ അറിയിപ്പ്',
      'icon': Icons.warning_amber_rounded,
      'color': Colors.redAccent,
    },
    {
      'value': 'GENERAL',
      'labelEn': 'General Notice',
      'labelMl': 'സാധാരണ അറിയിപ്പ്',
      'icon': Icons.notifications_rounded,
      'color': Colors.blueGrey,
    },
    {
      'value': 'TEST',
      'labelEn': 'Test Notification',
      'labelMl': 'ടെസ്റ്റ് അറിയിപ്പ്',
      'icon': Icons.bug_report_rounded,
      'color': Colors.teal,
    },
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _bodyController = TextEditingController(text: widget.initialBody ?? '');
    _refIdController = TextEditingController();

    if (widget.initialType != null && widget.initialType!.isNotEmpty) {
      _selectedType = widget.initialType!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _refIdController.dispose();
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

    if (!_isBroadcast && _selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isMl ? 'ദയവായി ഒരു അംഗത്തെ തിരഞ്ഞെടുക്കുക' : 'Please select a member',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final targetDesc = _isBroadcast
        ? (isMl
            ? 'എല്ലാ രജിസ്റ്റർ ചെയ്ത അംഗങ്ങളുടെ ഫോണുകളിലേക്കും'
            : 'to all registered member devices')
        : (isMl
            ? '${_selectedMember!.fullName} എന്ന അംഗത്തിന്റെ ഫോണിലേക്ക്'
            : 'to ${_selectedMember!.fullName}');

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
                isMl ? 'അറിയിപ്പ് അയക്കണോ?' : 'Send Notification?',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          isMl
              ? 'ഈ അറിയിപ്പ് $targetDesc തത്സമയം അയക്കുന്നതാണ്. തുടരണോ?'
              : 'This notification will be sent $targetDesc immediately. Continue?',
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
    final refId = int.tryParse(_refIdController.text.trim());

    final success = await vm.sendNotification(
      userId: _isBroadcast ? null : _selectedMember?.id,
      broadcast: _isBroadcast,
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      notificationType: _selectedType,
      referenceId: refId,
    );

    if (!context.mounted) return;

    if (success) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isMl ? 'വിജയകരം!' : 'Success!',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
          content: Text(
            isMl
                ? 'അറിയിപ്പ് വിജയകരമായി അയച്ചു.'
                : 'Notification sent successfully.',
            style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textDark),
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            vm.loadState.message ?? (isMl ? 'അറിയിപ്പ് അയക്കാൻ കഴിഞ്ഞില്ല' : 'Failed to send notification'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleTestMyDevice(BuildContext context, bool isMl) async {
    final vm = context.read<NotificationViewModel>();
    final success = await vm.sendTestToMyDevice();

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isMl ? 'ടെസ്റ്റ് അറിയിപ്പ് ഫോണിലേക്ക് അയച്ചു!' : 'Test notification sent to your device!',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            vm.loadState.message ?? (isMl ? 'ടെസ്റ്റ് പരാജയപ്പെട്ടു' : 'Test notification failed'),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMl = context.watch<LanguageViewModel>().isMalayalam;
    final notifVm = context.watch<NotificationViewModel>();
    final memberVm = context.watch<MemberViewModel>();
    final isLoading = notifVm.loadState.isLoading;

    // Set initial member if provided and not yet set
    if (widget.initialMemberId != null &&
        _selectedMember == null &&
        memberVm.members.isNotEmpty) {
      final found = memberVm.members.where((m) => m.id == widget.initialMemberId).firstOrNull;
      if (found != null) {
        _isBroadcast = false;
        _selectedMember = found;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: Text(
          isMl ? 'അറിയിപ്പുകൾ അയക്കുക' : 'Send Notification',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.phonelink_ring_rounded),
            tooltip: isMl ? 'എന്റെ ഫോണിൽ ടെസ്റ്റ് ചെയ്യുക' : 'Test on My Device',
            onPressed: isLoading ? null : () => _handleTestMyDevice(context, isMl),
          ),
        ],
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
                          isMl ? 'പുഷ് അറിയിപ്പുകൾ' : 'Push Notification Hub',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isMl
                              ? 'എല്ലാ അംഗങ്ങൾക്കോ അല്ലെങ്കിൽ ഒരു പ്രത്യേക അംഗത്തിനോ അറിയിപ്പുകൾ ഉടൻ അയക്കാം.'
                              : 'Send instant push alerts to all members or a specific member.',
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

            // Target Audience Selector
            Text(
              isMl ? 'ലക്ഷ്യം (Target Audience)' : 'Target Audience',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isBroadcast = true),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      decoration: BoxDecoration(
                        color: _isBroadcast ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isBroadcast ? AppColors.primary : AppColors.borderLight,
                          width: _isBroadcast ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.groups_rounded,
                            size: 20,
                            color: _isBroadcast ? AppColors.primary : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isMl ? 'എല്ലാവർക്കും' : 'All (Broadcast)',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: _isBroadcast ? FontWeight.bold : FontWeight.w500,
                              color: _isBroadcast ? AppColors.primary : AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isBroadcast = false),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      decoration: BoxDecoration(
                        color: !_isBroadcast ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: !_isBroadcast ? AppColors.primary : AppColors.borderLight,
                          width: !_isBroadcast ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_rounded,
                            size: 20,
                            color: !_isBroadcast ? AppColors.primary : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isMl ? 'പ്രത്യേക അംഗം' : 'Specific Member',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: !_isBroadcast ? FontWeight.bold : FontWeight.w500,
                              color: !_isBroadcast ? AppColors.primary : AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Member Dropdown if Specific Member is selected
            if (!_isBroadcast) ...[
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.borderLight),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<MemberModel>(
                      value: _selectedMember,
                      hint: Text(
                        isMl ? 'അംഗത്തെ തിരഞ്ഞെടുക്കുക' : 'Select a Member',
                        style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMuted),
                      ),
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
                      items: memberVm.members.map((member) {
                        return DropdownMenuItem<MemberModel>(
                          value: member,
                          child: Text(
                            '#${member.memberNumber} - ${member.fullName}',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (m) => setState(() => _selectedMember = m),
                    ),
                  ),
                ),
              ),
            ],

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
                              value: type['value'] as String,
                              child: Row(
                                children: [
                                  Icon(
                                    type['icon'] as IconData,
                                    size: 18,
                                    color: type['color'] as Color,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isMl ? type['labelMl'] as String : type['labelEn'] as String,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ],
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
                            : 'Enter the message content to send...',
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

                    // Optional Reference ID
                    if (_selectedType == 'MEETING' ||
                        _selectedType == 'PAYMENT' ||
                        _selectedType == 'LOAN') ...[
                      const SizedBox(height: 12),
                      Text(
                        isMl
                            ? 'റഫറൻസ് ഐഡി (Reference ID - Optional)'
                            : 'Reference ID (Optional)',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _refIdController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: isMl
                              ? 'ഉദാ: മീറ്റിംഗ് അല്ലെങ്കിൽ ട്രാൻസാക്ഷൻ ഐഡി'
                              : 'e.g. Meeting ID, Transaction ID, or Loan ID',
                          hintStyle: GoogleFonts.outfit(color: AppColors.textMuted, fontSize: 13),
                          prefixIcon: const Icon(Icons.tag_rounded, color: AppColors.primary),
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
                      ),
                    ],
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
                border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha: 0.3),
                  width: 1.2,
                ),
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
                    : (_isBroadcast
                        ? (isMl ? 'എല്ലാവർക്കും അയക്കുക (Send Broadcast)' : 'Send Broadcast Notification')
                        : (isMl ? 'അംഗത്തിന് അയക്കുക (Send to Member)' : 'Send to Member')),
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
