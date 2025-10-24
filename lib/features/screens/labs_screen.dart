import 'package:clinic/features/managers/add_user/add_user/patient_cubit.dart';
import 'package:clinic/features/managers/labs/cbc/cbc_cubit.dart';
import 'package:clinic/core/models/cbc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LabsScreen extends StatelessWidget {
  const LabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = CbcCubit();
        final pState = context.read<PatientCubit>().state;
        if (pState.selectedIds.isNotEmpty) cubit.loadForPatient(pState.selectedIds.first);
        return cubit;
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('CBC', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () => _openAddDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add CBC'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // CBC list / no data view
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: BlocBuilder<CbcCubit, CbcState>(builder: (context, state) {
                  final pState = context.watch<PatientCubit>().state;
                  if (pState.selectedIds.isEmpty) return const Text('No patient selected');
                  final pid = pState.selectedIds.first;

                  // if selection changed, ensure load
                  if (!state.isLoading && (state.list.isEmpty || state.list.first.patientId != pid)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<CbcCubit>().loadForPatient(pid));
                  }

                  if (state.isLoading) return const Center(child: CircularProgressIndicator());

                  final items = state.list;
                  if (items.isEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        const Text('No CBC records yet', textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Center(
                          child: ElevatedButton(
                            onPressed: () => _openAddDialog(context),
                            child: const Text('Add CBC'),
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: items.map((c) {
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                        title: Text(c.date.isEmpty ? _shortDate(c.createdAt) : c.date),
                        subtitle: Text('Hb: ${c.hb} • RBCs: ${c.rbcs} • MCV: ${c.mcv}'),
                        trailing: IconButton(
                          onPressed: () => context.read<CbcCubit>().delete(c.id!),
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),

            // Placeholders for other sections (will follow same pattern)
            Card(
              color: Colors.white,
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('Other lab sections will appear here')]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shortDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  Future<void> _openAddDialog(BuildContext ctx) async {
    final pState = ctx.read<PatientCubit>().state;
    if (pState.selectedIds.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Select a patient first')));
      return;
    }
    final pid = pState.selectedIds.first;

    final result = await showDialog<Cbc?>(
      context: ctx,
      builder: (_) => AddCbcDialog(pid: pid),
    );

    if (result != null) {
      await ctx.read<CbcCubit>().add(result);
      await ctx.read<CbcCubit>().loadForPatient(pid);
    }
  }
}

class AddCbcDialog extends StatefulWidget {
  final int pid;
  const AddCbcDialog({super.key, required this.pid});

  @override
  State<AddCbcDialog> createState() => _AddCbcDialogState();
}

class _AddCbcDialogState extends State<AddCbcDialog> {
  final _formKey = GlobalKey<FormState>();
  final dateCtrl = TextEditingController();
  final hbCtrl = TextEditingController();
  final rbCtrl = TextEditingController();
  final mcvCtrl = TextEditingController();
  final mchCtrl = TextEditingController();
  final tlcCtrl = TextEditingController();
  final neutCtrl = TextEditingController();
  final lymphCtrl = TextEditingController();
  final monoCtrl = TextEditingController();
  final eosCtrl = TextEditingController();
  final basoCtrl = TextEditingController();
  final pttCtrl = TextEditingController();

  @override
  void dispose() {
    dateCtrl.dispose();
    hbCtrl.dispose();
    rbCtrl.dispose();
    mcvCtrl.dispose();
    mchCtrl.dispose();
    tlcCtrl.dispose();
    neutCtrl.dispose();
    lymphCtrl.dispose();
    monoCtrl.dispose();
    eosCtrl.dispose();
    basoCtrl.dispose();
    pttCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) dateCtrl.text = '${picked.day}/${picked.month}/${picked.year}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final c = Cbc(
      patientId: widget.pid,
      date: dateCtrl.text.trim(),
      hb: hbCtrl.text.trim(),
      rbcs: rbCtrl.text.trim(),
      mcv: mcvCtrl.text.trim(),
      mch: mchCtrl.text.trim(),
      tlc: tlcCtrl.text.trim(),
      neut: neutCtrl.text.trim(),
      lymph: lymphCtrl.text.trim(),
      mono: monoCtrl.text.trim(),
      eos: eosCtrl.text.trim(),
      baso: basoCtrl.text.trim(),
      ptt: pttCtrl.text.trim(),
    );
    Navigator.of(context).pop(c);
  }

  InputDecoration _dec(String label) => InputDecoration(labelText: label, filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none));

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add CBC', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, color: Colors.white)),
                ],
              ),
            ),

            // form card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: _pickDate,
                        child: AbsorbPointer(child: TextFormField(controller: dateCtrl, decoration: _dec('Date'), validator: (_) => null)),
                      ),
                      const SizedBox(height: 10),
                      Row(children: [Expanded(child: TextFormField(controller: hbCtrl, decoration: _dec('Hb'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: rbCtrl, decoration: _dec('RBCs')))]),
                      const SizedBox(height: 8),
                      Row(children: [Expanded(child: TextFormField(controller: mcvCtrl, decoration: _dec('MCV'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: mchCtrl, decoration: _dec('MCH')))]),
                      const SizedBox(height: 8),
                      Row(children: [Expanded(child: TextFormField(controller: tlcCtrl, decoration: _dec('TLC'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: neutCtrl, decoration: _dec('Neut')))]),
                      const SizedBox(height: 8),
                      Row(children: [Expanded(child: TextFormField(controller: lymphCtrl, decoration: _dec('Lymph'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: monoCtrl, decoration: _dec('Mono')))]),
                      const SizedBox(height: 8),
                      Row(children: [Expanded(child: TextFormField(controller: eosCtrl, decoration: _dec('Eos'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: basoCtrl, decoration: _dec('Baso')))]),
                      const SizedBox(height: 8),
                      TextFormField(controller: pttCtrl, decoration: _dec('PTT')),

                      const SizedBox(height: 14),
                      Row(children: [Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))), const SizedBox(width: 12), Expanded(child: ElevatedButton(onPressed: _submit, child: const Text('Save')))]),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}