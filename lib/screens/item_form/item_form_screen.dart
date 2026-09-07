import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/neon_colors.dart';
import '../../viewmodels/billing_viewmodel.dart';
import '../../models/billing_item.dart';

/// A single form used for both creating a new billing item and editing an
/// existing one (when [existingItem] is passed in) — this dual-purpose
/// design avoids maintaining two near-identical screens.
///
/// Fields: title and amount (required), date (defaults to [initialDate]),
/// and an optional description — exactly the fields the app spec calls
/// for. A subtle scale + fade entrance is applied to the whole form via
/// an [AnimatedOpacity]/[AnimatedScale] pair triggered right after the
/// first frame.
class ItemFormScreen extends StatefulWidget {
  const ItemFormScreen({
    super.key,
    required this.initialDate,
    this.existingItem,
  });

  final DateTime initialDate;
  final BillingItem? existingItem;

  bool get isEditing => existingItem != null;

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late DateTime _date;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingItem;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _amountController = TextEditingController(
      text: existing != null ? existing.amount.toStringAsFixed(2) : '',
    );
    _descriptionController = TextEditingController(text: existing?.description ?? '');
    _date = existing?.date ?? widget.initialDate;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(_date.year - 5),
      lastDate: DateTime(_date.year + 5),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: NeonColors.primary,
                surface: NeonColors.surfaceElevated,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final title = _titleController.text.trim();
    final amount = double.parse(_amountController.text.trim());
    final description = _descriptionController.text.trim();

    final viewModel = context.read<BillingViewModel>();
    if (widget.isEditing) {
      await viewModel.updateItem(
        widget.existingItem!,
        title: title,
        amount: amount,
        date: _date,
        description: description,
      );
    } else {
      await viewModel.addItem(
        title: title,
        amount: amount,
        date: _date,
        description: description,
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: NeonColors.surfaceElevated,
        title: const Text('Delete this item?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: NeonColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<BillingViewModel>().deleteItem(widget.existingItem!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit expense' : 'New expense'),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: NeonColors.danger),
              onPressed: _delete,
            ),
        ],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: NeonColors.backdropGradient),
        child: SafeArea(
          child: AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: AnimatedSlide(
              offset: _visible ? Offset.zero : const Offset(0, 0.05),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(labelText: 'Amount'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        final parsed = double.tryParse((value ?? '').trim());
                        if (parsed == null) return 'Enter a valid number';
                        if (parsed <= 0) return 'Must be greater than 0';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(14),
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Date'),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
                            const Icon(Icons.calendar_today, size: 18, color: NeonColors.primary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                      ),
                      minLines: 2,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: _save,
                      child: Text(widget.isEditing ? 'Save changes' : 'Add expense'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
