import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/models/patient.dart';
import 'package:clinic/core/models/diabetes_labs.dart';
import 'package:clinic/features/managers/labs/diabetes_labs/diabetes_labs_cubit.dart';
import 'package:flutter/services.dart';

class DiabetesLabsSection extends StatelessWidget {
  final Patient patient;
  const DiabetesLabsSection({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<DiabetesLabsCubit>().loadForPatient(patient.id!, force: true);
      } catch (_) {}
    });

    return BlocBuilder<DiabetesLabsCubit, DiabetesLabsState>(
      builder: (context, state) {
        if (state.isLoading) return const Center(child: CircularProgressIndicator());

        if (state.list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Diabetes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                _buildAddButton(context),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Diabetes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  _buildAddButton(context),
                ],
              ),
              const SizedBox(height: 8),
              // Render list items with a shrink-wrapped ListView (no Flexible) so it works inside
              // the parent's SingleChildScrollView. Flexible can cause zero-height issues here.
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
                Text('Add Diabetes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, DiabetesLabs item) {
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
            height: 140,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
            ),
          ),
          const SizedBox(width: 12),
          const Padding(
            padding: EdgeInsets.only(left: 6, right: 6),
            child: CircleAvatar(radius: 22, backgroundColor: Color(0xFFEEF2FF), child: Icon(Icons.monitor_heart, color: Color(0xFF3B82F6))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(item.date),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _infoChip('FBG', item.fbiGlu?.toString()),
                      _infoChip('2h PP', item.hrsPpBiGlu?.toString()),
                      _infoChip('HbA1c', item.hba1c?.toString()),
                      _infoChip('C-Peptide', item.cPeptide?.toString()),
                      _infoChip('Insulin', item.insulinLevel?.toString()),
                      _infoChip('RBS', item.rbs?.toString()),
                      _infoChip('HOMA-IR', item.homaIr?.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(onPressed: () => context.read<DiabetesLabsCubit>().delete(item.id!), icon: const Icon(Icons.delete_outline, color: Colors.grey)),
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
      builder: (dialogContext) => BlocProvider.value(value: context.read<DiabetesLabsCubit>(), child: AddDiabetesDialog(patientId: patient.id!)),
    );
  }

  Widget _infoChip(String label, String? value) {
    return Chip(
      backgroundColor: Colors.grey.shade100,
      label: Text(
        '$label: ${value ?? '-'}',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }
}

class AddDiabetesDialog extends StatefulWidget {
  final int patientId;
  const AddDiabetesDialog({Key? key, required this.patientId}) : super(key: key);

  @override
  State<AddDiabetesDialog> createState() => _AddDiabetesDialogState();
}

class _AddDiabetesDialogState extends State<AddDiabetesDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _date;
  final fbgCtrl = TextEditingController();
  final ppCtrl = TextEditingController();
  final hba1cCtrl = TextEditingController();
  final cPeptideCtrl = TextEditingController();
  final insulinCtrl = TextEditingController();
  final rbsCtrl = TextEditingController();
  final homaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
  }

  @override
  void dispose() {
    fbgCtrl.dispose();
    ppCtrl.dispose();
    hba1cCtrl.dispose();
    cPeptideCtrl.dispose();
    insulinCtrl.dispose();
    rbsCtrl.dispose();
    homaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: now, firstDate: DateTime(2000), lastDate: now);
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _date == null) return;

    // Debug: raw inputs
    print('Diabetes input raw: fbg="${fbgCtrl.text}", pp="${ppCtrl.text}", hba1c="${hba1cCtrl.text}", cPeptide="${cPeptideCtrl.text}", insulin="${insulinCtrl.text}", rbs="${rbsCtrl.text}", homa="${homaCtrl.text}"');

    String norm(String s) => s.trim().replaceAll(',', '.');

    double? parseNum(TextEditingController c) {
      final t = norm(c.text);
      if (t.isEmpty) return null;
      final p = double.tryParse(t);
      if (p == null) print('Diabetes parsing failed for "${c.text}" -> "$t"');
      return p;
    }

    final item = DiabetesLabs(
      patientId: widget.patientId,
      date: _date!.toIso8601String(),
      fbiGlu: parseNum(fbgCtrl),
      hrsPpBiGlu: parseNum(ppCtrl),
      hba1c: parseNum(hba1cCtrl),
      cPeptide: parseNum(cPeptideCtrl),
      insulinLevel: parseNum(insulinCtrl),
      rbs: parseNum(rbsCtrl),
      homaIr: parseNum(homaCtrl),
      createdAt: DateTime.now().toIso8601String(),
    );

    // Log the map that will be inserted
    try {
      // If model provides toMap()
      try {
        print('Diabetes to insert: ${item.toMap()}');
      } catch (_) {}

      await context.read<DiabetesLabsCubit>().add(item);
      Navigator.of(context).pop();
    } catch (e) {
      print('Error adding diabetes labs: $e');
    }
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
                    const Text('Add Diabetes Labs', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
                      const SizedBox(height: 16),
                      _CustomTextField(controller: fbgCtrl, label: 'FBG'),
                      _CustomTextField(controller: ppCtrl, label: '2h PP Glu'),
                      _CustomTextField(controller: hba1cCtrl, label: 'HbA1c'),
                      _CustomTextField(controller: cPeptideCtrl, label: 'C-Peptide'),
                      _CustomTextField(controller: insulinCtrl, label: 'Insulin'),
                      _CustomTextField(controller: rbsCtrl, label: 'RBS'),
                      _CustomTextField(controller: homaCtrl, label: 'HOMA-IR'),
                      const SizedBox(height: 16),
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
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [Icon(Icons.check, color: Colors.white, size: 20), SizedBox(width: 10), Text('Add Diabetes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16))],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const _CustomTextField({Key? key, required this.controller, this.label = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        validator: (v) {
          // If empty -> OK (fields optional)
          if (v == null || v.trim().isEmpty) return null;
          // Normalize comma decimals and validate numeric
          final t = v.trim().replaceAll(',', '.');
          if (double.tryParse(t) == null) return 'Enter a valid number';
          return null;
        },
      ),
    );
  }
}
