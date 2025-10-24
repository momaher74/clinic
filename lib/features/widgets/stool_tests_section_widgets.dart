import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/models/patient.dart';
import 'package:clinic/core/models/stool_tests.dart';
import 'package:clinic/features/managers/labs/stool_tests/stool_tests_cubit.dart';

class StoolTestsSection extends StatelessWidget {
  final Patient patient;
  const StoolTestsSection({Key? key, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<StoolTestsCubit>().loadForPatient(patient.id!, force: true);
      } catch (_) {}
    });

    return BlocBuilder<StoolTestsCubit, StoolTestsState>(
      builder: (context, state) {
        if (state.isLoading) return const Center(child: CircularProgressIndicator());

        if (state.list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Stool Tests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                _buildAddButton(context),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Stool Tests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  _buildAddButton(context),
                ],
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.list.length,
                itemBuilder: (context, index) {
                  final item = state.list[index];
                  return _buildCard(context, item);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showAddDialog(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.add, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Add Stool', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, StoolTests item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
            ),
          ),
          const SizedBox(width: 12),
          const Padding(
            padding: EdgeInsets.only(left: 6, right: 6),
            child: CircleAvatar(radius: 22, backgroundColor: Color(0xFFEEF2FF), child: Icon(Icons.biotech, color: Color(0xFF3B82F6))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_formatDate(item.date), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _infoChip('Occult', item.occultInStool),
                      _infoChip('H. Pylori Ag', item.hPyloriAgInStool),
                      _infoChip('Fecal Calprotectin', item.fecalCalprotectin),
                      _infoChip('Analysis', item.stoolAnalysis),
                      _infoChip('FIT', item.fitTest),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(onPressed: item.id == null ? null : () => context.read<StoolTestsCubit>().delete(item.id!), icon: const Icon(Icons.delete_outline, color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
    } catch (_) {}
    return raw.contains('T') ? raw.split('T').first : raw;
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(value: context.read<StoolTestsCubit>(), child: AddStoolDialog(patientId: patient.id!)),
    );
  }

  Widget _infoChip(String label, String? value) {
    return Chip(
      backgroundColor: Colors.grey.shade100,
      label: Text('$label: ${value ?? '-'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}

class AddStoolDialog extends StatefulWidget {
  final int patientId;
  const AddStoolDialog({Key? key, required this.patientId}) : super(key: key);

  @override
  State<AddStoolDialog> createState() => _AddStoolDialogState();
}

class _AddStoolDialogState extends State<AddStoolDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _date;

  final occult = TextEditingController();
  final hPylori = TextEditingController();
  final calprotectin = TextEditingController();
  final analysis = TextEditingController();
  final fit = TextEditingController();

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
  }

  @override
  void dispose() {
    occult.dispose();
    hPylori.dispose();
    calprotectin.dispose();
    analysis.dispose();
    fit.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _date == null) return;

    final item = StoolTests(
      patientId: widget.patientId,
      date: _date!.toIso8601String(),
      occultInStool: occult.text.trim().isEmpty ? null : occult.text.trim(),
      hPyloriAgInStool: hPylori.text.trim().isEmpty ? null : hPylori.text.trim(),
      fecalCalprotectin: calprotectin.text.trim().isEmpty ? null : calprotectin.text.trim(),
      stoolAnalysis: analysis.text.trim().isEmpty ? null : analysis.text.trim(),
      fitTest: fit.text.trim().isEmpty ? null : fit.text.trim(),
      createdAt: DateTime.now().toIso8601String(),
    );

    try {
      await context.read<StoolTestsCubit>().add(item);
      Navigator.of(context).pop();
    } catch (_) {}
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: now, firstDate: DateTime(2000), lastDate: now);
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Text('Add Stool Tests', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: InputDecoration(labelText: 'Date', border: const OutlineInputBorder(), filled: true, fillColor: Colors.grey.shade50),
                          child: Text(_date == null ? 'Select Date' : '${_date!.day}/${_date!.month}/${_date!.year}'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(controller: occult, decoration: InputDecoration(labelText: 'Occult in Stool', border: const OutlineInputBorder(), filled: true, fillColor: Colors.grey.shade50), validator: (_) => null),
                      const SizedBox(height: 8),
                      TextFormField(controller: hPylori, decoration: InputDecoration(labelText: 'H. Pylori Ag in Stool', border: const OutlineInputBorder(), filled: true, fillColor: Colors.grey.shade50), validator: (_) => null),
                      const SizedBox(height: 8),
                      TextFormField(controller: calprotectin, decoration: InputDecoration(labelText: 'Fecal Calprotectin', border: const OutlineInputBorder(), filled: true, fillColor: Colors.grey.shade50), validator: (_) => null),
                      const SizedBox(height: 8),
                      TextFormField(controller: analysis, decoration: InputDecoration(labelText: 'Stool Analysis', border: const OutlineInputBorder(), filled: true, fillColor: Colors.grey.shade50), validator: (_) => null),
                      const SizedBox(height: 8),
                      TextFormField(controller: fit, decoration: InputDecoration(labelText: 'FIT Test', border: const OutlineInputBorder(), filled: true, fillColor: Colors.grey.shade50), validator: (_) => null),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: _submit,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                child: const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
