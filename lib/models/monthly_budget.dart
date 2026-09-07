import 'package:hive/hive.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/date_helper.dart';

/// The budget the user sets for one calendar month (e.g. "September 2026:
/// E£ 8000"). Stored keyed by [DateHelper.monthKey] so there is exactly
/// one budget per month.
class MonthlyBudget extends HiveObject {
  MonthlyBudget({required this.monthKey, required this.amount});

  /// e.g. "2026-09". See [DateHelper.monthKey].
  final String monthKey;
  double amount;
}

class MonthlyBudgetAdapter extends TypeAdapter<MonthlyBudget> {
  @override
  final int typeId = HiveTypeIds.monthlyBudget;

  @override
  MonthlyBudget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MonthlyBudget(
      monthKey: fields[0] as String,
      amount: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, MonthlyBudget obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.monthKey)
      ..writeByte(1)
      ..write(obj.amount);
  }
}
