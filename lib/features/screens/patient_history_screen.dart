import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/models/patient.dart';
import 'package:clinic/core/models/patient_history.dart';
import 'package:clinic/features/managers/patient_history/patient_history_cubit.dart';

class PatientHistoryScreen extends StatefulWidget {
  final Patient patient;
  const PatientHistoryScreen({super.key, required this.patient});

  @override
  State<PatientHistoryScreen> createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {
  late final PatientHistoryCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = PatientHistoryCubit();
    _cubit.loadForPatient(widget.patient.id!);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _showAddHistory() async {
    final result = await showDialog<PatientHistory?>(context: context, builder: (_) => AddHistoryDialog(patientId: widget.patient.id!));
    if (result != null) {
      _cubit.add(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Patient History — ${widget.patient.name}'),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
        ),
        body: BlocBuilder<PatientHistoryCubit, PatientHistoryState>(
          builder: (context, state) {
            if (state.isLoading) return const Center(child: CircularProgressIndicator());

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Selected patient card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(children: [
                        CircleAvatar(radius: 28, child: Text(widget.patient.name.isNotEmpty ? widget.patient.name[0] : 'P')),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(widget.patient.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Wrap(spacing: 12, children: [
                              _infoChip(Icons.cake_outlined, widget.patient.birthdate.split('T').first),
                              _infoChip(Icons.phone_outlined, widget.patient.mobile),
                              _infoChip(Icons.home_outlined, widget.patient.residency),
                            ]),
                          ]),
                        )
                      ]),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Latest history
                  if (state.history != null)
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Latest History', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                          const SizedBox(height: 8),
                          _historyRow('Occupation', state.history!.occupation),
                          _historyRow('Alcohol', state.history!.alcohol ? 'Yes' : 'No'),
                          _historyRow('Offspring', state.history!.offspring ? 'Yes' : 'No'),
                          _historyRow('Smoking', state.history!.smoking ? 'Yes' : 'No'),
                          _historyRow('Marital Status', state.history!.maritalStatus),
                          _historyRow('Allergy', state.history!.allergy ?? '-'),
                          _historyRow('Bilharziasis', state.history!.bilharziasis ? 'Yes' : 'No'),
                          _historyRow('Hepatitis', state.history!.hepatitis ? 'Yes' : 'No'),
                        ]),
                      ),
                    ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(onPressed: _showAddHistory, icon: const Icon(Icons.add), label: const Text('Add History')),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: state.list.isEmpty
                        ? const Center(child: Text('No history yet'))
                        : ListView.separated(
                            itemCount: state.list.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              final h = state.list[i];
                              return Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(h.occupation, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 6),
                                    Text('Alcohol: ${h.alcohol ? 'Yes' : 'No'} • Smoking: ${h.smoking ? 'Yes' : 'No'} • Offspring: ${h.offspring ? 'Yes' : 'No'}'),
                                  ]),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _historyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text('$label:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// -------------------- Add History Dialog --------------------
class AddHistoryDialog extends StatefulWidget {
  final int patientId;
  const AddHistoryDialog({super.key, required this.patientId});

  @override
  State<AddHistoryDialog> createState() => _AddHistoryDialogState();
}

class _AddHistoryDialogState extends State<AddHistoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _occupationCtrl = TextEditingController();
  bool _alcohol = false;
  bool _offspring = false;
  bool _smoking = false;
  String _marital = 'Single';
  final TextEditingController _allergyCtrl = TextEditingController();
  bool _bilhar = false;
  bool _hepatitis = false;

  @override
  void dispose() {
    _occupationCtrl.dispose();
    _allergyCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final h = PatientHistory(
      patientId: widget.patientId,
      occupation: _occupationCtrl.text.trim(),
      alcohol: _alcohol,
      offspring: _offspring,
      smoking: _smoking,
      maritalStatus: _marital,
      allergy: _allergyCtrl.text.trim().isEmpty ? null : _allergyCtrl.text.trim(),
      bilharziasis: _bilhar,
      hepatitis: _hepatitis,
      createdAt: now.toIso8601String(),
    );
    Navigator.of(context).pop(h);
  }

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
                  const Text('Add Patient History', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, color: Colors.white)),
                ],
              ),
            ),

            // white card form
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    TextFormField(
                      controller: _occupationCtrl,
                      decoration: const InputDecoration(labelText: 'Occupation'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),

                    const SizedBox(height: 12),

                    // Alcohol
                    Row(children: [
                      const Text('Alcohol: '),
                      const SizedBox(width: 12),
                      ChoiceChip(label: const Text('Yes'), selected: _alcohol, onSelected: (v) => setState(() => _alcohol = v)),
                      const SizedBox(width: 8),
                      ChoiceChip(label: const Text('No'), selected: !_alcohol, onSelected: (v) => setState(() => _alcohol = !v)),
                    ]),

                    const SizedBox(height: 12),

                    // Offspring (yes/no) - modern chips
                    Row(children: [
                      const Text('Offspring: '),
                      const SizedBox(width: 12),
                      ChoiceChip(label: const Text('Yes'), selected: _offspring, onSelected: (v) => setState(() => _offspring = v)),
                      const SizedBox(width: 8),
                      ChoiceChip(label: const Text('No'), selected: !_offspring, onSelected: (v) => setState(() => _offspring = !v)),
                    ]),

                    const SizedBox(height: 12),

                    // Smoking
                    Row(children: [
                      const Text('Smoking: '),
                      const SizedBox(width: 12),
                      ChoiceChip(label: const Text('Yes'), selected: _smoking, onSelected: (v) => setState(() => _smoking = v)),
                      const SizedBox(width: 8),
                      ChoiceChip(label: const Text('No'), selected: !_smoking, onSelected: (v) => setState(() => _smoking = !v)),
                    ]),

                    const SizedBox(height: 12),

                    // Marital status
                    DropdownButtonFormField<String>(
                      value: _marital,
                      items: const [
                        DropdownMenuItem(value: 'Single', child: Text('Single')),
                        DropdownMenuItem(value: 'Married', child: Text('Married')),
                        DropdownMenuItem(value: 'Divorced', child: Text('Divorced')),
                        DropdownMenuItem(value: 'Widowed', child: Text('Widowed')),
                      ],
                      onChanged: (v) => setState(() => _marital = v ?? 'Single'),
                      decoration: const InputDecoration(labelText: 'Marital Status'),
                    ),

                    const SizedBox(height: 12),

                    // Allergy
                    TextFormField(controller: _allergyCtrl, decoration: const InputDecoration(labelText: 'Allergy (optional)')),

                    const SizedBox(height: 12),

                    // Bilharziasis & Hepatitis
                    Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Bilharziasis'),
                        const SizedBox(height: 6),
                        ChoiceChip(label: const Text('Yes'), selected: _bilhar, onSelected: (v) => setState(() => _bilhar = v)),
                        const SizedBox(width: 6),
                        ChoiceChip(label: const Text('No'), selected: !_bilhar, onSelected: (v) => setState(() => _bilhar = !v)),
                      ])),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Hepatitis'),
                        const SizedBox(height: 6),
                        ChoiceChip(label: const Text('Yes'), selected: _hepatitis, onSelected: (v) => setState(() => _hepatitis = v)),
                        const SizedBox(width: 6),
                        ChoiceChip(label: const Text('No'), selected: !_hepatitis, onSelected: (v) => setState(() => _hepatitis = !v)),
                      ])),
                    ]),

                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))),
                      const SizedBox(width: 12),
                      Expanded(child: ElevatedButton(onPressed: _submit, child: const Text('Save'))),
                    ])
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}