import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('ml'));
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'ml': {
      // General & Navigation
      'app_title': 'ഐശ്വര്യ  സ്വയം  സഹായക  സംഘം  ലെഡ്ജർ',
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
      'date': 'തീയതി',
      'view_all': 'എല്ലാം കാണുക',
      'previous': 'മുമ്പത്തേത്',
      'next': 'അടുത്തത്',
      'surplus_fund': 'മിച്ച തുക',
      'total_loans': 'ആകെ  ലോൺ ',
      'total_fines': 'ആകെ  ഫൈൻ',

      // Dashboard
      'overview_title': 'ഐശ്വര്യ സംഘം അവലോകനം',
      'financial_totals': 'സാമ്പത്തിക ലെഡ്ജർ വിവരം',
      'financial_categories_overview': 'സാമ്പത്തിക വിഭാഗ അവലോകനം',
      'recent_transactions': 'സമീപകാല ലെഡ്ജർ ഇടപാടുകൾ',
      'no_recent_transactions': 'സമീപകാല ഇടപാടുകൾ ഒന്നുമില്ല.',
      'outstanding_loans': 'തിരിച്ചടയ്ക്കാനുള്ള വായ്പ',
      'total_deposits': 'ആകെ നിക്ഷേപം',
      'monthly_contributions': 'മാസ വരി',
      'meeting_collections': 'യോഗത്തിലെ പിരിവുകൾ',
      'outstanding_fines': 'കുടിശ്ശിക പിഴ',
      'fines_collected': 'പിരിഞ്ഞ പിഴ',
      'financial_aid': 'സാമ്പത്തിക സഹായം',
      'total_interest': 'ആകെ പലിശ',
      'interest_overview': 'പലിശ അവലോകനം',
      'interest_period': 'കാലയളവ്',
      'calculated_members': 'പലിശ കണക്കാക്കിയത്',
      'pending_members': 'കണക്കാക്കാനുള്ളത്',
      'outstanding_interest': 'കുടിശ്ശിക പലിശ',
      'no_active_meeting': 'സജീവ യോഗങ്ങൾ ഒന്നുമില്ല',
      'workspace': 'വർക്ക്സ്പേസ്',

      // Members & Registration
      'member_details': 'അംഗത്തിന്റെ ലെഡ്ജർ വിവരങ്ങൾ',
      'active_members': 'സജീവ അംഗങ്ങൾ',
      'new_member': 'പുതിയ അംഗം',
      'register_new_member': 'പുതിയ അംഗത്തെ ചേർക്കുക',
      'add_member': 'അംഗത്തെ ചേർക്കുക',
      'edit_profile': 'വിവരങ്ങൾ തിരുത്തുക',
      'member_number': 'അംഗ നമ്പർ (ഉദാ: M003)',
      'full_name': 'മുഴുവൻ പേര്',
      'username': 'യൂസർനെയിം',
      'password': 'പാസ്‌വേഡ്',
      'phone_number': 'ഫോൺ നമ്പർ',
      'address': 'വിലാസം',
      'joining_date': 'ചേർന്ന തീയതി',
      'initial_deposit': 'പ്രാരംഭ നിക്ഷേപം',
      'no_members': 'സജീവ അംഗങ്ങൾ ആരും ഇല്ല',
      'no_phone': 'ഫോൺ നമ്പർ ലഭ്യമല്ല',
      'account_balances': '6 അക്കൗണ്ട് ബാലൻസുകൾ',
      'transaction_history': 'ഇടപാടുകളുടെ വിവരങ്ങൾ',
      'no_transactions': 'ഇടപാടുകൾ ഒന്നുമില്ല',

      // Account Types
      'LOAN': 'വായ്പ',
      'DEPOSIT': 'നിക്ഷേപം',
      'MONTHLY_CONTRIBUTION': 'മാസ വരി ',
      'INTEREST': 'പലിശ',
      'FINE': 'ഫൈൻ',
      'FINANCIAL_AID': 'സാമ്പത്തിക സഹായം',

      // Transaction Types
      'tx_type_INTEREST_APPLIED': 'പലിശ ചേർത്തു',
      'tx_type_LOAN_ISSUED': 'വായ്പ നൽകി',
      'tx_type_MONTHLY_CONTRIBUTION': 'പ്രതിമാസ വിഹിതം',
      'tx_type_REPAYMENT': 'തിരിച്ചടവ്',
      'tx_type_ADDITION': 'ചേർക്കൽ',
      'tx_type_REVERSAL': 'റദ്ദാക്കൽ (Reversal)',

      // Reverse Actions
      'reverse_action': 'റദ്ദാക്കുക',
      'reason_for_reversal': 'റദ്ദാക്കാനുള്ള കാരണം',
      'reverse_transaction_title': 'ഇടപാട് റദ്ദാക്കുക',

      // Meetings
      'scheduled_meetings': 'നിശ്ചയിച്ച യോഗങ്ങൾ',
      'schedule_meeting': 'യോഗം നിശ്ചയിക്കുക',
      'meeting_active': 'യോഗം നടക്കുന്നു',
      'open_meeting': 'യോഗം ആരംഭിക്കുക',
      'complete_meeting': 'യോഗം പൂർത്തിയാക്കുക',
      'meeting_workspace': 'യോഗം വർക്ക്സ്പേസ്',
      'assigned_members': 'ഉൾപ്പെടുത്തിയ അംഗങ്ങൾ',
      'click_open_meeting':
          'അംഗങ്ങളെ ഉൾപ്പെടുത്താൻ "യോഗം ആരംഭിക്കുക" ക്ലിക്ക് ചെയ്യുക',
      'no_meetings': 'യോഗങ്ങൾ ഒന്നും നിശ്ചയിച്ചിട്ടില്ല',
      'first_meeting_of_month': 'മാസത്തിലെ ആദ്യ യോഗം',
      'active_meeting_notice':
          'സജീവ യോഗം ഇപ്പോൾ നടക്കുന്നു. പുതിയ യോഗം നിശ്ചയിക്കാൻ ഇത് പൂർത്തിയാക്കുക.',
      'status_open': 'തുടങ്ങി',
      'status_scheduled': 'നിശ്ചയിച്ചു',
      'status_completed': 'പൂർത്തിയായി',
      'status_pending': 'ബാക്കിയുണ്ട്',

      // Member Processing Form
      'member_collection_form': 'അംഗങ്ങളുടെ ശേഖരണ ഫോം',
      'processing_status': 'പ്രോസസ്സിംഗ് സ്റ്റാറ്റസ്',
      'financial_collection_entries': 'സാമ്പത്തിക ശേഖരണ എൻട്രികൾ',
      'calculated_interest_title': 'കണക്കാക്കിയ 1% മാസാന്ത പലിശ',
      'added_to_loan': 'വായ്പയിൽ ചേർത്തു',
      'bal': 'ബാക്കി',
      'current': 'നിലവിലുള്ളത്',
      'due': 'കുടിശ്ശിക',
      'total': 'ആകെ',
      'pay_full_loan': 'പൂർണ്ണ വായ്പ അടയ്ക്കുക',
      'calculating': 'കണക്കാക്കുന്നു...',
      'calculate_interest_button': '1% പലിശ കണക്കാക്കുക',

      // Repayment / Processing
      'process_payments': 'അടവുകൾ രേഖപ്പെടുത്തുക',
      'repayment_collections': 'തിരിച്ചടവ് പിരിവുകൾ',
      'loan_repayment': 'വായ്പ തിരിച്ചടവ് (₹)',
      'interest_payment': 'പലിശ അടവ് (₹)',
      'deposit_addition': 'നിക്ഷേപം ചേർക്കൽ (₹)',
      'contribution_addition': 'പ്രതിമാസ വിഹിതം (₹)',
      'fine_payment': 'പിഴ അടവ് (₹)',
      'aid_payment': 'സാമ്പത്തിക സഹായ അടവ് (₹)',
      'notes_remarks': 'കുറിപ്പുകൾ / വിവരങ്ങൾ (ഓപ്ഷണൽ)',
      'add_notes_hint': 'അടവ് വിവരങ്ങൾ എഴുതുക...',
      'submit_payments': 'അടവുകൾ സമർപ്പിക്കുക',
      'calc_interest_dialog_title': '1% പലിശ കണക്കാക്കുക',
      'calc_interest_needed_banner':
          'തിരിച്ചടവ് രേഖപ്പെടുത്തുന്നതിന് മുൻപ് പലിശ കണക്കാക്കണം.',
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
      'date': 'Date',
      'view_all': 'View All',
      'previous': 'Previous',
      'next': 'Next',

      // Dashboard
      'overview_title': 'Aiswarya Sangham Overview',
      'financial_totals': 'Financial Ledger Totals',
      'financial_categories_overview': 'Financial Categories Overview',
      'recent_transactions': 'Recent Ledger Transactions',
      'no_recent_transactions': 'No recent transactions.',
      'outstanding_loans': 'Outstanding Loans',
      'total_deposits': 'Total Deposits',
      'monthly_contributions': 'Monthly Contributions',
      'meeting_collections': 'Meeting Collections',
      'outstanding_fines': 'Outstanding Fines',
      'fines_collected': 'Fines Collected',
      'financial_aid': 'Financial Aid',
      'total_interest': 'Total Interest',
      'interest_overview': 'Interest Overview',
      'interest_period': 'Period',
      'calculated_members': 'Calculated',
      'pending_members': 'Pending',
      'outstanding_interest': 'Outstanding',
      'no_active_meeting': 'No Active Meeting Scheduled',
      'workspace': 'Workspace',

      // Members & Registration
      'member_details': 'Member Ledger Details',
      'active_members': 'Active Members',
      'new_member': 'New Member',
      'register_new_member': 'Register New Member',
      'add_member': 'Add Member',
      'edit_profile': 'Edit Profile',
      'member_number': 'Member Number (e.g. M003)',
      'full_name': 'Full Name',
      'username': 'Username',
      'password': 'Password',
      'phone_number': 'Phone Number',
      'address': 'Address',
      'joining_date': 'Joining Date',
      'initial_deposit': 'Initial Deposit',
      'no_members': 'No active members found.',
      'no_phone': 'No phone provided',
      'account_balances': '6 Account Category Balances',
      'transaction_history': 'Transaction Ledger History',
      'no_transactions': 'No transaction history.',

      // Account Types
      'LOAN': 'Loan',
      'DEPOSIT': 'Deposit',
      'MONTHLY_CONTRIBUTION': 'Contribution',
      'INTEREST': 'Interest',
      'FINE': 'Fine',
      'FINANCIAL_AID': 'Financial Aid',

      // Transaction Types
      'tx_type_INTEREST_APPLIED': 'Interest Applied',
      'tx_type_LOAN_ISSUED': 'Loan Issued',
      'tx_type_MONTHLY_CONTRIBUTION': 'Monthly Contribution',
      'tx_type_REPAYMENT': 'Repayment',
      'tx_type_ADDITION': 'Addition',
      'tx_type_REVERSAL': 'Reversal',

      // Reverse Actions
      'reverse_action': 'Reverse',
      'reason_for_reversal': 'Reason for Reversal',
      'reverse_transaction_title': 'Reverse Transaction',

      // Meetings
      'scheduled_meetings': 'Scheduled Meetings',
      'schedule_meeting': 'Schedule Meeting',
      'meeting_active': 'Meeting Active',
      'open_meeting': 'OPEN MEETING',
      'complete_meeting': 'COMPLETE MEETING',
      'meeting_workspace': 'Meeting Workspace',
      'assigned_members': 'Assigned Sangham Members',
      'click_open_meeting':
          'Click "OPEN MEETING" above to snapshot active members.',
      'no_meetings': 'No meetings scheduled.',
      'first_meeting_of_month': 'First Meeting of Month',
      'active_meeting_notice':
          'An active meeting is in progress. Complete it to unlock new meeting scheduling.',
      'status_open': 'OPEN',
      'status_scheduled': 'SCHEDULED',
      'status_completed': 'COMPLETED',
      'status_pending': 'PENDING',

      // Member Processing Form
      'member_collection_form': 'Member Collection Form',
      'processing_status': 'Processing Status',
      'financial_collection_entries': 'Financial Collection Entries',
      'calculated_interest_title': 'Calculated 1% Monthly Interest',
      'added_to_loan': 'Added to Loan',
      'bal': 'Bal',
      'current': 'Current',
      'due': 'Due',
      'total': 'Total',
      'pay_full_loan': 'Pay Full Loan',
      'calculating': 'Calculating...',
      'calculate_interest_button': 'Calculate Interest',

      // Repayment / Processing
      'process_payments': 'Process Member Payments',
      'repayment_collections': 'Meeting Repayment Collections',
      'loan_repayment': 'Loan Repayment (₹)',
      'interest_payment': 'Interest Payment (₹)',
      'deposit_addition': 'Savings Deposit Addition (₹)',
      'contribution_addition': 'Monthly Contribution Addition (₹)',
      'fine_payment': 'Fine Payment (₹)',
      'aid_payment': 'Financial Aid Payment (₹)',
      'notes_remarks': 'Notes / Remarks (Optional)',
      'add_notes_hint': 'Add optional payment notes...',
      'submit_payments': 'SUBMIT MEMBER PAYMENTS',
      'calc_interest_dialog_title': 'Calculate 1% Interest',
      'calc_interest_needed_banner':
          'Interest calculation required before processing repayments.',
      'interest_calculation_needed': 'Calculation Needed',
      'interest_calculated': 'Calculated',

      // Actions & Dialogs
      'add_deposit': 'Add Deposit',
      'issue_loan': 'Issue Loan',
      'add_fine': 'Add Fine',
      'add_contribution': 'Add Contribution',
      'add_aid': 'Add Financial Aid',
      'calc_interest_action': '1% Interest',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
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
