import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../core/utils/date_helper.dart';
import '../data/repositories/billing_repository.dart';
import '../models/billing_item.dart';

/// The ViewModel for everything to do with billing items.
///
/// This is a [ChangeNotifier] exposed via `provider` (see main.dart) — it
/// sits between the UI (screens) and the [BillingRepository]:
///
///   Screen (widgets)  --watches-->  BillingViewModel  --uses-->  BillingRepository  --reads/writes-->  Hive box
///
/// Screens never touch Hive or even know it exists; they only call
/// methods here and rebuild automatically via [notifyListeners]. This is
/// the "MVVM" half of the app's architecture — see docs/design_pattern.md.
class BillingViewModel extends ChangeNotifier {
  BillingViewModel({BillingRepository? repository})
      : _repository = repository ?? BillingRepository() {
    _load();
  }

  final BillingRepository _repository;
  final Uuid _uuid = const Uuid();

  List<BillingItem> _items = [];

  /// All billing items, most recently dated first.
  List<BillingItem> get items => List.unmodifiable(_items);

  void _load() {
    _items = _repository.getAll()
      ..sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addItem({
    required String title,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    final item = BillingItem(
      id: _uuid.v4(),
      title: title.trim(),
      amount: amount,
      date: DateHelper.dateOnly(date),
      description: (description == null || description.trim().isEmpty)
          ? null
          : description.trim(),
    );
    await _repository.add(item);
    _load();
  }

  Future<void> updateItem(
    BillingItem item, {
    required String title,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    final updated = item.copyWith(
      title: title.trim(),
      amount: amount,
      date: DateHelper.dateOnly(date),
      description: (description == null || description.trim().isEmpty)
          ? null
          : description.trim(),
      clearDescription: description == null || description.trim().isEmpty,
    );
    await _repository.update(updated);
    _load();
  }

  Future<void> deleteItem(String id) async {
    await _repository.delete(id);
    _load();
  }

  List<BillingItem> itemsForDay(DateTime day) {
    return _items.where((i) => DateHelper.isSameDay(i.date, day)).toList();
  }

  List<BillingItem> itemsForWeek(WeekOfMonth week) {
    return _items
        .where((i) => week.days.any((d) => DateHelper.isSameDay(d, i.date)))
        .toList();
  }

  List<BillingItem> itemsForMonth(DateTime month) {
    return _items
        .where((i) => i.date.year == month.year && i.date.month == month.month)
        .toList();
  }

  double totalFor(Iterable<BillingItem> items) =>
      items.fold(0.0, (sum, i) => sum + i.amount);

  double totalForDay(DateTime day) => totalFor(itemsForDay(day));

  double totalForWeek(WeekOfMonth week) => totalFor(itemsForWeek(week));

  double totalForMonth(DateTime month) => totalFor(itemsForMonth(month));
}
