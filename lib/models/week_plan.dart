import 'package:hive/hive.dart';
import '../core/constants/app_constants.dart';

/// A user-editable spending plan for one specific week of one specific
/// month (e.g. "2026-09-W1: planned E£ 2000"). This is what lets the
/// month's budget be broken down and adjusted week by week, per the
/// app's "create a plan for the week" requirement, instead of just an
/// even four-way split of the monthly budget.
class WeekPlan extends HiveObject {
  WeekPlan({required this.weekId, required this.plannedAmount});

  /// e.g. "2026-09-W1". See [WeekOfMonth.idFor].
  final String weekId;
  double plannedAmount;
}

class WeekPlanAdapter extends TypeAdapter<WeekPlan> {
  @override
  final int typeId = HiveTypeIds.weekPlan;

  @override
  WeekPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeekPlan(
      weekId: fields[0] as String,
      plannedAmount: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, WeekPlan obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.weekId)
      ..writeByte(1)
      ..write(obj.plannedAmount);
  }
}
