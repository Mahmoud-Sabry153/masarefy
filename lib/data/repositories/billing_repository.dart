import 'package:hive/hive.dart';
import '../../core/constants/app_constants.dart';
import '../../models/billing_item.dart';

/// Data-access layer for [BillingItem]s.
///
/// This is the only class in the app that talks to the Hive box directly
/// for billing items. Everything above it (the ViewModel, the screens)
/// depends on this repository's simple CRUD API instead of Hive itself —
/// so if the storage engine ever changed (say, to sqflite), only this
/// file would need to change. See docs/design_pattern.md for the full
/// rationale behind this layering.
class BillingRepository {
  Box<BillingItem> get _box => Hive.box<BillingItem>(HiveBoxes.billingItems);

  List<BillingItem> getAll() => _box.values.toList(growable: false);

  Future<void> add(BillingItem item) => _box.put(item.id, item);

  Future<void> update(BillingItem item) => _box.put(item.id, item);

  Future<void> delete(String id) => _box.delete(id);

  BillingItem? getById(String id) => _box.get(id);
}
