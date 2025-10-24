import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/models/patient.dart';
import 'package:clinic/core/models/celiac_disease_labs.dart';
import 'package:clinic/features/managers/labs/celiac_disease_labs/celiac_disease_labs_cubit.dart';

class CeliacDiseaseLabsSection extends StatelessWidget {
  final Patient patient;
  const CeliacDiseaseLabsSection({Key? key, required this.patient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<CeliacDiseaseLabsCubit>().loadForPatient(patient.id!, force: true);
      } catch (_) {}
    });

    return BlocBuilder<CeliacDiseaseLabsCubit, CeliacDiseaseLabsState>(
      builder: (context, state) {
        if (state.isLoading) return const Center(child: CircularProgressIndicator());

        if (state.list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Celiac Disease Labs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                  const Text('Celiac Disease Labs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                Text('Add Celiac', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, CeliacDiseaseLabs item) {
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
            child: CircleAvatar(radius: 22, backgroundColor: Color(0xFFEEF2FF), child: Icon(Icons.dashboard, color: Color(0xFF3B82F6))),
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
                      _infoChip('AGA IgA', item.agaIgA),
                      _infoChip('AGA IgG', item.agaIgG),
                      _infoChip('EMA IgA', item.emaIgA),
                      _infoChip('tTG IgA', item.ttgIgA),
                      _infoChip('tTG IgG', item.ttgIgG),
                      _infoChip('DGP IgA', item.dgpIgA),
                      _infoChip('DGP IgG', item.dgpIgG),
                      _infoChip('Total IgA', item.totalIgA?.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(onPressed: item.id == null ? null : () => context.read<CeliacDiseaseLabsCubit>().delete(item.id!), icon: const Icon(Icons.delete_outline, color: Colors.grey)),
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
      builder: (dialogContext) => BlocProvider.value(value: context.read<CeliacDiseaseLabsCubit>(), child: AddCeliacDialog(patientId: patient.id!)),
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

class AddCeliacDialog extends StatefulWidget {
  final int patientId;
  const AddCeliacDialog({Key? key, required this.patientId}) : super(key: key);

  @override
  State<AddCeliacDialog> createState() => _AddCeliacDialogState();
}

class _AddCeliacDialogState extends State<AddCeliacDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _date;

  final agaA = TextEditingController();
  final agaG = TextEditingController();
  final emaA = TextEditingController();
  final ttgA = TextEditingController();
  final ttgG = TextEditingController();
  final dgpA = TextEditingController();
  final dgpG = TextEditingController();
  final totalIgACtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
  }

  @override
  void dispose() {
    agaA.dispose();
    agaG.dispose();
    emaA.dispose();
    ttgA.dispose();
    ttgG.dispose();
    dgpA.dispose();
    dgpG.dispose();
    totalIgACtrl.dispose();
    super.dispose();
  }

  double? _parseNum(TextEditingController c) {
    final t = c.text.trim().replaceAll(',', '.');
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _date == null) return;

    final item = CeliacDiseaseLabs(
      patientId: widget.patientId,
      date: _date!.toIso8601String(),
      agaIgA: agaA.text.trim().isEmpty ? null : agaA.text.trim(),
      agaIgG: agaG.text.trim().isEmpty ? null : agaG.text.trim(),
      emaIgA: emaA.text.trim().isEmpty ? null : emaA.text.trim(),
      ttgIgA: ttgA.text.trim().isEmpty ? null : ttgA.text.trim(),
      ttgIgG: ttgG.text.trim().isEmpty ? null : ttgG.text.trim(),
      dgpIgA: dgpA.text.trim().isEmpty ? null : dgpA.text.trim(),
      dgpIgG: dgpG.text.trim().isEmpty ? null : dgpG.text.trim(),
      totalIgA: _parseNum(totalIgACtrl),
      createdAt: DateTime.now().toIso8601String(),
    );

    try {
      await context.read<CeliacDiseaseLabsCubit>().add(item);
      Navigator.of(context).pop();
    } catch (e) {
      // ignore
    }
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
                    const Text('Add Celiac Disease Labs', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
                      TextFormField(
                        controller: agaA,
                        decoration: InputDecoration(labelText: 'AGA IgA', border: const OutlineInputBorder(), filled: true, fillColor: Colors.grey.shade50),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        validator: (_) => null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: agaG,
                        decoration: InputDecoration(labelText: 'AGA IgG', border: const OutlineInputBorder(), filled: true, fillColor: Colors.grey.shade50),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        validator: (_) => null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: emaA,
                        decoration: InputDecoration(labelText: 'EMA IgA', border: const OutlineInputBorder(), filled: true, fillColor: Colors.grey.shade50),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        validator: (_) => null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: ttgA,
                        decoration: InputDecoration(labelText: 'tTG IgA', border: const OutlineInputBorder(), filled: true, fillColor: Colors.grey.shade50),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        validator: (_) => null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: ttgG,
                        decoration: InputDecoration(labelText: 'tTG IgG', border: const OutlineInputBorder(), filled: true, fillColor: Colors.grey.shade50),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        validator: (_) => null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: dgpA,
                        decoration: InputDecoration(labelText: 'DGP IgA', border: const OutlineInputBorder(), filled: true, fillColor: Colors.grey.shade50),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        validator: (_) => null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: dgpG,
                        decoration: InputDecoration(labelText: 'DGP IgG', border: const OutlineInputBorder(), filled: true, fillColor: Colors.grey.shade50),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        validator: (_) => null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: totalIgACtrl,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: 'Total IgA', border: const OutlineInputBorder(), filled: true, fillColor: Colors.grey.shade50),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        validator: (_) => null,
                      ),
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
