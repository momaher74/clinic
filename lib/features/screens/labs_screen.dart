import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/models/patient.dart';
import 'package:clinic/features/managers/labs/cbc/cbc_cubit.dart';
import 'package:clinic/features/widgets/cbc_section_widgets.dart';
import 'package:clinic/features/managers/labs/liver_function_test/liver_function_test_cubit.dart';
import 'package:clinic/features/widgets/liver_function_section_widgets.dart';
import 'package:clinic/features/managers/labs/kidney_function_test/kidney_function_test_cubit.dart';
import 'package:clinic/features/widgets/kidney_function_section_widgets.dart';
import 'package:clinic/features/managers/labs/thyroid_profile/thyroid_profile_cubit.dart';
import 'package:clinic/features/widgets/thyroid_profile_section_widgets.dart';
import 'package:clinic/features/managers/labs/diabetes_labs/diabetes_labs_cubit.dart';
import 'package:clinic/features/widgets/diabetes_labs_section_widgets.dart';
import 'package:clinic/features/managers/labs/lipid_profile/lipid_profile_cubit.dart';
import 'package:clinic/features/widgets/lipid_profile_section_widgets.dart';
import 'package:clinic/features/managers/labs/virology/virology_cubit.dart';
import 'package:clinic/features/widgets/virology_section_widgets.dart';
import 'package:clinic/features/managers/labs/inflammatory_markers/inflammatory_markers_cubit.dart';
import 'package:clinic/features/widgets/inflammatory_markers_section_widgets.dart';
import 'package:clinic/features/managers/labs/pancreatic_enzymes/pancreatic_enzymes_cubit.dart';
import 'package:clinic/features/widgets/pancreatic_enzymes_section_widgets.dart';
import 'package:clinic/features/managers/labs/autoimmune_markers/autoimmune_markers_cubit.dart';
import 'package:clinic/features/widgets/autoimmune_markers_section_widgets.dart';
import 'package:clinic/features/managers/labs/coagulation_profile/coagulation_profile_cubit.dart';
import 'package:clinic/features/widgets/coagulation_profile_section_widgets.dart';
import 'package:clinic/features/managers/labs/iron_profile/iron_profile_cubit.dart';
import 'package:clinic/features/widgets/iron_profile_section_widgets.dart';
import 'package:clinic/features/managers/labs/cu_profile/cu_profile_cubit.dart';
import 'package:clinic/features/widgets/cu_profile_section_widgets.dart';
import 'package:clinic/features/managers/labs/celiac_disease_labs/celiac_disease_labs_cubit.dart';
import 'package:clinic/features/widgets/celiac_disease_labs_section_widgets.dart';
import 'package:clinic/features/managers/labs/tumor_markers/tumor_markers_cubit.dart';
import 'package:clinic/features/widgets/tumor_markers_section_widgets.dart';
import 'package:clinic/features/managers/labs/vitamin_level/vitamin_level_cubit.dart';
import 'package:clinic/features/widgets/vitamin_level_section_widgets.dart';
import 'package:clinic/features/managers/labs/pregnancy_test/pregnancy_test_cubit.dart';
import 'package:clinic/features/widgets/pregnancy_test_section_widgets.dart';
import 'package:clinic/features/managers/labs/stool_tests/stool_tests_cubit.dart';
import 'package:clinic/features/widgets/stool_tests_section_widgets.dart';
import 'package:clinic/features/managers/labs/urine_analysis/urine_analysis_cubit.dart';
import 'package:clinic/features/widgets/urine_analysis_section_widgets.dart';
import 'dart:io';
import 'package:clinic/core/services/image_service.dart';
import 'package:clinic/core/constants/constants.dart';
import 'package:clinic/core/services/sql_service.dart';

class LabsScreen extends StatefulWidget {
  final Patient patient;

  const LabsScreen({super.key, required this.patient});

  @override
  State<LabsScreen> createState() => _LabsScreenState();
}

class _LabsScreenState extends State<LabsScreen> {
  final List<LabImageRecord> _labImages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initLabImages());
  }

  Future<void> _initLabImages() async {
    final db = DatabaseService();
    await db.createTableWithAttributes('lab_images', [
      'patient_id',
      'path',
      'caption',
      'created_at',
    ]);
    await _loadLabImages();
  }

  Future<void> _loadLabImages() async {
    final db = DatabaseService();
    final rows = await db.getAll('lab_images');
    final pid = widget.patient.id?.toString();
    final imgs = <LabImageRecord>[];
    for (final r in rows) {
      try {
        if (r['patient_id']?.toString() == pid) {
          imgs.add(
            LabImageRecord(
              id: r['id'] as int?,
              patientId: int.tryParse(r['patient_id']?.toString() ?? ''),
              path: r['path']?.toString() ?? '',
              caption: r['caption']?.toString(),
              createdAt: r['created_at']?.toString() ?? '',
            ),
          );
        }
      } catch (_) {}
    }
    setState(() {
      _labImages
        ..clear()
        ..addAll(imgs.reversed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              CbcCubit()..loadForPatient(widget.patient.id!, force: true),
        ),
        BlocProvider(
          create: (_) =>
              LiverFunctionTestCubit()
                ..loadForPatient(widget.patient.id!, force: true),
        ),
        BlocProvider(
          create: (_) =>
              KidneyFunctionTestCubit()
                ..loadForPatient(widget.patient.id!, force: true),
        ),
        BlocProvider(
          create: (_) =>
              DiabetesLabsCubit()
                ..loadForPatient(widget.patient.id!, force: true),
        ),
        BlocProvider(
          create: (_) =>
              LipidProfileCubit()
                ..loadForPatient(widget.patient.id!, force: true),
        ),
        BlocProvider(
          create: (_) =>
              IronProfileCubit()
                ..loadForPatient(widget.patient.id!, force: true),
        ),
        BlocProvider(
          create: (_) =>
              CuProfileCubit()..loadForPatient(widget.patient.id!, force: true),
        ),
        BlocProvider(
          create: (_) =>
              ThyroidProfileCubit()
                ..loadForPatient(widget.patient.id!, force: true),
        ),
        // Re-provide the VirologyCubit from parent so the MultiBlocProvider and descendants use the same instance
        BlocProvider.value(value: context.read<VirologyCubit>()),
        // Re-provide the InflammatoryMarkersCubit from parent
        BlocProvider.value(value: context.read<InflammatoryMarkersCubit>()),
        // Re-provide the PancreaticEnzymesCubit from parent
        BlocProvider.value(value: context.read<PancreaticEnzymesCubit>()),
        // Re-provide the AutoimmuneMarkersCubit from parent
        BlocProvider.value(value: context.read<AutoimmuneMarkersCubit>()),
        // Re-provide the CoagulationProfileCubit from parent
        BlocProvider.value(value: context.read<CoagulationProfileCubit>()),
        // Provide CeliacDiseaseLabsCubit for this screen
        BlocProvider(
          create: (_) =>
              CeliacDiseaseLabsCubit()
                ..loadForPatient(widget.patient.id!, force: true),
        ),
        // Provide TumorMarkersCubit for this screen
        BlocProvider(
          create: (_) =>
              TumorMarkersCubit()
                ..loadForPatient(widget.patient.id!, force: true),
        ),
        BlocProvider(
          create: (_) =>
              VitaminLevelCubit()
                ..loadForPatient(widget.patient.id!, force: true),
        ),
        BlocProvider(
          create: (_) =>
              PregnancyTestCubit()
                ..loadForPatient(widget.patient.id!, force: true),
        ),
        BlocProvider(
          create: (_) =>
              StoolTestsCubit()
                ..loadForPatient(widget.patient.id!, force: true),
        ),
        BlocProvider(
          create: (_) =>
              UrineAnalysisCubit()
                ..loadForPatient(widget.patient.id!, force: true),
        ),
        // Note: AutoimmuneMarkersCubit is provided by the parent (LayoutScreen) so we do not attempt to re-read it here.
      ],
      child: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            'Lab Images',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final rec = await showDialog<LabImageRecord>(
                                context: context,
                                builder: (_) => const AddLabImageDialog(),
                              );
                              if (rec != null) {
                                try {
                                  final db = DatabaseService();
                                  final id = await db.insert('lab_images', {
                                    'patient_id':
                                        widget.patient.id?.toString() ?? '',
                                    'path': rec.path,
                                    'caption': rec.caption ?? '',
                                    'created_at': rec.createdAt,
                                  });
                                  final newRec = LabImageRecord(
                                    id: id,
                                    patientId: widget.patient.id,
                                    path: rec.path,
                                    caption: rec.caption,
                                    createdAt: rec.createdAt,
                                  );
                                  setState(() => _labImages.insert(0, newRec));
                                } catch (e) {
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
                      if (_labImages.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No images added.'),
                        )
                      else
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _labImages.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, idx) {
                              final it = _labImages[idx];
                              return GestureDetector(
                                onTap: () => sharedOpenImage(context, it.path),
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
                                          child: const Icon(Icons.broken_image),
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
                                                    title: const Text('Delete'),
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
                                              if (it.id != null) {
                                                try {
                                                  await DatabaseService()
                                                      .delete(
                                                        'lab_images',
                                                        it.id!,
                                                      );
                                                } catch (_) {}
                                              }
                                              await ImageService.deleteStoredImage(
                                                it.path,
                                              );
                                              setState(
                                                () => _labImages.removeAt(idx),
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

              const SizedBox(height: 12),

              CbcSection(patient: widget.patient),
              const SizedBox(height: 12),
              LiverFunctionSection(patient: widget.patient),
              const SizedBox(height: 12),
              KidneyFunctionSection(patient: widget.patient),
              const SizedBox(height: 12),
              DiabetesLabsSection(patient: widget.patient),
              const SizedBox(height: 12),
              LipidProfileSection(patient: widget.patient),
              const SizedBox(height: 12),
              IronProfileSection(patient: widget.patient),
              const SizedBox(height: 12),
              CuProfileSection(patient: widget.patient),
              const SizedBox(height: 12),
              PancreaticEnzymesSection(patient: widget.patient),
              const SizedBox(height: 12),
              VirologySection(patient: widget.patient),
              const SizedBox(height: 12),
              InflammatoryMarkersSection(patient: widget.patient),
              const SizedBox(height: 12),
              AutoimmuneMarkersSection(patient: widget.patient),
              const SizedBox(height: 12),
              CoagulationProfileSection(patient: widget.patient),
              const SizedBox(height: 12),
              CeliacDiseaseLabsSection(patient: widget.patient),
              const SizedBox(height: 12),
              TumorMarkersSection(patient: widget.patient),
              const SizedBox(height: 12),
              VitaminLevelSection(patient: widget.patient),
              const SizedBox(height: 12),
              PregnancyTestSection(patient: widget.patient),
              const SizedBox(height: 12),
              StoolTestsSection(patient: widget.patient),
              const SizedBox(height: 12),
              UrineAnalysisSection(patient: widget.patient),
              const SizedBox(height: 12),
              ThyroidProfileSection(patient: widget.patient),
              const SizedBox(height: 24),

              // Lab Images section (mirrors Examination Images)
            ],
          ),
        ),
      ),
    );
  }

  // Simple local model + dialog for adding a lab image
}

class LabImageRecord {
  final int? id;
  final int? patientId;
  final String path;
  final String? caption;
  final String createdAt;

  LabImageRecord({
    this.id,
    this.patientId,
    required this.path,
    this.caption,
    required this.createdAt,
  });
}

class AddLabImageDialog extends StatefulWidget {
  const AddLabImageDialog({super.key});

  @override
  State<AddLabImageDialog> createState() => _AddLabImageDialogState();
}

class _AddLabImageDialogState extends State<AddLabImageDialog> {
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
    final rec = LabImageRecord(
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
                      'Add Lab Image',
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
