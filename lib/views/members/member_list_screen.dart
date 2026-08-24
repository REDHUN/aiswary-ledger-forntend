import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/common/common_error_widget.dart';
import '../../viewmodel/member_viewmodel.dart';
import 'member_detail_screen.dart';
import 'add_member_dialog.dart';
import '../../core/common/app_shimmer.dart';
import '../../core/localization/app_localizations.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MemberViewModel>().fetchMembers();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Consumer<MemberViewModel>(
        builder: (context, vm, _) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                color: Colors.white,
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.outfit(fontSize: 14, color: AppColors.textDark),
                  decoration: InputDecoration(
                    hintText: l10n.locale.languageCode == 'ml'
                        ? 'അംഗത്തിൻ്റെ പേര്, നമ്പർ, ഫോൺ തിരയുക...'
                        : 'Search member by name, number, phone...',
                    hintStyle: GoogleFonts.outfit(fontSize: 13, color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              vm.fetchMembers(query: '');
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
                    vm.fetchMembers(query: val);
                  },
                ),
              ),
              const Divider(height: 1, color: AppColors.borderLight),
              Expanded(
                child: _buildMemberList(context, vm, l10n),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'member_list_fab',
        onPressed: () {
          showDialog(context: context, builder: (_) => const AddMemberDialog());
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text(
          l10n.translate('new_member'),
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMemberList(BuildContext context, MemberViewModel vm, AppLocalizations l10n) {
    if (vm.loadState.isLoading) {
      return const MemberListShimmerLoading();
    }

    if (vm.loadState.hasError) {
      return CommonErrorWidget(
        message: vm.loadState.message ?? 'Failed to load members',
        onRetry: () => vm.fetchMembers(),
      );
    }

    final members = vm.members;
    if (members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_search_rounded, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              l10n.translate('no_members'),
              style: GoogleFonts.outfit(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => vm.fetchMembers(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.borderLight)),
            elevation: 0,
            color: Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  member.memberNumber,
                  style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
              title: Text(
                member.fullName,
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              subtitle: Text(
                member.phone ?? l10n.translate('no_phone'),
                style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textMuted),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MemberDetailScreen(memberId: member.id)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
