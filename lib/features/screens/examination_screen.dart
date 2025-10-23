import 'package:clinic/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/features/managers/examination/examination/examination_cubit.dart';
import 'package:clinic/features/managers/examination/examination/examination_state.dart';
import 'package:clinic/features/managers/add_user/add_user/patient_cubit.dart';
import 'package:clinic/core/models/examination.dart';
import 'package:clinic/core/models/request.dart';

class ExaminationScreen extends StatefulWidget {
  const ExaminationScreen({super.key});

  @override
  State<ExaminationScreen> createState() => _ExaminationScreenState();
}

class _ExaminationScreenState extends State<ExaminationScreen> {
  final _formKey = GlobalKey<FormState>();
  final bpCtrl = TextEditingController();
  final pulseCtrl = TextEditingController();
  final tempCtrl = TextEditingController();
  final spo2Ctrl = TextEditingController();
  final otherCtrl = TextEditingController();
  final examCtrl = TextEditingController();

  final reqCtrl = TextEditingController();

  @override
  void dispose() {
    bpCtrl.dispose();
    pulseCtrl.dispose();
    tempCtrl.dispose();
    spo2Ctrl.dispose();
    otherCtrl.dispose();
    examCtrl.dispose();
    reqCtrl.dispose();
    super.dispose();
  }

  void _loadForSelectedPatient() {
    final patientState = context.read<PatientCubit>().state;
    if (patientState.selectedIds.isEmpty) return;
    final pid = patientState.selectedIds.first;
    context.read<ExaminationCubit>().loadForPatient(pid);
  }

  Future<void> _submitExamination() async {
    if (!_formKey.currentState!.validate()) return;
    final patientState = context.read<PatientCubit>().state;
    if (patientState.selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a patient first')));
      return;
    }
    final pid = patientState.selectedIds.first;
    final ex = Examination(
      patientId: pid,
      bp: bpCtrl.text.trim(),
      pulse: pulseCtrl.text.trim(),
      temp: tempCtrl.text.trim(),
      spo2: spo2Ctrl.text.trim(),
      other: otherCtrl.text.trim(),
      examination: examCtrl.text.trim(),
    );

    try {
      FocusScope.of(context).unfocus();
      await context.read<ExaminationCubit>().addExamination(ex);
      // reload from DB to be safe
      await context.read<ExaminationCubit>().loadForPatient(pid);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Examination saved')));
      _formKey.currentState!.reset();
      bpCtrl.clear();
      pulseCtrl.clear();
      tempCtrl.clear();
      spo2Ctrl.clear();
      otherCtrl.clear();
      examCtrl.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  Future<void> _submitReq() async {
    final patientState = context.read<PatientCubit>().state;
    if (patientState.selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a patient first')));
      return;
    }
    final pid = patientState.selectedIds.first;
    if (reqCtrl.text.trim().isEmpty) return;
    final r = Req(patientId: pid, description: reqCtrl.text.trim());
    try {
      await context.read<ExaminationCubit>().addReq(r);
      await context.read<ExaminationCubit>().loadForPatient(pid);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Req added')));
      reqCtrl.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  String _formatCreatedAt(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  InputDecoration _fieldDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      
      prefixIcon: icon == null ? null : Icon(icon, color: Colors.grey.shade700),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) {
         // try to load when patient selection changes
         final patientState = context.watch<PatientCubit>().state;
         if (patientState.selectedIds.isNotEmpty && (state.patientId != patientState.selectedIds.first)) {
           // load new patient data
           WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ExaminationCubit>().loadForPatient(patientState.selectedIds.first));
         }

         return Container(
            color: Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Patient card
                  _patientCard(context),
                  const SizedBox(height: 14),

                  // Examination form inside Card
                  Card(
                    color: Colors.white,
                    elevation: 6,
                    shadowColor: Colors.black.withOpacity(0.08),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('New Examination', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                TextButton.icon(onPressed: _loadForSelectedPatient, icon: const Icon(Icons.refresh), label: const Text('Reload'))
                              ],
                            ),
                            const SizedBox(height: 8),

                            Row(
                              children: [
                                Expanded(child: TextFormField(controller: bpCtrl, decoration: _fieldDecoration('Bp', icon: Icons.favorite)) ),
                                const SizedBox(width: 10),
                                Expanded(child: TextFormField(controller: pulseCtrl, decoration: _fieldDecoration('Pulse', icon: Icons.monitor_heart)) ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(child: TextFormField(controller: tempCtrl, decoration: _fieldDecoration('Temp', icon: Icons.thermostat_rounded)) ),
                                const SizedBox(width: 10),
                                Expanded(child: TextFormField(controller: spo2Ctrl, decoration: _fieldDecoration('SPO2', icon: Icons.bubble_chart)) ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextFormField(controller: otherCtrl, decoration: _fieldDecoration('Other', icon: Icons.more_horiz)),
                            const SizedBox(height: 10),
                            TextFormField(controller: examCtrl, decoration: _fieldDecoration('Examination', icon: Icons.assignment), maxLines: 4),

                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _submitExamination,
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), padding: const EdgeInsets.symmetric(vertical: 14)),
                                    child:  Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Save Examination' , style: TextStyle(color: Colors.white)),
                                    ) ,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                OutlinedButton(
                                  onPressed: () {
                                    _formKey.currentState?.reset();
                                  },
                                  child: const Text('Clear'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Req card
                  Card(
                    color: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.06),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Req', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: reqCtrl,
                                  decoration: _fieldDecoration('Description', icon: Icons.note_add),
                                  keyboardType: TextInputType.multiline,
                                  minLines: 2,
                                  maxLines: 6,
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                height: 60,
                                width: 100,
                                child: ElevatedButton(
                                  onPressed: _submitReq,
                                  style: ElevatedButton.styleFrom( 
                                    backgroundColor: primaryColor,
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14) ),
                                  child:  Text('Add' , style: TextStyle(color: Colors.white)  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Existing examinations list
                  Card(
                    color: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.06),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Examinations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          if (state.isLoading) const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())),
                          if (!state.isLoading && state.examinations.isEmpty) const Padding(padding: EdgeInsets.all(8.0), child: Text('No examinations yet.')),
                          if (state.examinations.isNotEmpty)
                            for (final e in state.examinations) Dismissible(
                              key: ValueKey('ex-${e.id}-${e.createdAt}'),
                              direction: DismissDirection.endToStart,
                              background: Container(color: Colors.redAccent, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
                              onDismissed: (_) {
                                if (e.id != null) context.read<ExaminationCubit>().deleteExamination(e.id!);
                              },
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                                leading: CircleAvatar(backgroundColor: Colors.indigo.shade50, child: Text(_initials(e.examination.isNotEmpty ? e.examination : '${e.bp}'))),
                                title: Text(e.examination.isEmpty ? 'Vitals: ${_compactVitals(e)}' : e.examination, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text('${_formatCreatedAt(e.createdAt)}\nBp: ${e.bp} • Pulse: ${e.pulse} • Temp: ${e.temp} • SPO2: ${e.spo2}', style: TextStyle(color: Colors.grey.shade700)),
                                isThreeLine: true,
                                trailing: IconButton(onPressed: () { if (e.id != null) context.read<ExaminationCubit>().deleteExamination(e.id!); }, icon: const Icon(Icons.delete_outline, color: Colors.redAccent)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Reqs list
                  Card(
                    color: Colors.white,
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.06),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Reqs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          if (!state.isLoading && state.reqs.isEmpty) const Padding(padding: EdgeInsets.all(8.0), child: Text('No reqs yet.')),
                          if (state.reqs.isNotEmpty)
                            for (final r in state.reqs)
                              Dismissible(
                                key: ValueKey('rq-${r.id}-${r.createdAt}'),
                                direction: DismissDirection.endToStart,
                                background: Container(color: Colors.redAccent, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
                                onDismissed: (_) {
                                  if (r.id != null) context.read<ExaminationCubit>().deleteReq(r.id!);
                                },
                                child: ListTile(
                                  leading: CircleAvatar(backgroundColor: Colors.green.shade50, child: const Icon(Icons.request_page, color: Colors.green)),
                                  title: Text(r.description, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text(_formatCreatedAt(r.createdAt), style: TextStyle(color: Colors.grey.shade700)),
                                  trailing: IconButton(onPressed: () { if (r.id != null) context.read<ExaminationCubit>().deleteReq(r.id!); }, icon: const Icon(Icons.delete_outline, color: Colors.redAccent)),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      );
   }

  String _compactVitals(Examination e) {
    final parts = <String>[];
    if (e.bp.isNotEmpty) parts.add('BP ${e.bp}');
    if (e.pulse.isNotEmpty) parts.add('P ${e.pulse}');
    if (e.temp.isNotEmpty) parts.add('T ${e.temp}');
    return parts.join(' • ');
  }

  Widget _patientCard(BuildContext context) {
    final pState = context.watch<PatientCubit>().state;
    if (pState.selectedIds.isEmpty) return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: const Text('No patient selected'));
    final patient = pState.patients.firstWhere((p) => p.id == pState.selectedIds.first);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
      child: Row(
        children: [
          CircleAvatar(radius: 28, backgroundColor: Colors.indigo.shade50, child: Text(_initials(patient.name), style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(patient.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 6), Row(children: [Text('${patient.age} Y', style: TextStyle(color: Colors.grey.shade700)), const SizedBox(width: 8), Text(patient.sex, style: TextStyle(color: Colors.grey.shade700))]), const SizedBox(height: 6), Text(patient.mobile, style: TextStyle(color: Colors.grey.shade700))]),
          ),
          IconButton(onPressed: () => _showDeleteAllDialog(context), icon: const Icon(Icons.delete_forever, color: Colors.redAccent)),
        ],
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Delete all for this patient?'),
        content: const Text('This will delete all examinations and reqs for selected patient.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final pid = context.read<PatientCubit>().state.selectedIds.first;
              // delete all examinations
              for (final e in List.of(context.read<ExaminationCubit>().state.examinations)) {
                if (e.patientId == pid && e.id != null) await context.read<ExaminationCubit>().deleteExamination(e.id!);
              }
              for (final r in List.of(context.read<ExaminationCubit>().state.reqs)) {
                if (r.patientId == pid && r.id != null) await context.read<ExaminationCubit>().deleteReq(r.id!);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}