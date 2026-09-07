import 'package:intl/intl.dart';

/// Formats raw `double` amounts consistently across every screen.
///
/// The app doesn't do multi-currency conversion (it's a purely local,
/// single-user budgeting tool) — this just centralizes the number format
/// so "1234.5" always renders the same way everywhere.
class CurrencyHelper {
  CurrencyHelper._();

  static final NumberFormat _format = NumberFormat.currency(
    symbol: 'E£ ',
    decimalDigits: 2,
  );

  static String format(double amount) => _format.format(amount);

  static String formatCompact(double amount) {
    if (amount.abs() >= 1000) {
      return '${_format.currencySymbol}${(amount / 1000).toStringAsFixed(1)}k';
    }
    return format(amount);
  }
}
