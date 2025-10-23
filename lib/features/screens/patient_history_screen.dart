import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/models/patient.dart';
import 'package:clinic/core/models/patient_history.dart';
import 'package:clinic/core/models/drug.dart';
import 'package:clinic/core/models/disease.dart';
import 'package:clinic/features/managers/patient_history/patient_history_cubit.dart';
import 'package:clinic/features/managers/drug/drug_cubit.dart';
import 'package:clinic/features/managers/disease/disease_cubit.dart';

class PatientHistoryScreen extends StatefulWidget {
  final Patient patient;
  const PatientHistoryScreen({super.key, required this.patient});

  @override
  State<PatientHistoryScreen> createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {
  late final PatientHistoryCubit _cubit;
  late final DrugCubit _drugCubit;
  late final DiseaseCubit _diseaseCubit;
  // local in-memory lists for new sections (Operations and Family History)
  final List<OperationRecord> _operations = [];
  final List<FamilyHistoryRecord> _familyHistories = [];

  @override
  void initState() {
    super.initState();
    _cubit = PatientHistoryCubit();
    _drugCubit = DrugCubit();
    _diseaseCubit = DiseaseCubit();

    _cubit.loadForPatient(widget.patient.id!);
    _drugCubit.loadForPatient(widget.patient.id!);
    _diseaseCubit.loadForPatient(widget.patient.id!);
  }

  @override
  void dispose() {
    _cubit.close();
    _drugCubit.close();
    _diseaseCubit.close();
    super.dispose();
  }

  Future<void> _showAddHistory() async {
    final result = await showDialog<PatientHistory?>(context: context, builder: (_) => AddHistoryDialog(patientId: widget.patient.id!));
    if (result != null) {
      _cubit.add(result);
    }
  }

  Future<void> _showAddDrug() async {
    final result = await showDialog<Drug?>(context: context, builder: (_) => AddDrugDialog(patientId: widget.patient.id!));
    if (result != null) {
      _drugCubit.add(result);
    }
  }

  Future<void> _showAddDisease() async {
    final result = await showDialog<DiseaseStatus?>(context: context, builder: (_) => AddDiseaseDialog(patientId: widget.patient.id!));
    if (result != null) {
      _diseaseCubit.add(result);
    }
  }

  Future<void> _showAddOperation() async {
    final result = await showDialog<OperationRecord?>(context: context, builder: (_) => AddOperationDialog());
    if (result != null) setState(() => _operations.insert(0, result));
  }

  Future<void> _showAddFamilyHistory() async {
    final result = await showDialog<FamilyHistoryRecord?>(context: context, builder: (_) => AddFamilyHistoryDialog());
    if (result != null) setState(() => _familyHistories.insert(0, result));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider.value(value: _drugCubit),
        BlocProvider.value(value: _diseaseCubit),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
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
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Selected patient card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6))],
                      ),
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
                          ),

                          // Add History button inside the patient card for easier access
                          ElevatedButton.icon(
                            onPressed: _showAddHistory,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add History'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ]),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Latest history
                    if (state.history != null)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 6))],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Latest History', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                            const SizedBox(height: 8),
                            _historyRow('Occupation', state.history!.occupation),
                            _historyRow('Alcohol', state.history!.alcohol ? 'Yes' : 'No'),
                            _historyRow('Offspring', state.history!.offspring ? 'Yes' : 'No'),
                            _historyRow('Smoking', state.history!.smoking ? 'Yes' : 'No'),
                            _historyRow('Married', state.history!.maritalStatus ? 'Yes' : 'No'),
                            _historyRow('Allergy', state.history!.allergy ? 'Yes' : 'No'),
                            _historyRow('Bilharziasis', state.history!.bilharziasis ? 'Yes' : 'No'),
                            _historyRow('Hepatitis', state.history!.hepatitis ? 'Yes' : 'No'),
                          ]),
                        ),
                      ),

                    // small spacing after latest history
                    const SizedBox(height: 12),

                    // Diseases section (separated with primary-colored header)
                    BlocBuilder<DiseaseCubit, DiseaseState>(builder: (context, ds) {
                      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        // header with primary gradient
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            const Text('Diseases', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            TextButton.icon(onPressed: _showAddDisease, icon: const Icon(Icons.add, color: Colors.white), label: const Text('Add', style: TextStyle(color: Colors.white)), style: TextButton.styleFrom(foregroundColor: Colors.white)),
                          ]),
                        ),

                        // body card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 6))],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ds.list.isNotEmpty
                                ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text('Latest: DM: ${ds.list.first.dm ? 'Yes' : 'No'} • HTN: ${ds.list.first.htn ? 'Yes' : 'No'}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    if ((ds.list.first.notes ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6.0), child: Text('Notes: ${ds.list.first.notes}'))
                                  ])
                                : const Text('No disease records yet'),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // disease list below the card
                        if (ds.list.isNotEmpty)
                          SizedBox(
                            height: 110,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: ds.list.length,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (context, i) {
                                final d = ds.list[i];
                                return Container(
                                  width: 260,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 6))],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                        // if neither DM nor HTN, show a friendly 'No diseases' label
                                        Text(
                                          (d.dm || d.htn) ? '${d.dm ? 'DM' : ''}${d.dm && d.htn ? ' • ' : ''}${d.htn ? 'HTN' : ''}' : 'No diseases',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                          onPressed: () async {
                                            final ok = await showDialog<bool>(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                      title: const Text('Confirm'),
                                                      content: const Text('Delete this disease record?'),
                                                      actions: [
                                                        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                                                        TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
                                                      ],
                                                    ));
                                            if (ok == true && d.id != null) await _diseaseCubit.remove(d.id!);
                                          },
                                        )
                                      ]),
                                      const SizedBox(height: 6),
                                      if ((d.notes ?? '').isNotEmpty) Text(d.notes!),
                                    ]),
                                  ),
                                );
                              },
                            ),
                          ),
                      ]);
                    }),

                    const SizedBox(height: 12),

                    // -------------------- Operations section --------------------
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Operations', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        TextButton.icon(onPressed: _showAddOperation, icon: const Icon(Icons.add, color: Colors.white), label: const Text('Add', style: TextStyle(color: Colors.white)), style: TextButton.styleFrom(foregroundColor: Colors.white)),
                      ]),
                    ),

                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 6))]),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: _operations.isNotEmpty
                            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('Latest: ${_operations.first.date.split('T').first} • Dr: ${_operations.first.doctor}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                if ((_operations.first.description ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6.0), child: Text('Notes: ${_operations.first.description}'))
                              ])
                            : const Text('No operations recorded yet'),
                      ),
                    ),

                    const SizedBox(height: 8),

                    if (_operations.isNotEmpty)
                      SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _operations.length,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final o = _operations[i];
                            return Container(
                              width: 320,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 6))]),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                    Expanded(child: Text('${o.date.split('T').first} • Dr: ${o.doctor}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                    IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () => setState(() => _operations.removeAt(i)))
                                  ]),
                                  const SizedBox(height: 6),
                                  if ((o.description ?? '').isNotEmpty) Text(o.description!),
                                ]),
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 12),

                    // -------------------- Family history section --------------------
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Family History', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        TextButton.icon(onPressed: _showAddFamilyHistory, icon: const Icon(Icons.add, color: Colors.white), label: const Text('Add', style: TextStyle(color: Colors.white)), style: TextButton.styleFrom(foregroundColor: Colors.white)),
                      ]),
                    ),

                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 6))]),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: _familyHistories.isNotEmpty
                            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                if (_familyHistories.first.description.isNotEmpty) Text(_familyHistories.first.description),
                              ])
                            : const Text('No family history recorded'),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Drugs section (separated with primary-colored header)
                    BlocBuilder<DrugCubit, DrugState>(builder: (context, ds) {
                      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Theme.of(context).primaryColor, Theme.of(context).colorScheme.secondary],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            const Text('Drugs', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            TextButton.icon(onPressed: _showAddDrug, icon: const Icon(Icons.add, color: Colors.white), label: const Text('Add', style: TextStyle(color: Colors.white)), style: TextButton.styleFrom(foregroundColor: Colors.white)),
                          ]),
                        ),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 6))],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ds.list.isEmpty
                                ? const Text('No drugs prescribed')
                                : Column(children: ds.list.map((d) => Container(
                                       margin: const EdgeInsets.symmetric(vertical: 6),
                                       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 6))]),
                                       child: Padding(
                                         padding: const EdgeInsets.all(12.0),
                                         child: Row(children: [
                                           Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 6), Text('${d.dose} • ${d.frequency} • ${d.durationDays} days')])),
                                           IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: () async {
                                             final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Confirm'), content: const Text('Delete this drug?'), actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete'))]));
                                             if (ok == true && d.id != null) await _drugCubit.remove(d.id!);
                                           })
                                         ]),
                                       ),
                                     )).toList()),
                          ),
                        ),
                      ]);
                    }),
                  ],
                ),
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
  bool _married = false;
  bool _allergy = false;
  bool _bilhar = false;
  bool _hepatitis = false;

  @override
  void dispose() {
    _occupationCtrl.dispose();
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
      maritalStatus: _married,
      allergy: _allergy,
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
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // gradient top bar
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add Patient History', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, color: Colors.white)),
                ],
              ),
            ),

            // white body
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    TextFormField(
                      controller: _occupationCtrl,
                      decoration: InputDecoration(
                        labelText: 'Occupation',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),

                    const SizedBox(height: 14),

                    // Alcohol
                    Row(children: [
                      const SizedBox(width: 120, child: Text('Alcohol:')),
                      ChoiceChip(
                        label: const Text('Yes'),
                        selected: _alcohol,
                        onSelected: (v) => setState(() => _alcohol = v),
                        selectedColor: const Color(0xFF7C3AED),
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: TextStyle(color: _alcohol ? Colors.white : Colors.black87),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('No'),
                        selected: !_alcohol,
                        onSelected: (v) => setState(() => _alcohol = !v),
                        selectedColor: const Color(0xFF7C3AED),
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: TextStyle(color: !_alcohol ? Colors.white : Colors.black87),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ]),

                    const SizedBox(height: 12),

                    // Offspring
                    Row(children: [
                      const SizedBox(width: 120, child: Text('Offspring:')),
                      ChoiceChip(
                        label: const Text('Yes'),
                        selected: _offspring,
                        onSelected: (v) => setState(() => _offspring = v),
                        selectedColor: const Color(0xFF7C3AED),
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: TextStyle(color: _offspring ? Colors.white : Colors.black87),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('No'),
                        selected: !_offspring,
                        onSelected: (v) => setState(() => _offspring = !v),
                        selectedColor: const Color(0xFF7C3AED),
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: TextStyle(color: !_offspring ? Colors.white : Colors.black87),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ]),

                    const SizedBox(height: 12),

                    // Smoking
                    Row(children: [
                      const SizedBox(width: 120, child: Text('Smoking:')),
                      ChoiceChip(
                        label: const Text('Yes'),
                        selected: _smoking,
                        onSelected: (v) => setState(() => _smoking = v),
                        selectedColor: const Color(0xFF7C3AED),
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: TextStyle(color: _smoking ? Colors.white : Colors.black87),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('No'),
                        selected: !_smoking,
                        onSelected: (v) => setState(() => _smoking = !v),
                        selectedColor: const Color(0xFF7C3AED),
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: TextStyle(color: !_smoking ? Colors.white : Colors.black87),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ]),

                    const SizedBox(height: 12),

                    // Marital status (Yes/No)
                    Row(children: [
                      const SizedBox(width: 120, child: Text('Married:')),
                      ChoiceChip(
                        label: const Text('Yes'),
                        selected: _married,
                        onSelected: (v) => setState(() => _married = v),
                        selectedColor: const Color(0xFF7C3AED),
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: TextStyle(color: _married ? Colors.white : Colors.black87),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('No'),
                        selected: !_married,
                        onSelected: (v) => setState(() => _married = !v),
                        selectedColor: const Color(0xFF7C3AED),
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: TextStyle(color: !_married ? Colors.white : Colors.black87),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ]),

                    const SizedBox(height: 12),

                    // Allergy (yes/no)
                    Row(children: [
                      const SizedBox(width: 120, child: Text('Allergy:')),
                      ChoiceChip(
                        label: const Text('Yes'),
                        selected: _allergy,
                        onSelected: (v) => setState(() => _allergy = v),
                        selectedColor: const Color(0xFF7C3AED),
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: TextStyle(color: _allergy ? Colors.white : Colors.black87),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('No'),
                        selected: !_allergy,
                        onSelected: (v) => setState(() => _allergy = !v),
                        selectedColor: const Color(0xFF7C3AED),
                        backgroundColor: Colors.grey.shade200,
                        labelStyle: TextStyle(color: !_allergy ? Colors.white : Colors.black87),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ]),

                    const SizedBox(height: 12),

                    // Bilharziasis & Hepatitis inline
                    Row(children: [
                      Expanded(child: Row(children: [
                        const SizedBox(width: 120, child: Text('Bilharziasis:')),
                        ChoiceChip(
                          label: const Text('Yes'),
                          selected: _bilhar,
                          onSelected: (v) => setState(() => _bilhar = v),
                          selectedColor: const Color(0xFF7C3AED),
                          backgroundColor: Colors.grey.shade200,
                          labelStyle: TextStyle(color: _bilhar ? Colors.white : Colors.black87),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('No'),
                          selected: !_bilhar,
                          onSelected: (v) => setState(() => _bilhar = !v),
                          selectedColor: const Color(0xFF7C3AED),
                          backgroundColor: Colors.grey.shade200,
                          labelStyle: TextStyle(color: !_bilhar ? Colors.white : Colors.black87),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ])),
                      Expanded(child: Row(children: [
                        const SizedBox(width: 100, child: Text('Hepatitis:')),
                        ChoiceChip(
                          label: const Text('Yes'),
                          selected: _hepatitis,
                          onSelected: (v) => setState(() => _hepatitis = v),
                          selectedColor: const Color(0xFF7C3AED),
                          backgroundColor: Colors.grey.shade200,
                          labelStyle: TextStyle(color: _hepatitis ? Colors.white : Colors.black87),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('No'),
                          selected: !_hepatitis,
                          onSelected: (v) => setState(() => _hepatitis = !v),
                          selectedColor: const Color(0xFF7C3AED),
                          backgroundColor: Colors.grey.shade200,
                          labelStyle: TextStyle(color: !_hepatitis ? Colors.white : Colors.black87),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ])),
                    ]),

                    const SizedBox(height: 18),

                    // action buttons
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                      const SizedBox(width: 8),
                      ElevatedButton(onPressed: _submit, style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor), child:  Text('Save' , style: TextStyle(color:  Colors.white),)),
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

// -------------------- Add Drug Dialog --------------------
class AddDrugDialog extends StatefulWidget {
  final int patientId;
  const AddDrugDialog({super.key, required this.patientId});

  @override
  State<AddDrugDialog> createState() => _AddDrugDialogState();
}

class _AddDrugDialogState extends State<AddDrugDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _dose = TextEditingController();
  final TextEditingController _frequency = TextEditingController();
  final TextEditingController _duration = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    _frequency.dispose();
    _duration.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final d = Drug(
      patientId: widget.patientId,
      name: _name.text.trim(),
      dose: _dose.text.trim(),
      frequency: _frequency.text.trim(),
      durationDays: int.tryParse(_duration.text.trim()) ?? 0,
      createdAt: now.toIso8601String(),
    );
    Navigator.of(context).pop(d);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Add Drug', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, color: Colors.white)),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  TextFormField(
                    controller: _name,
                    decoration: InputDecoration(labelText: 'Drug name', filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _dose,
                    decoration: InputDecoration(labelText: 'Dose (e.g. 300 mg)', filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _frequency,
                    decoration: InputDecoration(labelText: 'Frequency (e.g. 2 times/day)', filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _duration,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Duration (days)', filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)),
                    validator: (v) => v == null || int.tryParse(v.trim()) == null ? 'Enter number of days' : null,
                  ),

                  const SizedBox(height: 18),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: _submit, style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor), child:  Text('Save' , style: TextStyle(color: Colors.white),)),
                  ])
                ]),
              ),
            ),
          )
        ]),
      ),
    );
  }
}

// -------------------- Add Disease Dialog --------------------
class AddDiseaseDialog extends StatefulWidget {
  final int patientId;
  const AddDiseaseDialog({super.key, required this.patientId});

  @override
  State<AddDiseaseDialog> createState() => _AddDiseaseDialogState();
}

class _AddDiseaseDialogState extends State<AddDiseaseDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _dm = false;
  bool _htn = false;
  final TextEditingController _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  void _submit() {
    final now = DateTime.now();
    final d = DiseaseStatus(
      patientId: widget.patientId,
      dm: _dm,
      htn: _htn,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      createdAt: now.toIso8601String(),
    );
    Navigator.of(context).pop(d);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Add Disease', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, color: Colors.white)),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  const SizedBox(width: 100, child: Text('DM:')),
                  ChoiceChip(label: const Text('Yes'), selected: _dm, onSelected: (v) => setState(() => _dm = v), selectedColor: const Color(0xFF7C3AED), backgroundColor: Colors.grey.shade200, labelStyle: TextStyle(color: _dm ? Colors.white : Colors.black87), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  const SizedBox(width: 8),
                  ChoiceChip(label: const Text('No'), selected: !_dm, onSelected: (v) => setState(() => _dm = !v), selectedColor: const Color(0xFF7C3AED), backgroundColor: Colors.grey.shade200, labelStyle: TextStyle(color: !_dm ? Colors.white : Colors.black87), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ]),

                const SizedBox(height: 12),

                Row(children: [
                  const SizedBox(width: 100, child: Text('HTN:')),
                  ChoiceChip(label: const Text('Yes'), selected: _htn, onSelected: (v) => setState(() => _htn = v), selectedColor: const Color(0xFF7C3AED), backgroundColor: Colors.grey.shade200, labelStyle: TextStyle(color: _htn ? Colors.white : Colors.black87), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  const SizedBox(width: 8),
                  ChoiceChip(label: const Text('No'), selected: !_htn, onSelected: (v) => setState(() => _htn = !v), selectedColor: const Color(0xFF7C3AED), backgroundColor: Colors.grey.shade200, labelStyle: TextStyle(color: !_htn ? Colors.white : Colors.black87), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ]),

                const SizedBox(height: 12),
                TextFormField(controller: _notes, decoration: InputDecoration(labelText: 'Notes (optional)', filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),

                const SizedBox(height: 18),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _submit, style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor), child:  Text('Save' , style: TextStyle(color: Colors.white),)),
                ])
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// -------------------- Add Operation Dialog --------------------
class AddOperationDialog extends StatefulWidget {
  const AddOperationDialog({super.key});

  @override
  State<AddOperationDialog> createState() => _AddOperationDialogState();
}

class _AddOperationDialogState extends State<AddOperationDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime _date = DateTime.now();
  final TextEditingController _doctor = TextEditingController();
  final TextEditingController _description = TextEditingController();

  @override
  void dispose() {
    _doctor.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(1900), lastDate: DateTime(2100));
    if (d != null) setState(() => _date = d);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final op = OperationRecord(date: _date.toIso8601String(), doctor: _doctor.text.trim().isEmpty ? 'Unknown' : _doctor.text.trim(), description: _description.text.trim().isEmpty ? null : _description.text.trim());
    Navigator.of(context).pop(op);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Add Operation', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, color: Colors.white)),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  Expanded(child: Text('Date: ${_date.toLocal().toIso8601String().split('T').first}')),
                  TextButton(onPressed: _pickDate, child: const Text('Change')),
                ]),

                const SizedBox(height: 12),
                TextFormField(controller: _doctor, decoration: InputDecoration(labelText: 'Doctor (optional)', filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),

                const SizedBox(height: 12),
                TextFormField(controller: _description, maxLines: 4, decoration: InputDecoration(labelText: 'Description', filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none))),

                const SizedBox(height: 18),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _submit, style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor), child:  Text('Save' , style: TextStyle(color: Colors.white),)),
                ])
              ]),
            ),
          )
        ]),
      ),
    );
  }
}

class AddFamilyHistoryDialog extends StatefulWidget {
  const AddFamilyHistoryDialog({super.key});

  @override
  State<AddFamilyHistoryDialog> createState() => _AddFamilyHistoryDialogState();
}

class _AddFamilyHistoryDialogState extends State<AddFamilyHistoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _description = TextEditingController();

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final fh = FamilyHistoryRecord(description: _description.text.trim(), createdAt: DateTime.now().toIso8601String());
    Navigator.of(context).pop(fh);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Add Family History', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, color: Colors.white)),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                TextFormField(controller: _description, maxLines: 6, decoration: InputDecoration(labelText: 'Family history description', filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none)), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                const SizedBox(height: 18),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _submit, style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor), child:  Text('Save' , style: TextStyle(color: Colors.white),)),
                ])
              ]),
            ),
          )
        ]),
      ),
    );
  }
}

// Simple local models for the new sections
class OperationRecord {
  final String date;
  final String doctor;
  final String? description;
  OperationRecord({required this.date, required this.doctor, this.description});
}

class FamilyHistoryRecord {
  final String description;
  final String createdAt;
  FamilyHistoryRecord({required this.description, required this.createdAt});
}