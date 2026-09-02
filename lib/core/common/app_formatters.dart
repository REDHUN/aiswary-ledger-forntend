import 'package:ashgledger/core/localization/app_localizations.dart';

class AppFormatters {
  /// Formats raw date or DateTime object into 'dd-MM-yyyy' (e.g., 22-08-2026).
  static String formatDate(dynamic date) {
    if (date == null) return '';
    if (date is DateTime) {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString().padLeft(4, '0');
      return '$day-$month-$year';
    }
    final raw = date.toString().trim();
    if (raw.isEmpty) return '';

    try {
      final dt = DateTime.tryParse(raw);
      if (dt != null) {
        final local = dt.toLocal();
        final day = local.day.toString().padLeft(2, '0');
        final month = local.month.toString().padLeft(2, '0');
        final year = local.year.toString().padLeft(4, '0');
        return '$day-$month-$year';
      }
    } catch (_) {}

    // Fallback if string is formatted like YYYY-MM-DD
    final parts = raw.split('-');
    if (parts.length == 3 && parts[0].length == 4) {
      final y = parts[0];
      final m = parts[1].padLeft(2, '0');
      final d = parts[2].split('T')[0].split(' ')[0].padLeft(2, '0');
      return '$d-$m-$y';
    }

    return raw;
  }

  /// Formats raw ISO date-time strings like '2026-08-22T15:30:42.928095Z'
  /// into 'dd-MM-yyyy 15:30'.
  static String formatDateTime(String? rawIso) {
    if (rawIso == null || rawIso.trim().isEmpty) return '';
    try {
      final dt = DateTime.tryParse(rawIso);
      if (dt != null) {
        final local = dt.toLocal();
        final day = local.day.toString().padLeft(2, '0');
        final month = local.month.toString().padLeft(2, '0');
        final year = local.year.toString().padLeft(4, '0');
        final hour = local.hour.toString().padLeft(2, '0');
        final minute = local.minute.toString().padLeft(2, '0');
        return '$day-$month-$year $hour:$minute';
      }
    } catch (_) {}

    // Fallback string cleanup if parsing fails
    var cleaned = rawIso.replaceAll('T', ' ').replaceAll('Z', '');
    if (cleaned.contains('.')) {
      cleaned = cleaned.substring(0, cleaned.indexOf('.'));
    }
    if (cleaned.length > 16) {
      cleaned = cleaned.substring(0, 16);
    }
    return cleaned;
  }

  /// Converts raw transaction type enum strings (e.g. 'INTEREST_APPLIED', 'LOAN_ISSUED')
  /// to localized text ('പലിശ ചേർത്തു', 'വായ്പ നൽകി').
  static String formatTransactionType(String type, [AppLocalizations? l10n]) {
    if (l10n != null) {
      final key = 'tx_type_${type.toUpperCase()}';
      final translated = l10n.translate(key);
      if (translated != key) return translated;
    }

    switch (type.toUpperCase()) {
      case 'INTEREST_APPLIED':
        return 'Interest Applied';
      case 'LOAN_ISSUED':
        return 'Loan Issued';
      case 'MONTHLY_CONTRIBUTION':
        return 'Monthly Contribution';
      case 'REPAYMENT':
        return 'Repayment';
      case 'ADDITION':
        return 'Addition';
      case 'REVERSAL':
        return 'Reversal';
      default:
        return type.split('_').map((w) {
          if (w.isEmpty) return '';
          return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
        }).join(' ');
    }
  }

  /// Converts raw account type enum strings (e.g. 'MONTHLY_CONTRIBUTION', 'FINANCIAL_AID')
  /// into localized titles ('വിഹിതം', 'സാമ്പത്തിക സഹായം').
  static String formatAccountType(String accountType, [AppLocalizations? l10n]) {
    if (l10n != null) {
      final translated = l10n.translate(accountType.toUpperCase());
      if (translated != accountType.toUpperCase()) return translated;
    }

    switch (accountType.toUpperCase()) {
      case 'MONTHLY_CONTRIBUTION':
        return 'Contribution';
      case 'FINANCIAL_AID':
        return 'Financial Aid';
      case 'LOAN':
        return 'Loan';
      case 'DEPOSIT':
        return 'Deposit';
      case 'FINE':
        return 'Fine';
      case 'INTEREST':
        return 'Interest';
      default:
        return accountType.split('_').map((w) {
          if (w.isEmpty) return '';
          return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
        }).join(' ');
    }
  }

  /// Formats system generated transaction descriptions into localized language.
  static String formatDescription(String? description, [AppLocalizations? l10n]) {
    if (description == null || description.isEmpty) return '';
    if (l10n == null || l10n.locale.languageCode != 'ml') return description;

    if (description.startsWith('Monthly interest (1%) capitalized to loan for period ')) {
      final period = description.replaceAll('Monthly interest (1%) capitalized to loan for period ', '');
      return '$period കാലയളവിലേക്കുള്ള 1% മാസാന്ത പലിശ വായ്പയിൽ ചേർത്തു';
    }
    if (description.startsWith('Reversal of transaction #')) {
      return description.replaceAll('Reversal of transaction #', 'ഇടപാട് # റദ്ദാക്കൽ: ').replaceAll('Reason: ', 'കാരണം: ');
    }
    if (description == 'Deposit recorded') return 'നിക്ഷേപം രേഖപ്പെടുത്തി';
    if (description == 'Loan issued') return 'വായ്പ നൽകി';

    return description;
  }
}
