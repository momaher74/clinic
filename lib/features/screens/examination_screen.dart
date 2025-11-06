import 'dart:io';
import 'package:clinic/core/services/image_service.dart';
import 'package:clinic/core/constants/constants.dart';
import 'package:clinic/core/services/sql_service.dart';
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
  // Local in-memory list of images added in this screen session.
  final List<ExaminationImageRecord> _examImages = [];

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

  @override
  void initState() {
    super.initState();
    // initialize DB table and load images for currently selected patient
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _initExaminationImages(),
    );
  }

  Future<void> _initExaminationImages() async {
    final db = DatabaseService();
    await db.createTableWithAttributes('examination_images', [
      'patient_id',
      'path',
      'caption',
      'created_at',
    ]);
    await _loadExaminationImages();
  }

  Future<void> _loadExaminationImages() async {
    final db = DatabaseService();
    final pState = context.read<PatientCubit>().state;
    if (pState.selectedIds.isEmpty) {
      setState(() => _examImages.clear());
      return;
    }
    final pid = pState.selectedIds.first;
    final rows = await db.getAll('examination_images');
    final imgs = <ExaminationImageRecord>[];
    for (final r in rows) {
      try {
        if (r['patient_id']?.toString() == pid.toString()) {
          imgs.add(
            ExaminationImageRecord(
              id: r['id'] as int?,
              patientId: int.tryParse(r['patient_id']?.toString() ?? '') ?? pid,
              path: r['path']?.toString() ?? '',
              caption: r['caption']?.toString(),
              createdAt: r['created_at']?.toString() ?? '',
            ),
          );
        }
      } catch (_) {}
    }
    // show newest first
    setState(() {
      _examImages
        ..clear()
        ..addAll(imgs.reversed);
    });
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select a patient first')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Examination saved')));
      _formKey.currentState!.reset();
      bpCtrl.clear();
      pulseCtrl.clear();
      tempCtrl.clear();
      spo2Ctrl.clear();
      otherCtrl.clear();
      examCtrl.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  Future<void> _submitReq() async {
    final patientState = context.read<PatientCubit>().state;
    if (patientState.selectedIds.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select a patient first')));
      return;
    }
    final pid = patientState.selectedIds.first;
    if (reqCtrl.text.trim().isEmpty) return;
    final r = Req(patientId: pid, description: reqCtrl.text.trim());
    try {
      await context.read<ExaminationCubit>().addReq(r);
      await context.read<ExaminationCubit>().loadForPatient(pid);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Req added')));
      reqCtrl.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
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
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  InputDecoration _fieldDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,

      prefixIcon: icon == null ? null : Icon(icon, color: Colors.grey.shade700),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExaminationCubit, ExaminationState>(
      builder: (context, state) {
        // try to load when patient selection changes
        final patientState = context.watch<PatientCubit>().state;
        if (patientState.selectedIds.isNotEmpty &&
            (state.patientId != patientState.selectedIds.first)) {
          // load new patient data and reload examination images for the newly selected patient
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<ExaminationCubit>().loadForPatient(
              patientState.selectedIds.first,
            );
            _loadExaminationImages();
          });
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                              const Text(
                                'New Examination',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _loadForSelectedPatient,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reload'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: bpCtrl,
                                  decoration: _fieldDecoration(
                                    'Bp',
                                    icon: Icons.favorite,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: pulseCtrl,
                                  decoration: _fieldDecoration(
                                    'Pulse',
                                    icon: Icons.monitor_heart,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: tempCtrl,
                                  decoration: _fieldDecoration(
                                    'Temp',
                                    icon: Icons.thermostat_rounded,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: spo2Ctrl,
                                  decoration: _fieldDecoration(
                                    'SPO2',
                                    icon: Icons.bubble_chart,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: otherCtrl,
                            decoration: _fieldDecoration(
                              'Other',
                              icon: Icons.more_horiz,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: examCtrl,
                            decoration: _fieldDecoration(
                              'Examination',
                              icon: Icons.assignment,
                            ),
                            maxLines: 4,
                          ),

                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _submitExamination,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3B82F6),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Save Examination',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Req',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: reqCtrl,
                                decoration: _fieldDecoration(
                                  'Description',
                                  icon: Icons.note_add,
                                ),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 14,
                                  ),
                                ),
                                child: Text(
                                  'Add',
                                  style: TextStyle(color: Colors.white),
                                ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Examinations',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (state.isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        if (!state.isLoading && state.examinations.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('No examinations yet.'),
                          ),
                        if (state.examinations.isNotEmpty)
                          for (final e in state.examinations)
                            Dismissible(
                              key: ValueKey('ex-${e.id}-${e.createdAt}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.redAccent,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (_) {
                                if (e.id != null)
                                  context
                                      .read<ExaminationCubit>()
                                      .deleteExamination(e.id!);
                              },
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 6,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.indigo.shade50,
                                  child: Text(
                                    _initials(
                                      e.examination.isNotEmpty
                                          ? e.examination
                                          : '${e.bp}',
                                    ),
                                  ),
                                ),
                                title: Text(
                                  e.examination.isEmpty
                                      ? 'Vitals: ${_compactVitals(e)}'
                                      : e.examination,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  '${_formatCreatedAt(e.createdAt)}\nBp: ${e.bp} • Pulse: ${e.pulse} • Temp: ${e.temp} • SPO2: ${e.spo2}',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                                isThreeLine: true,
                                trailing: IconButton(
                                  onPressed: () {
                                    if (e.id != null)
                                      context
                                          .read<ExaminationCubit>()
                                          .deleteExamination(e.id!);
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Reqs',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (!state.isLoading && state.reqs.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('No reqs yet.'),
                          ),
                        if (state.reqs.isNotEmpty)
                          for (final r in state.reqs)
                            Dismissible(
                              key: ValueKey('rq-${r.id}-${r.createdAt}'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.redAccent,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (_) {
                                if (r.id != null)
                                  context.read<ExaminationCubit>().deleteReq(
                                    r.id!,
                                  );
                              },
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green.shade50,
                                  child: const Icon(
                                    Icons.request_page,
                                    color: Colors.green,
                                  ),
                                ),
                                title: Text(
                                  r.description,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  _formatCreatedAt(r.createdAt),
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    if (r.id != null)
                                      context
                                          .read<ExaminationCubit>()
                                          .deleteReq(r.id!);
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Examination Images card
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Examination Images',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final rec =
                                    await showDialog<ExaminationImageRecord>(
                                      context: context,
                                      builder: (_) =>
                                          const AddExaminationImageDialog(),
                                    );
                                if (rec != null) {
                                  final pState = context
                                      .read<PatientCubit>()
                                      .state;
                                  if (pState.selectedIds.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Select a patient first'),
                                      ),
                                    );
                                    return;
                                  }
                                  final pid = pState.selectedIds.first;
                                  try {
                                    final db = DatabaseService();
                                    final id = await db
                                        .insert('examination_images', {
                                          'patient_id': pid.toString(),
                                          'path': rec.path,
                                          'caption': rec.caption ?? '',
                                          'created_at': rec.createdAt,
                                        });
                                    final newRec = ExaminationImageRecord(
                                      id: id,
                                      patientId: pid,
                                      path: rec.path,
                                      caption: rec.caption,
                                      createdAt: rec.createdAt,
                                    );
                                    setState(
                                      () => _examImages.insert(0, newRec),
                                    );
                                  } catch (e) {
                                    // show minimal feedback
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Save image failed: $e'),
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(
                                Icons.add_photo_alternate_outlined,
                              ),
                              label: const Text('Add Image'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (_examImages.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('No images added.'),
                          )
                        else
                          SizedBox(
                            height: 120,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _examImages.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, idx) {
                                final it = _examImages[idx];
                                return GestureDetector(
                                  onTap: () =>
                                      sharedOpenImage(context, it.path),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(it.path),
                                          width: 160,
                                          height: 110,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, e, s) => Container(
                                            width: 160,
                                            height: 110,
                                            color: Colors.grey.shade200,
                                            child: const Icon(
                                              Icons.broken_image,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: 6,
                                        top: 6,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black45,
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 32,
                                              minHeight: 32,
                                            ),
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                            onPressed: () async {
                                              final confirm =
                                                  await showDialog<bool>(
                                                    context: context,
                                                    builder: (c) => AlertDialog(
                                                      title: const Text(
                                                        'Delete',
                                                      ),
                                                      content: const Text(
                                                        'Delete this image?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                c,
                                                              ).pop(false),
                                                          child: const Text(
                                                            'Cancel',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                c,
                                                              ).pop(true),
                                                          child: const Text(
                                                            'Delete',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                              if (confirm == true) {
                                                // delete DB record if present
                                                if (it.id != null) {
                                                  try {
                                                    await DatabaseService()
                                                        .delete(
                                                          'examination_images',
                                                          it.id!,
                                                        );
                                                  } catch (_) {}
                                                }
                                                // best-effort delete stored file
                                                await ImageService.deleteStoredImage(
                                                  it.path,
                                                );
                                                setState(
                                                  () =>
                                                      _examImages.removeAt(idx),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
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
    if (pState.selectedIds.isEmpty)
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('No patient selected'),
      );
    final patient = pState.patients.firstWhere(
      (p) => p.id == pState.selectedIds.first,
    );
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.indigo.shade50,
            child: Text(
              _initials(patient.name),
              style: const TextStyle(
                color: Colors.indigo,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${patient.age} Y',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      patient.sex,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  patient.mobile,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showDeleteAllDialog(context),
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Delete all for this patient?'),
        content: const Text(
          'This will delete all examinations and reqs for selected patient.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final pid = context.read<PatientCubit>().state.selectedIds.first;
              // delete all examinations
              for (final e in List.of(
                context.read<ExaminationCubit>().state.examinations,
              )) {
                if (e.patientId == pid && e.id != null)
                  await context.read<ExaminationCubit>().deleteExamination(
                    e.id!,
                  );
              }
              for (final r in List.of(
                context.read<ExaminationCubit>().state.reqs,
              )) {
                if (r.patientId == pid && r.id != null)
                  await context.read<ExaminationCubit>().deleteReq(r.id!);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

// Simple local model + dialog for adding an examination image
class ExaminationImageRecord {
  final int? id;
  final int? patientId;
  final String path;
  final String? caption;
  final String createdAt;

  ExaminationImageRecord({
    this.id,
    this.patientId,
    required this.path,
    this.caption,
    required this.createdAt,
  });
}

class AddExaminationImageDialog extends StatefulWidget {
  const AddExaminationImageDialog({super.key});

  @override
  State<AddExaminationImageDialog> createState() =>
      _AddExaminationImageDialogState();
}

class _AddExaminationImageDialogState extends State<AddExaminationImageDialog> {
  String? _imagePath;
  final TextEditingController _captionCtrl = TextEditingController();

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final stored = await ImageService.pickAndStoreImage();
    if (stored != null) setState(() => _imagePath = stored);
  }

  void _submit() {
    if (_imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick an image (required)')),
      );
      return;
    }
    final rec = ExaminationImageRecord(
      path: _imagePath!,
      caption: _captionCtrl.text.trim().isEmpty
          ? null
          : _captionCtrl.text.trim(),
      createdAt: DateTime.now().toIso8601String(),
    );
    Navigator.of(context).pop(rec);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add Examination Image',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_imagePath != null)
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => sharedOpenImage(context, _imagePath!),
                            child: Center(
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxHeight: 220,
                                      ),
                                      child: Image.file(
                                        File(_imagePath!),
                                        fit: BoxFit.contain,
                                        width: double.infinity,
                                        errorBuilder: (ctx, e, st) => Container(
                                          height: 140,
                                          color: Colors.grey.shade200,
                                          child: const Icon(Icons.broken_image),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Material(
                                        color: Colors.black45,
                                        shape: const CircleBorder(),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          onPressed: _pickImage,
                                          tooltip: 'Change image',
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Material(
                                        color: Colors.black45,
                                        shape: const CircleBorder(),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          onPressed: () =>
                                              setState(() => _imagePath = null),
                                          tooltip: 'Remove image',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap image to preview',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Pick Image (required)'),
                        ),
                      ),

                    const SizedBox(height: 12),
                    TextField(
                      controller: _captionCtrl,
                      decoration: InputDecoration(
                        labelText: 'Caption (optional)',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
