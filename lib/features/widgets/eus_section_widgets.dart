import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/models/patient.dart';
import 'package:clinic/core/models/endoscopy.dart';
import 'package:clinic/features/managers/endoscopy/eus_cubit.dart';
import 'package:clinic/features/widgets/ogd_section_widgets.dart';
import 'package:clinic/core/services/image_service.dart';
import 'package:clinic/core/constants/constants.dart';

class EusSection extends StatelessWidget {
  final Patient patient;

  const EusSection({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<EusCubit>().loadForPatient(patient.id!, force: true);
      } catch (_) {}
    });

    return BlocBuilder<EusCubit, EusState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'EUS',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showAddDialog(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.add, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Add EUS',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'EUS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _showAddDialog(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.add, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Add EUS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.list.length,
                    itemBuilder: (context, index) {
                      final item = state.list[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 6,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF9B59B6),
                                    Color(0xFF8E44AD),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  bottomLeft: Radius.circular(14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Padding(
                              padding: const EdgeInsets.only(left: 6, right: 6),
                              child:
                                  item.imagePath != null &&
                                      item.imagePath!.isNotEmpty
                                  ? InkWell(
                                      onTap: () => sharedOpenImage(
                                        context,
                                        item.imagePath!,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(22),
                                        child: Image.file(
                                          File(item.imagePath!),
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, st) =>
                                              const CircleAvatar(
                                                radius: 22,
                                                backgroundColor: Color(
                                                  0xFFF3E5F5,
                                                ),
                                                child: Icon(
                                                  Icons.monitor_heart,
                                                  color: Color(0xFF9B59B6),
                                                ),
                                              ),
                                        ),
                                      ),
                                    )
                                  : const CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Color(0xFFF3E5F5),
                                      child: Icon(
                                        Icons.monitor_heart,
                                        color: Color(0xFF9B59B6),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 6,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _formatDate(item.date),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        if (item.ec.isNotEmpty)
                                          _infoChip('EC', item.ec),
                                        if (item.endoscopist.isNotEmpty)
                                          _infoChip(
                                            'Endoscopist',
                                            item.endoscopist,
                                          ),
                                        if (item.followUp.isNotEmpty)
                                          _infoChip('Follow Up', item.followUp),
                                        if (item.report.isNotEmpty)
                                          _infoChip('Report', item.report),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.grey,
                                ),
                                onPressed: () =>
                                    context.read<EusCubit>().delete(item.id!),
                                tooltip: 'Delete',
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
          );
        }
      },
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => MultiBlocProvider(
        providers: [BlocProvider.value(value: context.read<EusCubit>())],
        child: _EusAddDialog(patientId: patient.id!),
      ),
    );
  }
}

class _EusAddDialog extends StatefulWidget {
  final int patientId;

  const _EusAddDialog({required this.patientId});

  @override
  State<_EusAddDialog> createState() => _EusAddDialogState();
}

class _EusAddDialogState extends State<_EusAddDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _date;
  final ecCtrl = TextEditingController();
  final endoscopistCtrl = TextEditingController();
  final followUpCtrl = TextEditingController();
  final reportCtrl = TextEditingController();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
  }

  @override
  void dispose() {
    ecCtrl.dispose();
    endoscopistCtrl.dispose();
    followUpCtrl.dispose();
    reportCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickImage() async {
    final stored = await ImageService.pickAndStoreImage();
    if (stored != null) setState(() => _imagePath = stored);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _date == null) return;
    final endoscopy = Endoscopy(
      patientId: widget.patientId,
      type: 'EUS',
      date: _date!.toIso8601String(),
      ec: ecCtrl.text.trim(),
      endoscopist: endoscopistCtrl.text.trim(),
      followUp: followUpCtrl.text.trim(),
      report: reportCtrl.text.trim(),
      imagePath: _imagePath,
    );
    try {
      await context.read<EusCubit>().add(endoscopy);
      Navigator.of(context).pop();
    } catch (e) {
      print('Error adding EUS: $e');
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
            gradient: LinearGradient(
              colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    const Text(
                      'Add EUS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          child: Text(
                            _date == null
                                ? 'Select Date'
                                : '${_date!.day}/${_date!.month}/${_date!.year}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_imagePath != null)
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () =>
                                  sharedOpenImage(context, _imagePath!),
                              child: Center(
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxHeight: 220,
                                          // allow full width but cap height
                                        ),
                                        child: Image.file(
                                          File(_imagePath!),
                                          fit: BoxFit.contain,
                                          width: double.infinity,
                                          errorBuilder: (ctx, err, st) =>
                                              Container(
                                                height: 140,
                                                color: Colors.grey.shade200,
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  size: 52,
                                                ),
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
                                            onPressed: () => setState(
                                              () => _imagePath = null,
                                            ),
                                            tooltip: 'Remove image',
                                          ),
                                        ),
                                        const SizedBox(width: 6),
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
                        ),
                      if (_imagePath == null)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Pick Image (optional)'),
                          ),
                        ),
                      CustomTextField(controller: ecCtrl, label: 'EC'),
                      CustomTextField(
                        controller: endoscopistCtrl,
                        label: 'Endoscopist',
                      ),
                      CustomTextField(
                        controller: followUpCtrl,
                        label: 'Follow Up',
                      ),
                      CustomTextField(
                        controller: reportCtrl,
                        label: 'Report',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: _submit,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Add EUS',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
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

String _formatDate(String date) {
  try {
    final parsed = DateTime.tryParse(date);
    if (parsed != null) {
      return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
    }
  } catch (_) {}
  return date.contains('T') ? date.split('T').first : date;
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
