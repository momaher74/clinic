import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/models/patient.dart';
import 'package:clinic/core/models/autoimmune_markers.dart';
import 'package:clinic/features/managers/labs/autoimmune_markers/autoimmune_markers_cubit.dart';

class AutoimmuneMarkersSection extends StatelessWidget {
  final Patient patient;
  const AutoimmuneMarkersSection({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<AutoimmuneMarkersCubit>().loadForPatient(patient.id!, force: true);
      } catch (_) {}
    });

    return BlocBuilder<AutoimmuneMarkersCubit, AutoimmuneMarkersState>(
      builder: (context, state) {
        if (state.isLoading) return const Center(child: CircularProgressIndicator());

        if (state.list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Autoimmune Markers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                  const Text('Autoimmune Markers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                Text('Add Autoimmune', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, AutoimmuneMarkers item) {
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
            height: 160,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
            ),
          ),
          const SizedBox(width: 12),
          const Padding(
            padding: EdgeInsets.only(left: 6, right: 6),
            child: CircleAvatar(radius: 22, backgroundColor: Color(0xFFEEF2FF), child: Icon(Icons.science, color: Color(0xFF3B82F6))),
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
                      _infoChip('ANA', item.ana),
                      _infoChip('AMA', item.ama),
                      _infoChip('ASMA', item.asma),
                      _infoChip('LKM', item.lkm),
                      _infoChip('SLA', item.sla),
                      _infoChip('Total IgG', item.totalIgG?.toString()),
                      _infoChip('Total IgM', item.totalIgM?.toString()),
                      _infoChip('ANCA', item.anca),
                      _infoChip('ASCA', item.asca),
                      _infoChip('Anti Ds DNA', item.antiDsDna?.toString()),
                      _infoChip('C3', item.c3?.toString()),
                      _infoChip('C4', item.c4?.toString()),
                      _infoChip('RF', item.rf?.toString()),
                      _infoChip('Anti CCP', item.antiCcp?.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(onPressed: () => context.read<AutoimmuneMarkersCubit>().delete(item.id!), icon: const Icon(Icons.delete_outline, color: Colors.grey)),
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
      builder: (dialogContext) => BlocProvider.value(value: context.read<AutoimmuneMarkersCubit>(), child: AddAutoimmuneDialog(patientId: patient.id!)),
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

class AddAutoimmuneDialog extends StatefulWidget {
  final int patientId;
  const AddAutoimmuneDialog({Key? key, required this.patientId}) : super(key: key);

  @override
  State<AddAutoimmuneDialog> createState() => _AddAutoimmuneDialogState();
}

class _AddAutoimmuneDialogState extends State<AddAutoimmuneDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _date;

  final anaCtrl = TextEditingController();
  final amaCtrl = TextEditingController();
  final asmaCtrl = TextEditingController();
  final lkmCtrl = TextEditingController();
  final slaCtrl = TextEditingController();
  final totalIgGCtrl = TextEditingController();
  final totalIgMCtrl = TextEditingController();
  final ancaCtrl = TextEditingController();
  final ascaCtrl = TextEditingController();
  final antiDsCtrl = TextEditingController();
  final c3Ctrl = TextEditingController();
  final c4Ctrl = TextEditingController();
  final rfCtrl = TextEditingController();
  final antiCcpCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
  }

  @override
  void dispose() {
    anaCtrl.dispose();
    amaCtrl.dispose();
    asmaCtrl.dispose();
    lkmCtrl.dispose();
    slaCtrl.dispose();
    totalIgGCtrl.dispose();
    totalIgMCtrl.dispose();
    ancaCtrl.dispose();
    ascaCtrl.dispose();
    antiDsCtrl.dispose();
    c3Ctrl.dispose();
    c4Ctrl.dispose();
    rfCtrl.dispose();
    antiCcpCtrl.dispose();
    super.dispose();
  }

  double? _parseNum(TextEditingController c) {
    final t = c.text.trim().replaceAll(',', '.');
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _date == null) return;

    final item = AutoimmuneMarkers(
      patientId: widget.patientId,
      date: _date!.toIso8601String(),
      ana: anaCtrl.text.trim().isEmpty ? null : anaCtrl.text.trim(),
      ama: amaCtrl.text.trim().isEmpty ? null : amaCtrl.text.trim(),
      asma: asmaCtrl.text.trim().isEmpty ? null : asmaCtrl.text.trim(),
      lkm: lkmCtrl.text.trim().isEmpty ? null : lkmCtrl.text.trim(),
      sla: slaCtrl.text.trim().isEmpty ? null : slaCtrl.text.trim(),
      totalIgG: _parseNum(totalIgGCtrl),
      totalIgM: _parseNum(totalIgMCtrl),
      anca: ancaCtrl.text.trim().isEmpty ? null : ancaCtrl.text.trim(),
      asca: ascaCtrl.text.trim().isEmpty ? null : ascaCtrl.text.trim(),
      antiDsDna: _parseNum(antiDsCtrl),
      c3: _parseNum(c3Ctrl),
      c4: _parseNum(c4Ctrl),
      rf: _parseNum(rfCtrl),
      antiCcp: _parseNum(antiCcpCtrl),
      createdAt: DateTime.now().toIso8601String(),
    );

    try {
      await context.read<AutoimmuneMarkersCubit>().add(item);
      Navigator.of(context).pop();
    } catch (e) {
      // ignore for now
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
                    const Text('Add Autoimmune Markers', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
                      _TextField(controller: anaCtrl, label: 'ANA'),
                      _TextField(controller: amaCtrl, label: 'AMA'),
                      _TextField(controller: asmaCtrl, label: 'ASMA'),
                      _TextField(controller: lkmCtrl, label: 'LKM'),
                      _TextField(controller: slaCtrl, label: 'SLA'),
                      _NumberField(controller: totalIgGCtrl, label: 'Total IgG'),
                      _NumberField(controller: totalIgMCtrl, label: 'Total IgM'),
                      _TextField(controller: ancaCtrl, label: 'ANCA'),
                      _TextField(controller: ascaCtrl, label: 'ASCA'),
                      _NumberField(controller: antiDsCtrl, label: 'Anti Ds DNA'),
                      _NumberField(controller: c3Ctrl, label: 'C3'),
                      _NumberField(controller: c4Ctrl, label: 'C4'),
                      _NumberField(controller: rfCtrl, label: 'RF'),
                      _NumberField(controller: antiCcpCtrl, label: 'Anti CCP'),
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

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const _TextField({Key? key, required this.controller, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      validator: (_) => null,
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const _NumberField({Key? key, required this.controller, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (_) => null,
    );
  }
}
