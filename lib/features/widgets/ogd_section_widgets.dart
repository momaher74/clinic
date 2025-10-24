import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/models/patient.dart';
import 'package:clinic/core/models/endoscopy.dart';
import 'package:clinic/features/managers/endoscopy/ogd_cubit.dart';

class OgdSection extends StatelessWidget {
  final Patient patient;

  const OgdSection({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<OgdCubit>().loadForPatient(patient.id!, force: true);
      } catch (_) {}
    });

    return BlocBuilder<OgdCubit, OgdState>(
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
                  'OGD',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
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
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.add, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Add OGD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
                      'OGD',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
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
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.add, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text('Add OGD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
                                  colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
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
                            const Padding(
                              padding: EdgeInsets.only(left: 6, right: 6),
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor: Color(0xFFFFEBEE),
                                child: Icon(Icons.medical_services, color: Color(0xFFFF6B6B)),
                              ),
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
                                        if (item.ec.isNotEmpty) _infoChip('EC', item.ec),
                                        if (item.endoscopist.isNotEmpty) _infoChip('Endoscopist', item.endoscopist),
                                        if (item.followUp.isNotEmpty) _infoChip('Follow Up', item.followUp),
                                        if (item.report.isNotEmpty) _infoChip('Report', item.report),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                onPressed: () => context.read<OgdCubit>().delete(item.id!),
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
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<OgdCubit>(),
        child: AddEndoscopyDialog(patientId: patient.id!, type: 'OGD'),
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

class AddEndoscopyDialog extends StatefulWidget {
  final int patientId;
  final String type;

  const AddEndoscopyDialog({super.key, required this.patientId, required this.type});

  @override
  State<AddEndoscopyDialog> createState() => _AddEndoscopyDialogState();
}

class _AddEndoscopyDialogState extends State<AddEndoscopyDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _date;
  final ecCtrl = TextEditingController();
  final endoscopistCtrl = TextEditingController();
  final followUpCtrl = TextEditingController();
  final reportCtrl = TextEditingController();

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

  void _submit() async {
    if (!_formKey.currentState!.validate() || _date == null) return;
    final endoscopy = Endoscopy(
      patientId: widget.patientId,
      type: widget.type,
      date: _date!.toIso8601String(),
      ec: ecCtrl.text.trim(),
      endoscopist: endoscopistCtrl.text.trim(),
      followUp: followUpCtrl.text.trim(),
      report: reportCtrl.text.trim(),
    );
    try {
      if (widget.type == 'OGD') {
        await context.read<OgdCubit>().add(endoscopy);
      }
      Navigator.of(context).pop();
    } catch (e) {
      print('Error adding ${widget.type}: $e');
    }
  }

  Color _getGradientColor1() {
    switch (widget.type) {
      case 'OGD':
        return const Color(0xFFFF6B6B);
      case 'Colonoscopy':
        return const Color(0xFF4ECDC4);
      case 'ERCP':
        return const Color(0xFFFFBE0B);
      case 'EUS':
        return const Color(0xFF9B59B6);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  Color _getGradientColor2() {
    switch (widget.type) {
      case 'OGD':
        return const Color(0xFFEE5A6F);
      case 'Colonoscopy':
        return const Color(0xFF44A08D);
      case 'ERCP':
        return const Color(0xFFFB8500);
      case 'EUS':
        return const Color(0xFF8E44AD);
      default:
        return const Color(0xFF7C3AED);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_getGradientColor1(), _getGradientColor2()],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(14)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Text(
                      'Add ${widget.type}',
                      style: const TextStyle(
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
                            _date == null ? 'Select Date' : '${_date!.day}/${_date!.month}/${_date!.year}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(controller: ecCtrl, label: 'EC'),
                      CustomTextField(controller: endoscopistCtrl, label: 'Endoscopist'),
                      CustomTextField(controller: followUpCtrl, label: 'Follow Up'),
                      CustomTextField(controller: reportCtrl, label: 'Report', maxLines: 3),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_getGradientColor1(), _getGradientColor2()],
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
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check, color: Colors.white, size: 20),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Add ${widget.type}',
                                      style: const TextStyle(
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

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;
  final IconData? prefixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    this.label = '',
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, color: Colors.grey.shade600),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
