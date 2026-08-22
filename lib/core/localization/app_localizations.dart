import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? AppLocalizations(const Locale('ml'));
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'ml': {
      // General & Navigation
      'app_title': 'ഐശ്വര്യ സംഘം ലെഡ്ജർ',
      'dashboard': 'ഡാഷ്‌ബോർഡ്',
      'members': 'അംഗങ്ങൾ',
      'meetings': 'യോഗങ്ങൾ',
      'language': 'ഭാഷ',
      'malayalam': 'മലയാളം',
      'english': 'English',
      'save': 'സേവ് ചെയ്യുക',
      'cancel': 'റദ്ദാക്കുക',
      'calculate': 'കണക്കാക്കുക',
      'submit': 'സമർപ്പിക്കുക',
      'close': 'അടയ്ക്കുക',

      // Dashboard
      'overview_title': 'ഐശ്വര്യ സംഘം അവലോകനം',
      'financial_totals': 'സാമ്പത്തിക ലെഡ്ജർ വിവരം',
      'outstanding_loans': 'തിരിച്ചടയ്ക്കാനുള്ള വായ്പ',
      'total_deposits': 'ആകെ നിക്ഷേപം',
      'monthly_contributions': 'പ്രതിമാസ വിഹിതം',
      'meeting_collections': 'യോഗത്തിലെ പിരിവുകൾ',
      'outstanding_fines': 'കുടിശ്ശിക പിഴ',
      'financial_aid': 'സാമ്പത്തിക സഹായം',
      'interest_overview': 'പലിശ അവലോകനം',
      'interest_period': 'കാലയളവ്',
      'calculated_members': 'പലിശ കണക്കാക്കിയത്',
      'pending_members': 'കണക്കാക്കാനുള്ളത്',
      'outstanding_interest': 'കുടിശ്ശിക പലിശ',
      'no_active_meeting': 'സജീവ യോഗങ്ങൾ ഒന്നുമില്ല',
      'workspace': 'വർക്ക്സ്പേസ്',

      // Members
      'member_details': 'അംഗത്തിന്റെ ലെഡ്ജർ വിവരങ്ങൾ',
      'active_members': 'സജീവ അംഗങ്ങൾ',
      'new_member': 'പുതിയ അംഗം',
      'add_member': 'അംഗത്തെ ചേർക്കുക',
      'full_name': 'മുഴുവൻ പേര്',
      'phone_number': 'ഫോൺ നമ്പർ',
      'address': 'വിലാസം',
      'initial_deposit': 'പ്രാരംഭ നിക്ഷേപം',
      'no_members': 'സജീവ അംഗങ്ങൾ ആരും ഇല്ല',
      'no_phone': 'ഫോൺ നമ്പർ ലഭ്യമല്ല',
      'account_balances': '6 അക്കൗണ്ട് ബാലൻസുകൾ',
      'transaction_history': 'ഇടപാടുകളുടെ വിവരങ്ങൾ',
      'no_transactions': 'ഇടപാടുകൾ ഒന്നുമില്ല',

      // Account Types
      'LOAN': 'വായ്പ',
      'DEPOSIT': 'നിക്ഷേപം',
      'MONTHLY_CONTRIBUTION': 'പ്രതിമാസ വിഹിതം',
      'INTEREST': 'പലിശ',
      'FINE': 'പിഴ',
      'FINANCIAL_AID': 'സാമ്പത്തിക സഹായം',

      // Meetings
      'scheduled_meetings': 'നിശ്ചയിച്ച യോഗങ്ങൾ',
      'schedule_meeting': 'യോഗം നിശ്ചയിക്കുക',
      'meeting_active': 'യോഗം നടക്കുന്നു',
      'open_meeting': 'യോഗം ആരംഭിക്കുക',
      'complete_meeting': 'യോഗം പൂർത്തിയാക്കുക',
      'meeting_workspace': 'യോഗം വർക്ക്സ്പേസ്',
      'assigned_members': 'ഉൾപ്പെടുത്തിയ അംഗങ്ങൾ',
      'click_open_meeting': 'അംഗങ്ങളെ ഉൾപ്പെടുത്താൻ "യോഗം ആരംഭിക്കുക" ക്ലിക്ക് ചെയ്യുക',
      'no_meetings': 'യോഗങ്ങൾ ഒന്നും നിശ്ചയിച്ചിട്ടില്ല',
      'status_open': 'തുടങ്ങി',
      'status_scheduled': 'നിശ്ചയിച്ചു',
      'status_completed': 'പൂർത്തിയായി',

      // Repayment / Processing
      'process_payments': 'അടവുകൾ രേഖപ്പെടുത്തുക',
      'repayment_collections': 'തിരിച്ചടവ് പിരിവുകൾ',
      'loan_repayment': 'വായ്പ തിരിച്ചടവ് (₹)',
      'interest_payment': 'പലിശ അടവ് (₹)',
      'deposit_addition': 'നിക്ഷേപം ചേർക്കൽ (₹)',
      'contribution_addition': 'പ്രതിമാസ വിഹിതം (₹)',
      'fine_payment': 'പിഴ അടവ് (₹)',
      'aid_payment': 'സാമ്പത്തിക സഹായ അടവ് (₹)',
      'notes_remarks': 'കുറിപ്പുകൾ / വിവരങ്ങൾ',
      'add_notes_hint': 'അടവ് വിവരങ്ങൾ എഴുതുക...',
      'submit_payments': 'അടവുകൾ സമർപ്പിക്കുക',
      'calc_interest_dialog_title': '1% പലിശ കണക്കാക്കുക',
      'calc_interest_needed_banner': 'തിരിച്ചടവ് രേഖപ്പെടുത്തുന്നതിന് മുൻപ് പലിശ കണക്കാക്കണം.',
      'interest_calculation_needed': 'പലിശ കണക്കാക്കണം',
      'interest_calculated': 'പലിശ കണക്കാക്കി',

      // Actions & Dialogs
      'add_deposit': 'നിക്ഷേപം ചേർക്കുക',
      'issue_loan': 'വായ്പ നൽകുക',
      'add_fine': 'പിഴ ചേർക്കുക',
      'add_contribution': 'വിഹിതം ചേർക്കുക',
      'add_aid': 'സാമ്പത്തിക സഹായം നൽകുക',
      'calc_interest_action': '1% പലിശ',
    },
    'en': {
      // General & Navigation
      'app_title': 'Aiswarya Sangham Ledger',
      'dashboard': 'Dashboard',
      'members': 'Members',
      'meetings': 'Meetings',
      'language': 'Language',
      'malayalam': 'മലയാളം',
      'english': 'English',
      'save': 'Save',
      'cancel': 'Cancel',
      'calculate': 'Calculate',
      'submit': 'Submit',
      'close': 'Close',

      // Dashboard
      'overview_title': 'Aiswarya Sangham Overview',
      'financial_totals': 'Financial Ledger Totals',
      'outstanding_loans': 'Outstanding Loans',
      'total_deposits': 'Total Deposits',
      'monthly_contributions': 'Monthly Contributions',
      'meeting_collections': 'Meeting Collections',
      'outstanding_fines': 'Outstanding Fines',
      'financial_aid': 'Financial Aid',
      'interest_overview': 'Interest Overview',
      'interest_period': 'Period',
      'calculated_members': 'Calculated',
      'pending_members': 'Pending',
      'outstanding_interest': 'Outstanding',
      'no_active_meeting': 'No Active Meeting Scheduled',
      'workspace': 'Workspace',

      // Members
      'member_details': 'Member Ledger Details',
      'active_members': 'Active Members',
      'new_member': 'New Member',
      'add_member': 'Add Member',
      'full_name': 'Full Name',
      'phone_number': 'Phone Number',
      'address': 'Address',
      'initial_deposit': 'Initial Deposit',
      'no_members': 'No active members found.',
      'no_phone': 'No phone provided',
      'account_balances': '6 Account Category Balances',
      'transaction_history': 'Transaction Ledger History',
      'no_transactions': 'No transaction history.',

      // Account Types
      'LOAN': 'LOAN',
      'DEPOSIT': 'DEPOSIT',
      'MONTHLY_CONTRIBUTION': 'MONTHLY CONTRIBUTION',
      'INTEREST': 'INTEREST',
      'FINE': 'FINE',
      'FINANCIAL_AID': 'FINANCIAL AID',

      // Meetings
      'scheduled_meetings': 'Scheduled Meetings',
      'schedule_meeting': 'Schedule Meeting',
      'meeting_active': 'Meeting Active',
      'open_meeting': 'OPEN MEETING',
      'complete_meeting': 'COMPLETE MEETING',
      'meeting_workspace': 'Meeting Workspace',
      'assigned_members': 'Assigned Sangham Members',
      'click_open_meeting': 'Click "OPEN MEETING" above to snapshot active members.',
      'no_meetings': 'No meetings scheduled.',
      'status_open': 'OPEN',
      'status_scheduled': 'SCHEDULED',
      'status_completed': 'COMPLETED',

      // Repayment / Processing
      'process_payments': 'Process Member Payments',
      'repayment_collections': 'Meeting Repayment Collections',
      'loan_repayment': 'Loan Repayment (₹)',
      'interest_payment': 'Interest Payment (₹)',
      'deposit_addition': 'Deposit Addition (₹)',
      'contribution_addition': 'Monthly Contribution (₹)',
      'fine_payment': 'Fine Payment (₹)',
      'aid_payment': 'Financial Aid Payment (₹)',
      'notes_remarks': 'Notes & Remarks',
      'add_notes_hint': 'Add optional payment notes...',
      'submit_payments': 'SUBMIT MEMBER PAYMENTS',
      'calc_interest_dialog_title': 'Calculate 1% Interest',
      'calc_interest_needed_banner': 'Interest calculation required before processing repayments.',
      'interest_calculation_needed': 'Calculation Needed',
      'interest_calculated': 'Calculated',

      // Actions & Dialogs
      'add_deposit': 'Add Deposit',
      'issue_loan': 'Issue Loan',
      'add_fine': 'Add Fine',
      'add_contribution': 'Add Contribution',
      'add_aid': 'Add Financial Aid',
      'calc_interest_action': '1% Interest',
    }
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }

  String get dashboard => translate('dashboard');
  String get members => translate('members');
  String get meetings => translate('meetings');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ml', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
