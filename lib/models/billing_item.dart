import 'package:hive/hive.dart';
import '../core/constants/app_constants.dart';

/// A single billing/expense entry: something you spent money on.
///
/// Every item has a [title] and [amount] (required by the app spec), an
/// optional [description], the [date] it applies to (used to place it in
/// the correct day/week/month), and [createdAt] which records exactly
/// when the entry was first saved — kept separate from [date] because a
/// user can log an expense for yesterday, but "created at" should still
/// reflect reality for auditing/sorting by recency.
///
/// This extends [HiveObject] so instances can call `save()`/`delete()`
/// directly once stored in a box (used by [BillingRepository]).
///
/// NOTE ON THE HAND-WRITTEN ADAPTER BELOW: Hive normally generates
/// [BillingItemAdapter] via `build_runner`. That code-gen step requires
/// running a command locally (`flutter pub run build_runner build`) after
/// `pub get`. To keep this project runnable with just `flutter pub get`
/// (no extra build step), the adapter is written by hand below, following
/// the exact same field-numbering format build_runner itself produces.
class BillingItem extends HiveObject {
  BillingItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String id;
  String title;
  double amount;
  DateTime date;
  String? description;
  final DateTime createdAt;

  BillingItem copyWith({
    String? title,
    double? amount,
    DateTime? date,
    String? description,
    bool clearDescription = false,
  }) {
    return BillingItem(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: clearDescription ? null : (description ?? this.description),
      createdAt: createdAt,
    );
  }
}

/// Hand-written Hive [TypeAdapter] for [BillingItem].
///
/// Field indices (0-5) are part of Hive's on-disk format: once shipped,
/// never change or reuse a field number — only append new ones — or
/// existing users' saved data will be misread.
class BillingItemAdapter extends TypeAdapter<BillingItem> {
  @override
  final int typeId = HiveTypeIds.billingItem;

  @override
  BillingItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BillingItem(
      id: fields[0] as String,
      title: fields[1] as String,
      amount: fields[2] as double,
      date: fields[3] as DateTime,
      description: fields[4] as String?,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BillingItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.createdAt);
  }
}
